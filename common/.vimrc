" ============================================================================
" 统一 vimrc —— Windows / macOS / Linux 通用，Vim 8+ 与 Neovim 共用
" 设计原则：零插件依赖；平台差异一律用 has() 判断，不再维护多份文件。
" 维护约定见仓库根目录 AGENTS.md。
" ============================================================================

" ---------------------------------------------------------------- 基础兼容
set nocompatible
set encoding=utf-8
scriptencoding utf-8

" Vim 自带示例配置（Neovim 没有此文件且默认合理，跳过）
if !has('nvim')
  silent! runtime! vimrc_example.vim
endif

" matchit：增强 % 跳转。Vim 直接 runtime，Neovim 用自带 pack。
if has('nvim')
  silent! packadd matchit
else
  silent! runtime! macros/matchit.vim
endif

" Windows GUI（gVim）沿用 MS 习惯按键；终端模式不 behave mswin，避免劫持 Ctrl-V
if has('win32') && has('gui_running')
  source $VIMRUNTIME/mswin.vim
  behave mswin
endif

syntax on
filetype plugin indent on

" ---------------------------------------------------------------- 文件与备份
set nobackup
set nowritebackup
set noswapfile

if has('persistent_undo')
  set undofile
  set undolevels=1000
  set undoreload=10000
  let s:undo_dir = expand(has('win32') ? '~/vimfiles/undo' : '~/.vim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
  endif
  let &undodir = s:undo_dir . '//'
endif

" ---------------------------------------------------------------- 编码
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312,cp936,big5,latin1
set fileformats=unix,dos,mac
set ambiwidth=double

" gVim 中文菜单乱码修复（仅 Windows GUI）
if has('gui_running') && has('win32')
  source $VIMRUNTIME/delmenu.vim
  set langmenu=zh_CN.UTF-8
  source $VIMRUNTIME/menu.vim
endif

" ---------------------------------------------------------------- 界面
set number
set cursorline
set ruler
set laststatus=2
set statusline=%F%m%r%h%w\ [F=%Y]\ [L=%l/%L,C=%c]\ %{&fenc!=''?&fenc:&enc}
set showcmd
set showmode
set wildmenu
set wildignore=*.o,*.obj,*.pyc,*.class,*.swp,*.bak,*.exe,*.dll
set scrolloff=5
set history=1000
set updatetime=300
set noshowmatch
set listchars=tab:>-,trail:$,extends:>,precedes:<,nbsp:+
set nolist
set background=dark
silent! colorscheme evening

if has('gui_running')
  set guioptions+=m          " 保留菜单栏
  set guioptions-=T          " 隐藏工具栏
  set guioptions-=r          " 隐藏右侧滚动条
  set guioptions-=L          " 隐藏左侧滚动条
  set lines=40 columns=120
  if has('win32')
    set guifont=JetBrains_Mono_NL:h11:cANSI:qDRAFT
  elseif has('mac')
    set guifont=Monaco:h13
  else
    set guifont=Monospace\ 11
  endif
endif

" 终端下插入/普通模式光标形状（xterm 系）
if !has('gui_running') && &term =~# 'xterm\|screen\|tmux'
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
  let &t_SR = "\e[4 q"
  let &t_ti .= "\e[2 q"
  let &t_te .= "\e[6 q"
endif

" Windows 终端（非 GUI）256 色兜底
if has('win32') && !has('gui_running')
  set t_Co=256
endif

" 恢复上次光标位置
augroup dotfiles_last_position
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ | exe "normal! g`\""
        \ | endif
augroup END

" ---------------------------------------------------------------- 编辑行为
set autoindent
set smartindent
set cindent
set backspace=indent,eol,start
set confirm
set hidden
set mouse=a
set timeoutlen=300 ttimeoutlen=10
set viminfo+=!
set isk+=$,%,#,-
map Q gq
" Neovim 已移除 pastetoggle（改用 :set paste）；仅 Vim 设置
if !has('nvim')
  set pastetoggle=<F2>
endif

" Windows 路径用正斜杠（方便复制路径）
if has('win32')
  set shellslash
endif

set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set smarttab
set formatoptions+=mM

" 剪贴板：能接系统剪贴板就接；无 +clipboard 的构建直接跳过
" （vim-tiny 等最小构建没有 clipboard；Debian/Ubuntu 默认 vim 已带）
if has('clipboard')
  if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
  else
    set clipboard=unnamed
  endif
endif

" macOS：允许 Meta 组合键
if exists('+macmeta')
  set macmeta
endif

" ---------------------------------------------------------------- 搜索
set ignorecase
set incsearch
set hlsearch
set smartcase
set wrapscan

" ---------------------------------------------------------------- 缩进：按文件类型
set foldenable
set foldmethod=indent
set foldlevel=100

augroup dotfiles_filetype
  autocmd!
  autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
  autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType c,cpp setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType javascript,typescript,json,yaml,yml,html,css,scss
        \ setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  " Nginx 配置沿用前端 2 空格
  autocmd BufRead,BufNewFile */nginx/*,*.nginx,*nginx.conf
        \ setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType text,markdown setlocal wrap linebreak nolist
augroup END

" ============================================================================
" 快捷键：Leader = 反斜杠（\），空格兼用
" （历史习惯以 \ 为主：\q 退出、\w 保存；空格同样可用）
" ============================================================================
let mapleader = "\\"
let maplocalleader = "\\"
" 空格兼用：空格等同反斜杠，后续按键走同一套 <leader> 映射
" （新增 <leader> 映射只需写一份，空格自动跟随）
nmap <Space> \
xmap <Space> \

" 退出/保存
nnoremap <leader>w  :w<CR>
nnoremap <leader>x  :x<CR>
nnoremap <leader>q  :q<CR>
nnoremap <leader>Q  :q!<CR>
nnoremap <leader>qa :qa!<CR>

" 快速编辑本配置
nnoremap <leader>fed  :e $MYVIMRC<CR>
nnoremap <leader>feR  :so $MYVIMRC<CR>

" Buffer 切换
nnoremap <leader>d  :bd<CR>
nnoremap <leader>n  :bn<CR>
nnoremap <leader>p  :bp<CR>

" 文件浏览（内置 netrw，无需 NERDTree）
nnoremap <leader>e  :Lexplore<CR>
nnoremap <leader>E  :Sexplore<CR>

" 显示切换 / 窗口均分
nnoremap <leader>L :set list!<CR>:set list?<CR>
nnoremap <leader>= <C-w>=

" 收尾 / 搜索
nnoremap <leader>/  :noh<CR>
nnoremap <leader>;  A;<Esc>
nnoremap Y y$
vnoremap < <gv
vnoremap > >gv

" 搜索居中
nnoremap n nzz
nnoremap N Nzz

" ESC 替代，缓解 ESC 延迟
inoremap jj <Esc>

" 插入模式快速换行
inoremap <S-CR> <Esc>o
inoremap <C-CR> <Esc>O

" 窗口导航
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>
nnoremap <leader>c <C-w>c
nnoremap <leader>o <C-w>o

" 删除行尾空格 / 显示文件信息
function! s:TrimTrailingWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
  echo "已删除行尾空格"
endfunction
command! TrimTrailingWhitespace call s:TrimTrailingWhitespace()
nnoremap <leader>T :TrimTrailingWhitespace<CR>

" 压缩连续空行（<leader>B）
function! s:ReduceBlankLines()
  let l:save = winsaveview()
  keeppatterns %s/\(\n\s*\)\{3,}/\r\r/e
  call winrestview(l:save)
  echo "已压缩空行"
endfunction
command! ReduceBlankLines call s:ReduceBlankLines()
nnoremap <leader>B :ReduceBlankLines<CR>

function! s:FileInfo()
  echo 'Enc=' . &fileencoding . ' FF=' . &fileformat . ' FT=' . &filetype
endfunction
command! FileInfo call s:FileInfo()

" gVim 下 Ctrl-S 保存
if has('gui_running')
  nnoremap <C-s> :w<CR>
  inoremap <C-s> <Esc>:w<CR>a
endif

" Windows 习惯按键（仅 win32；终端下未 behave mswin，不会全局劫持）
if has('win32')
  " 插入模式
  inoremap <C-v> <C-r>+
  inoremap <C-c> <Esc>yygi
  inoremap <C-x> <Esc>ddgi
  inoremap <C-z> <C-o>u
  inoremap <C-y> <C-o><C-r>
  inoremap <C-a> <Esc>ggVG
  inoremap <C-f> <Esc>/
  " 可视模式：Ctrl-C/X 进系统剪贴板（保留 Ctrl-V 块选择）
  vnoremap <C-c> "+y
  vnoremap <C-x> "+d
  " 普通模式
  nnoremap <C-a> ggVG
  nnoremap <C-c> "+yy
  " 传统 Windows 剪贴板键
  map <C-Insert> "+y
  imap <S-Insert> <C-r>+
  cmap <S-Insert> <C-r>+
  " 强制写入（PowerShell 回写）
  cnoremap w!! w !powershell -Command "Set-Content -Path '%' -Value (Get-Content -Raw)"
endif

" MSYS2 / Git-Bash 终端 vim（win32unix）：has('win32') 为 0，
" 上面的 win32 习惯按键不生效。单独补可视模式 Ctrl-C 复制选中到系统剪贴板。
" （终端里 Ctrl-C 默认只会退出可视模式，选中内容哪儿也没去——这就是之前复制失灵的原因。
" 另：开了 mouse=a 后，Windows Terminal 里用鼠标框选需按住 Shift 穿透。）
if has('win32unix') && !has('gui_running')
  vnoremap <C-c> "*y
endif

" Windows 外部 diff（处理空格路径；内部 diff 可用时不启用）
if has('win32') && &diffopt !~# 'internal'
  set diffexpr=MyDiff()
  function MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg1 = substitute(arg1, '!', '\!', 'g')
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg2 = substitute(arg2, '!', '\!', 'g')
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let arg3 = substitute(arg3, '!', '\!', 'g')
    if $VIMRUNTIME =~ ' '
      if &sh =~ '\<cmd'
        if empty(&shellxquote)
          let l:shxq_sav = ''
          set shellxquote&
        endif
        let cmd = '"' . $VIMRUNTIME . '\diff"'
      else
        let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
      endif
    else
      let cmd = $VIMRUNTIME . '\diff'
    endif
    let cmd = substitute(cmd, '!', '\!', 'g')
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
    if exists('l:shxq_sav')
      let &shellxquote=l:shxq_sav
    endif
  endfunction
endif

" ============================================================================
" 可选：YouCompleteMe（不常用，默认关闭）
" 启用：在 ~/.vimrc.local 写 `let g:dotfiles_enable_ycm = 1`
" 需自行按官方文档编译 YCM，并把 .ycm_extra_conf.py 放到 ~/.vim/ 下。
" ============================================================================
if get(g:, 'dotfiles_enable_ycm', 0) && !has('win32')
  let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
  let g:ycm_error_symbol = '>>'
  let g:ycm_warning_symbol = '>*'
  let g:ycm_seed_identifiers_with_syntax = 1
  let g:ycm_complete_in_comments = 1
  let g:ycm_complete_in_strings = 1
  let g:ycm_min_num_of_chars_for_completion = 2
  let g:ycm_autoclose_preview_window_after_completion = 1
  let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']

  nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
  nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
  nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
  nnoremap <F4> :YcmDiags<CR>
endif

" 个人本地覆盖（不进版本库，见 .gitignore 的 *.local）
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
