set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/macros/matchit.vim

if (has("win32") || has("win95") || has("win64") || has("win16"))
	let g:vimrc_iswindows=1
else
	let g:vimrc_iswindows=0
endif
if (g:vimrc_iswindows)
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set diffexpr=MyDiff()
	function MyDiff()
		let opt = '-a --binary '
		if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
		if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
		let arg1 = v:fname_in
		if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
		let arg2 = v:fname_new
		if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
		let arg3 = v:fname_out
		if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
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
		silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
		if exists('l:shxq_sav')
			let &shellxquote=l:shxq_sav
		endif
	endfunction
endif    "for windows only
"--------------------------------------------
" General setting
"--------------------------------------------
set nobackup
if exists('+undofile')
	set undofile
endif
set noundofile
set laststatus=2
set history=500
set ruler
set noshowmatch
set showcmd
set listchars=tab:>-,trail:-
"set list
if has("mouse")
	set mouse=nvi
endif
"set mouse=a
"set cursorline
"set cursorcolumn

" Fast saving & exit
nmap <leader>x  :x<cr>
nmap <leader>w  :w<cr>
nmap <leader>q  :q<cr>
nmap <leader>d  :bd<cr>
nmap <leader>n  :bn<cr>
"支持单行和多行的选择，//格式
map <c-h>  <leader>c<space>

if has("gui")
	nmap <S-CR> i<CR><ESC>
	imap <S-CR> <C-o>o
	imap <C-CR> <C-o>O
endif

" setting for quickhl
"nmap <Space>m <Plug>(quickhl-manual-this)
"xmap <Space>m <Plug>(quickhl-manual-this)
"nmap <Space>M <Plug>(quickhl-manual-reset)
"xmap <Space>M <Plug>(quickhl-manual-reset)

" setting for nerdtree
nmap <space>ft  :NERDTreeToggle<CR>
nmap <space>bd  :bd<CR>
nmap <space>bn  :bn<CR>
nmap <space>fs  :w<CR>
nmap <space>fed :e $MYVIMRC<CR>

"a shortcut for inserting datetime
iabbrev dts <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>

if exists('+macmeta')
	set macmeta
endif
set pastetoggle=<F2>

"---------------------------------------------
" Search setting
"---------------------------------------------
set ignorecase
set incsearch
set hlsearch
"---------------------------------------------
" Text formatting/layout
"---------------------------------------------
set autoindent
set smartindent
set fo=tcrqn            " see help (complex)
set tabstop=4           " tab spacing (settings below are just to unify it)
set softtabstop=4       " unify
set shiftwidth=4        " unify
set noexpandtab         " real tabs please!
set smarttab            " use tabs at the start of a line, spaces elsewhere
set formatoptions+=mM   " so that vim can reformat multibyte text (e.g. Chinese)

syntax on
filetype on             " enable file type detection
filetype plugin on      " enable loading the plugin for appropriate file type
filetype plugin indent on

"---------------------------------------------
" Folding
"---------------------------------------------
set foldenable          " turn on folding
set foldmethod=indent   " make folding indent sensitive
set foldlevel =100      " don't autofold anything (but can still fold manually)
set foldopen -=search   " don't open folds when you search into them
set foldopen -=undo     " don't open folds when you undo stuff

"-----------------------------------------------------------
set browsedir=buffer   " use directory of the related buffer for file browser
set clipboard+=unnamed " use clipboard register '*' for all y, d, c, p ops
set viminfo+=!         " make sure it can save viminfo
set isk+=$,%,#,-       " none of these should be word dividers
set confirm            " raise a dialog confirm whether to save changed buffer
set ffs=unix,dos,mac   " favor unix ff which behaves good under both Win & Linux
"set encoding=utf-8
"set fileencoding=chinese
"set fileencodings=ucs-bom,utf-8,chinese
set ambiwidth=double
map Q gq
" don't use Ex-mode, use Q for formatting

"------------------------------------------------------------
" Encoding settings
"------------------------------------------------------------
if has("multi_byte")
	" Set fileencoding priority
	"set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
	if getfsize(expand("%")) > 0
		set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
	else
		set fileencodings=utf-8,cp936,big5,euc-jp,euc-kr,latin1
	endif
	"" CJK environment detection and corresponding setting
	if v:lang =~ "^zh_CN"
		"" Use cp936 to support GBK, euc-cn == gb2312
		set encoding=cp936
		set termencoding=cp936
		set fileencoding=cp936
	elseif v:lang =~ "^zh_TW"
		"" cp950, big5 or euc-tw
		set encoding=big5
		set termencoding=big5
		set fileencoding=big5
	elseif v:lang =~ "^ko"
		set encoding=euc-kr
		set termencoding=euc-kr
		set fileencoding=euc-kr
	elseif v:lang =~ "^ja_JP"
		set encoding=euc-jp
		set termencoding=euc-jp
		set fileencoding=euc-jp
	else
		set encoding=utf-8
		set termencoding=utf-8
		set fileencoding=utf-8
	endif
	"" Detect UTF-8 locale, and replace CJK setting if needed
	if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
		set encoding=utf-8
		set termencoding=utf-8
		set fileencoding=utf-8
	endif
else
	echoerr "This Vim was not compiled with multi_byte"
endif

"进行Tlist的设置--taglist
"按下F3就可以呼出了
map <F3> :silent! Tlist<CR>
let Tlist_Ctags_Cmd='ctags'      "因为我们放在环境变量里，所以可以直接执行
let Tlist_Use_Right_Window=0     "让窗口显示在右边，0的话就是显示在左边
let Tlist_Show_One_File=0        "让taglist可以同时展示多个文件的函数列表，如果想只有1个，设置为1
let Tlist_File_Fold_Auto_Close=1 "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1      "当taglist是最后一个分割窗口时，自动退出vim
"是否一直处理tags.1:处理;0:不处理
let Tlist_Process_File_Always=0  "不是一直实时更新tags，因为没有必要
let Tlist_Inc_Winwidth=0

set nocompatible
filetype off
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"Plug 'VundleVim/Vundle.vim'

set rtp+=~/.vim/plugged/vim-plug
call plug#begin('~/.vim/plugged')
" let plug manage plug
Plug 'jidzhang/vim-plug'

" repos on github
Plug 'jiangmiao/auto-pairs'
"Plug 'hdima/python-syntax'
"Plug 'python-mode/python-mode'
"Plug 'Valloric/ListToggle'
"Plug 'Valloric/YouCompleteMe'

"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'

"Plug 'Lokaltog/vim-powerline'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 't9md/vim-quickhl'

"Plug 'vim-ruby/vim-ruby'
"Plug 'mattn/emmet-vim'

"super power motion:
"Plug 'easymotion/vim-easymotion'
"Plug 'haya14busa/incsearch.vim'
"Plug 'haya14busa/incsearch-easymotion.vim'
"Plug 'haya14busa/incsearch-fuzzy.vim'

"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-abolish'
"Plug 'tpope/vim-rails'
"Plug 'tpope/vim-sensible'
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"Plug 'tpope/vim-dispatch'
"Plug 'tpope/vim-repeat'
"Plug 'kana/vim-textobj-user'
"Plug 'kana/vim-textobj-lastpat'
"Plug 'kana/vim-textobj-line'
"Plug 'kana/vim-textobj-function'
"Plug 'nelstrom/vim-qargs'
"Plug 'mileszs/ack.vim'
"Plug 'w0rp/ale'
"Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'Shougo/neocomplete.vim'
"Plug 'Shougo/neosnippet-snippets'
"Plug 'Shougo/vimshell.vim'
"Plug 'Shougo/unite.vim'
"Plug 'Shougo/neco-vim'
"Plug 'c9s/perlomni.vim'
"Plug 'ternjs/tern_for_vim'

"if has('nvim')
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugs' }
"else
"Plug 'Shougo/deoplete.nvim'
"Plug 'roxma/nvim-yarp'
"Plug 'roxma/vim-hug-neovim-rpc'
"endif

"Plug 'terryma/vim-multiple-cursors'
"Plug 'terryma/vim-expand-region'
"Plug 'terryma/vim-smooth-scroll'

"Plug 'mhinz/vim-signify'
"Plug 'justinmk/vim-sneak'

"Plug 'Yggdroot/indentLine'
"Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
"Plug 'plasticboy/vim-markdown'
"Plug 'altercation/vim-colors-solarized'
Plug 'sickill/vim-monokai'
"Plug 'vimchina/vimcdoc'
"Plug 'vimchina/vim-fencview'

"Plug 'vim-scripts/taglist.vim'
"Plug 'vim-scripts/a.vim'
"Plug 'vim-scripts/molokai'

"Plug 'vim-scripts/L9'
"Plug 'vim-scripts/FuzzyFinder'
"Plug 'vim-scripts/AutoComplPop'

" non github repos
"Plug 'git://git.wincent.com/command-t.git'
" repos on local machine
"Plug 'file:///User/XX/path/to/plugin'

"call vundle#end()
call plug#end()
filetype plugin indent on

""=====================================
"" Setting for NeoComplete
""Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
"" Disable AutoComplPop.
"let g:acp_enableAtStartup = 0
"" Use neocomplete.
"let g:neocomplete#enable_at_startup = 1
"" Use smartcase.
"let g:neocomplete#enable_smart_case = 1
"" Set minimum syntax keyword length.
"let g:neocomplete#sources#syntax#min_keyword_length = 3
"
"" Define dictionary.
"let g:neocomplete#sources#dictionary#dictionaries = {
"			\ 'default' : '',
"			\ 'vimshell' : $HOME.'/.vimshell_hist',
"			\ 'scheme' : $HOME.'/.gosh_completions'
"			\ }
"
"" Define keyword.
"if !exists('g:neocomplete#keyword_patterns')
"	let g:neocomplete#keyword_patterns = {}
"endif
"let g:neocomplete#keyword_patterns['default'] = '\h\w*'
"
"" Plug key-mappings.
"inoremap <expr><C-g>     neocomplete#undo_completion()
"inoremap <expr><C-l>     neocomplete#complete_common_string()
"
"" Recommended key-mappings.
"" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function()
"	return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
"	" For no inserting <CR> key.
"	"return pumvisible() ? "\<C-y>" : "\<CR>"
"endfunction
"" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"" Close popup by <Space>.
""inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
"
"" AutoComplPop like behavior.
""let g:neocomplete#enable_auto_select = 1
"
"" Shell like behavior(not recommended).
""set completeopt+=longest
""let g:neocomplete#enable_auto_select = 1
""let g:neocomplete#disable_auto_complete = 1
""inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
"
"" Enable omni completion.
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"
"" Enable heavy omni completion.
"if !exists('g:neocomplete#sources#omni#input_patterns')
"	let g:neocomplete#sources#omni#input_patterns = {}
"endif
""let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
""let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
""let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
"
"" For perlomni.vim setting.
"" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"===========================
set t_Co=256
set laststatus=2

"let g:deoplete#enable_at_startup = 1

"let g:fencview_autodetect=0
"let g:fencview_auto_patterns='*.txt,*.md,*.htm{l\=},*.c,*.cpp,*.py,*.php'
"let g:vim_markdown_folding_disabled=1

"---------------------------------------------
" Gui-font
"--------------------------------------------
if  has('gui_running')
	set background=light
else
	set background=dark
endif
set wrap
if has("gui")
	"colo evening
	"colo molokai
	set lines=25 columns=80
	set guioptions=
	set guioptions+=m
	"set guioptions -=T
	"set guioptions -=r
	"set guioptions +=b
	"set guifont=courier_new:h10
	if (g:vimrc_iswindows)
		set guifont=Monaco:h10
	else
		set guifont=Monaco:h12
	endif
	"set background=light
	"let g:solarized_italic=0
	"colo solarized
else
	"colo blue
	"colo default
	"colo molokai
endif
"colo evening
colo monokai

" filetype indentation
if has("autocmd")
	filetype on
	autocmd FileType ruby setlocal ts=2 sts=2 sw=2 et
	autocmd FileType lisp setlocal ts=2 sts=2 sw=2 et
	autocmd FileType python setlocal ts=4 sts=4 sw=4 et
	autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noet
	autocmd FileType html setlocal ts=4 sts=4 sw=4 et
	autocmd FileType css setlocal iskeyword+=-
endif

" Tabularize mappings
nmap <Leader>a=		:Tabularize /=<CR>
nmap <Leader>a:		:Tabularize /:<CR>
nmap <Leader>a::	:Tabularize /:\zs<CR>
nmap <Leader>a,		:Tabularize /,<CR>
nmap <Leader>a<Bar> :Tabularize /<CR>

"" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

"" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"


"let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
"let g:ycm_python_binary_path='python'
""let g:ycm_key_list_select_completion=[]
""let g:ycm_key_list_previous_completion=[]
"let g:ycm_error_symbol = '>>'
"let g:ycm_warning_symbol = '>*'
"nnoremap <space>gl :YcmCompleter GoToDeclaration<CR>
"nnoremap <space>gf :YcmCompleter GoToDefinition<CR>
"nnoremap <space>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
"nmap <F4> :YcmDiags<CR>
""是否开启语义补全"
"let g:ycm_seed_identifiers_with_syntax=1
""是否在注释中也开启补全"
"let g:ycm_complete_in_comments=1
"let g:ycm_collect_identifiers_from_comments_and_strings = 0
""开始补全的字符数"
"let g:ycm_min_num_of_chars_for_completion=1
""补全后自动关机预览窗口"
"let g:ycm_autoclose_preview_window_after_completion=1
"" 禁止缓存匹配项,每次都重新生成匹配项"
"let g:ycm_cache_omnifunc=0
""字符串中也开启补全"
"let g:ycm_complete_in_strings = 1
""离开插入模式后自动关闭预览窗口"
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif
""上下左右键行为"
"inoremap <expr> <Down>     pumvisible() ? '\<C-n>' : '\<Down>'
"inoremap <expr> <Up>       pumvisible() ? '\<C-p>' : '\<Up>'
"inoremap <expr> <PageDown> pumvisible() ? '\<PageDown>\<C-p>\<C-n>' : '\<PageDown>'
"inoremap <expr> <PageUp>   pumvisible() ? '\<PageUp>\<C-p>\<C-n>' : '\<PageUp>'


"=========================================================
" setting for easymotion
" <Leader>f{char} to move to {char}
"map  <space>f <Plug>(easymotion-bd-f)
"nmap <space>f <Plug>(easymotion-overwin-f)
"" s{char}{char} to move to {char}{char}
"nmap s <Plug>(easymotion-overwin-f2)
"" Move to line
"map  <space>l <Plug>(easymotion-bd-jk)
"nmap <space>l <Plug>(easymotion-overwin-line)
"" Move to word
"map  <space>w <Plug>(easymotion-bd-w)
"nmap <space>w <Plug>(easymotion-overwin-w)
"" JK motions: Line motions
"map <Leader>j <Plug>(easymotion-j)
"map <Leader>k <Plug>(easymotion-k)
"
"" Require tpope/vim-repeat to enable dot repeat support
"" Jump to anywhere with only `s{char}{target}`
"" `s<CR>` repeat last find motion.
"nmap s <Plug>(easymotion-s)
"" Bidirectional & within line 't' motion
"omap t <Plug>(easymotion-bd-tl)
"" Use uppercase target labels and type as a lower case
"let g:EasyMotion_use_upper = 1
"" type `l` and match `l`&`L`
"let g:EasyMotion_smartcase = 1
"" Smartsign (type `3` and match `3`&`#`)
"let g:EasyMotion_use_smartsign_us = 1
"
"" You can use other keymappings like <C-l> instead of <CR> if you want to
"" use these mappings as default search and somtimes want to move cursor with
"" EasyMotion.
"function! s:incsearch_config(...) abort
"	return incsearch#util#deepextend(deepcopy({
"				\   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
"				\   'keymap': {
"				\     "\<CR>": '<Over>(easymotion)'
"				\   },
"				\   'is_expr': 0
"				\ }), get(a:, 1, {}))
"endfunction
"noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
"noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
"noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
"
""":h g:incsearch#auto_nohlsearch
"set hlsearch
"let g:incsearch#auto_nohlsearch = 1
"map n  <Plug>(incsearch-nohl-n)
"map N  <Plug>(incsearch-nohl-N)
"map *  <Plug>(incsearch-nohl-*)
"map #  <Plug>(incsearch-nohl-#)
"map g* <Plug>(incsearch-nohl-g*)
"map g# <Plug>(incsearch-nohl-g#)
"
"map z/ <Plug>(incsearch-easymotion-/)
"map z? <Plug>(incsearch-easymotion-?)
"map zg/ <Plug>(incsearch-easymotion-stay)
"
"" incsearch.vim x fuzzy x vim-easymotion
"function! s:config_easyfuzzymotion(...) abort
"	return extend(copy({
"				\   'converters': [incsearch#config#fuzzyword#converter()],
"				\   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
"				\   'keymap': {"\<CR>": '<Over>(easymotion)'},
"				\   'is_expr': 0,
"				\   'is_stay': 1
"				\ }), get(a:, 1, {}))
"endfunction
"noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
"" setting for easymotion end
""=========================================================
