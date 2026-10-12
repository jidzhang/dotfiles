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
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312,big5,latin1
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
set ruler
set laststatus=2
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
    set guifont=JetBrains_Mono:h11
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
set viminfo+=!
set isk+=$,%,#,-
map Q gq
" Neovim 已移除 pastetoggle（改用 :set paste）；仅 Vim 设置
if !has('nvim')
  set pastetoggle=<F2>
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
  autocmd FileType text,markdown setlocal wrap linebreak nolist
augroup END

" ============================================================================
" 快捷键：Leader = 空格
" ============================================================================
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

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
endfunction
command! TrimTrailingWhitespace call s:TrimTrailingWhitespace()
nnoremap <leader>T :TrimTrailingWhitespace<CR>

function! s:FileInfo()
  echo 'Enc=' . &fileencoding . ' FF=' . &fileformat . ' FT=' . &filetype
endfunction
command! FileInfo call s:FileInfo()

" gVim 下 Ctrl-S 保存
if has('gui_running')
  nnoremap <C-s> :w<CR>
  inoremap <C-s> <Esc>:w<CR>a
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
