nmap <Space>feR :so ~/.vimrc<CR>
nmap <Space>fed :e ~/.vimrc<CR>
nmap <Space>fs :w<CR>
nmap <Space>; A;<Esc>

" 启用行号
set number
colorscheme evening

" 高亮当前行
"set cursorline

" 设置 Leader 键（支持 \ 和 Space 双重触发）
let mapleader = '\'
nmap <Space> <Leader>

set showcmd
set ignorecase
set incsearch
set hlsearch
set smartcase
"set clipboard=unnamed

" 重新定义ESC
inoremap jj <Esc>
"inoremap jk <Esc>
" 快速添加新的空行
imap <S-CR> <ESC>o
imap <C-CR> <ESC>O

" 优化移动
"nnoremap <C-d> <C-d>zz  " 向下翻页并居中光标

" 快速调用 VS 功能
"nnoremap gd :vsc Edit.GoToDefinition<CR>
"nnoremap <leader>d :vsc Edit.GoToDefinition<CR>
"nnoremap <leader>f :vsc Edit.FindInFiles<CR>

" 保留 VS 的 Ctrl+/ 注释
"inoremap <C-/> <C-X><C-O>

" 使用 VS 的智能补全（Ctrl+Space）
"inoremap <C-Space> <C-X><C-O>

"source $VIM/_vimrc

" Vim with all enhancements
if !has("nvim")
	source $VIMRUNTIME/vimrc_example.vim
endif

" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
	set diffexpr=MyDiff()
endif
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

" ============================================
" Windows gVim 优化配置
" 版本要求: Vim 8.1+ / gVim
" 编码: UTF-8 with BOM (Windows中文环境)
" ============================================

" ============================================
" 1. 基础行为与兼容性
" ============================================
set nocompatible
set hidden                    " 允许隐藏未保存的buffer
set history=1000
set updatetime=300
set mouse=a                   " 启用鼠标支持（Windows终端也适用）
set clipboard=unnamed         " 默认使用系统剪贴板

" Windows 路径分隔符优化
set shellslash                " 使用正斜杠作为路径分隔符（方便复制路径）

" 恢复上一次编辑位置（如果有的话）
augroup last_position
	autocmd!
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" ============================================
" 2. Windows 中文环境编码设置（关键）
" ============================================
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gb18030,gbk,gb2312,cp936,ucs-bom,default,latin1
set ambiwidth=double          " 正确处理中日韩宽字符
set fileformats=unix,dos      " 自动识别换行符

" 解决菜单乱码（gVim）
if has('gui_running') && has('win32')
	source $VIMRUNTIME/delmenu.vim
	set langmenu=zh_CN.UTF-8
	source $VIMRUNTIME/menu.vim
endif

" ============================================
" 3. 显示与界面（GUI & Terminal）
" ============================================
syntax on
filetype plugin indent on

" 行号与状态栏
set number
set norelativenumber            " 相对行号（方便跳转）
set laststatus=2
set statusline=%F%m%r%h%w\ [F=%Y]\ [L=%l/%L,C=%c]\ [P=%P]\ %{&fenc!=''?&fenc:&enc}

" 滚动与显示优化
set scrolloff=5               " 光标上下保持5行间距
set showcmd                   " 右下角显示操作
set showmode                  " 显示当前模式
set wildmenu                  " 命令行补全增强
set wildignore=*.o,*.obj,*.pyc,*.class,*.swp,*.bak,*.exe,*.dll

" 特殊字符可视化（按 <Leader>L 切换）
set listchars=tab:>-,trail:$,extends:>,precedes:<,nbsp:␣
set nolist

" 配色方案
set background=dark
"colorscheme desert

" gVim 专属设置
if has('gui_running')
	" 字体设置（JetBrains Mono NL，需提前安装）
	set guifont=JetBrains_Mono_NL:h11:cANSI:qDRAFT

	" 界面元素控制
	set guioptions+=m           " 保留菜单栏（Windows习惯）
	set guioptions-=T           " 隐藏工具栏（节省空间）
	set guioptions-=r           " 隐藏右侧滚动条
	set guioptions-=L           " 隐藏左侧滚动条

	" 窗口默认大小
	set lines=40 columns=120

" Windows 终端光标样式（非GUI）
elseif has('win32') && !has('gui_running')
	set t_Co=256
	let &t_SI = "\<Esc>[6 q"    " 插入模式：竖线
	let &t_EI = "\<Esc>[2 q"    " 普通模式：方块
	let &t_SR = "\<Esc>[4 q"    " 替换模式：下划线
	let &t_ti .= "\<Esc>[2 q"   " vim启动时Normal模式设为方块
	let &t_te .= "\<Esc>[6 q"   " 退出vim时恢复终端竖线光标
endif

" ============================================
" 4. 编辑行为与缩进（默认4空格）
" ============================================
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab               " 默认使用空格代替Tab
set autoindent
set smartindent
set cindent                   " C风格缩进（对编程友好）
set backspace=indent,eol,start " 退格键跨行

" 自动切换不同文件的缩进规则
augroup filetype_specific
	autocmd!
	" Nginx/前端 2空格缩进
	autocmd BufRead,BufNewFile */nginx/*,*.nginx,*nginx.conf,*.html,*.css,*.js,*.json,*.yaml,*.yml 
				\ setlocal tabstop=2 shiftwidth=2 softtabstop=2
	" Makefile 保持Tab
	autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
	" Python 4空格（默认即可，显式声明）
	autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
	" 文本文件自动换行
	autocmd FileType text,markdown setlocal wrap linebreak nolist
augroup END

" ============================================
" 5. Windows 快捷键适配（核心优化）
" ============================================
" 说明: 在 gVim 中，Ctrl+C/S/V 不会与系统冲突，可安全映射

" --------------- 插入模式 Windows 习惯 ---------------
" Ctrl+V 粘贴系统剪贴板
inoremap <C-v> <C-r>+

" Ctrl+C 复制当前行（类似Windows编辑器的行为）
" 注意：这会覆盖 Vim 的"终止操作"，但在gVim中很少需要
inoremap <C-c> <Esc>yygi

" Ctrl+X 剪切当前行
inoremap <C-x> <Esc>ddgi

" Ctrl+Z 撤销（插入模式也可用）
inoremap <C-z> <C-o>u

" Ctrl+Y 重做（反撤销）
inoremap <C-y> <C-o><C-r>

" Ctrl+A 全选（插入模式）
inoremap <C-a> <Esc>ggVG

" Ctrl+S 保存（Windows最常用）
inoremap <C-s> <Esc>:w<CR>a
nnoremap <C-s> :w<CR>

" Ctrl+F 查找（插入模式进入搜索）
inoremap <C-f> <Esc>/

" --------------- 可视模式 Windows 习惯 ---------------
" 可视模式下 Ctrl+C 复制到系统剪贴板（Windows思维惯性）
vnoremap <C-c> "+y

" 可视模式下 Ctrl+X 剪切
vnoremap <C-x> "+d

" 保留 Ctrl+V 作为块选择（Vim 强大功能），
" 如需在可视模式粘贴，使用 Shift+Insert 或改按 <Leader>v

" --------------- 普通模式 Windows 兼容 ---------------
" Ctrl+A 全选
nnoremap <C-a> ggVG

" Ctrl+C 在普通模式复制当前行到系统剪贴板
nnoremap <C-c> "+yy

" Ctrl+Insert / Shift+Insert 系统剪贴板（传统Windows习惯）
map <C-Insert> "+y
imap <S-Insert> <C-r>+
cmap <S-Insert> <C-r>+

" ============================================
" 6. 搜索优化（智能高亮）
" ============================================
set hlsearch
set incsearch                 " 实时搜索
set ignorecase
set smartcase                 " 有大写字母时切换为大小写敏感
set wrapscan                  " 搜索到文件末尾后从头开始

" 按 <Leader>/ 取消高亮
nnoremap <Leader>/ :noh<CR>

" ============================================
" 7. 文件管理与持久化
" ============================================
" 禁用交换文件和备份（Windows下容易残留）
set nobackup
set nowritebackup
set noswapfile

" 持久化撤销（Undo），Vim 8+ 支持
if has('persistent_undo')
	set undofile
	set undolevels=1000
	set undoreload=10000

	" Windows 撤销目录设置
	if has('win32')
		set undodir=~/vimfiles/undo//
		" 自动创建目录
		if !isdirectory(expand('~/vimfiles/undo'))
			silent! call mkdir(expand('~/vimfiles/undo'), 'p')
		endif
	else
		set undodir=~/.vim/undo//
		if !isdirectory(expand('~/.vim/undo'))
			silent! call mkdir(expand('~/.vim/undo'), 'p')
		endif
	endif
endif

" ============================================
" 8. Leader 快捷键
" ============================================

" 快速保存退出
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>x :x<CR>          " 保存并退出
nnoremap <Leader>Q :q!<CR>         " 强制退出

" 窗口导航（保留 hjkl 风格）
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>v :vsplit<CR>     " 垂直分割
nnoremap <Leader>s :split<CR>      " 水平分割
nnoremap <Leader>c <C-w>c         " 关闭窗口
nnoremap <Leader>o <C-w>o         " 只保留当前窗口
nnoremap <Leader>= <C-w>=         " 均分窗口

" Buffer 切换
nnoremap <Leader>n :bn<CR>         " 下一个buffer
nnoremap <Leader>p :bp<CR>         " 上一个buffer
nnoremap <Leader>d :bd<CR>         " 删除buffer

" 文件浏览（内置）
nnoremap <Leader>e :Explore<CR>
nnoremap <Leader>E :Sexplore<CR>   " 水平分割浏览

" 显示切换
nnoremap <Leader>L :set list!<CR>:set list?<CR>

" 强制写入（sudo 替代，Windows 用 PowerShell 方法）
if has('win32')
	cnoremap w!! w !powershell -Command "Set-Content -Path '%' -Value (Get-Content -Raw)"
endif

" ============================================
" 9. 实用工具函数
" ============================================

" 删除行尾空格（<Leader>T）
function! TrimTrailingWhitespace()
	let l:save = winsaveview()
	keeppatterns %s/\s\+$//e
	call winrestview(l:save)
	echo "已删除行尾空格"
endfunction
command! TrimTrailingWhitespace call TrimTrailingWhitespace()
nnoremap <Leader>T :TrimTrailingWhitespace<CR>

" 压缩连续空行（<Leader>B）
function! ReduceBlankLines()
	let l:save = winsaveview()
	keeppatterns %s/\(\n\s*\)\{3,}/\r\r/e
	call winrestview(l:save)
	echo "已压缩空行"
endfunction
command! ReduceBlankLines call ReduceBlankLines()
nnoremap <Leader>B :ReduceBlankLines<CR>

" 显示当前文件编码和换行符
function! ShowFileInfo()
	echo "编码: " . &fileencoding . " | 换行: " . &fileformat . " | 类型: " . &filetype
endfunction
command! FileInfo call ShowFileInfo()

" ============================================
" 10. 终端光标样式（跨平台，适用于所有终端 vim）
" ============================================
if !has('gui_running') && &term =~# 'xterm\|screen\|tmux'
	let &t_SI = "\e[6 q"    " 插入模式：竖线
	let &t_EI = "\e[2 q"    " 普通模式：方块
	let &t_SR = "\e[4 q"    " 替换模式：下划线
	let &t_ti .= "\e[2 q"   " vim启动时Normal模式设为方块
	let &t_te .= "\e[6 q"   " 退出vim时恢复终端竖线光标
endif
