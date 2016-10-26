set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/macros/matchit.vim

if(has("win32") || has("win95") || has("win64") || has("win16"))
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
set laststatus=2
set history=1000
set ruler
set noshowmatch
set showcmd
set listchars=tab:>-,trail:-
"set list
if has("mouse")
    set mouse=nvi
endif
"set mouse=a

" Fast saving
nmap <leader>x  :x<cr>
nmap <leader>w  :w<cr>
nmap <leader>q  :q<cr>
nmap <leader>d  :bd<cr>
nmap <leader>n  :bn<cr>
"支持单行和多行的选择，//格式
map <c-h>  <leader>c<space>
if (g:vimrc_iswindows)
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
nmap <space>ft :NERDTreeToggle<cr>
nmap <space>bd :bd<cr>
nmap <space>bn :bn<cr>
nmap <space>fs :w<cr>
nmap <space>fed :e $MYVIMRC<cr>

"a shortcut for inserting datetime
"iabbrev dts <C-R>=strftime("%H:%M %m/%d/%Y")<CR>
iabbrev dts <C-R>=strftime("%Y-%m-%d %H:%M")<CR>

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

if exists('+macmeta')
    set macmeta
endif
set pastetoggle=<F2>

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
    endif
    "" Detect UTF-8 locale, and replace CJK setting if needed
    if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
        set encoding=utf-8
        set termencoding=utf-8
        set fileencoding=utf-8
    endif
else
    echoerr "Sorry, this version of Vim was not compiled with multi_byte"
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
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage vundle
Plugin 'VundleVim/Vundle.vim'

" Very great plugins
" original repos on github
Plugin 'jiangmiao/auto-pairs'
"Plugin 'klen/python-mode'
"Plugin 'hdima/python-syntax'
"Plugin 'Valloric/ListToggle'
"Plugin 'Valloric/YouCompleteMe'

"Plugin 'Lokaltog/vim-powerline'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

"super power motion:
Plugin 'easymotion/vim-easymotion'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-easymotion.vim'
Plugin 'haya14busa/incsearch-fuzzy.vim'

"Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
Plugin 'vim-ruby/vim-ruby'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-fireplace'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-lastpat'
Plugin 'kana/vim-textobj-line'
Plugin 'kana/vim-textobj-function'
Plugin 'nelstrom/vim-qargs'
"Plugin 'mileszs/ack.vim'
"Plugin 't9md/vim-quickhl'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'Shougo/neocomplete.vim'
Plugin 'Shougo/neosnippet-snippets'
Plugin 'Shougo/vimshell.vim'
Plugin 'Shougo/unite.vim'
Plugin 'c9s/perlomni.vim'
Plugin 'ternjs/tern_for_vim'

Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'altercation/vim-colors-solarized'
"Plugin 'chrisbra/vim_faq'
Plugin 'vimchina/vimcdoc'
"Plugin 'vimchina/vim-fencview'
"html & css & javascript
"Plugin 'wookiehangover/jshint.vim'
"Plugin 'joestelmach/lint.vim'

" vim-scripts repos
Plugin 'taglist.vim'
Plugin 'a.vim'
Plugin 'molokai'

"Plugin 'L9'
"Plugin 'FuzzyFinder'
"Plugin 'AutoComplPop'

" non github repos
"Plugin 'git://git.wincent.com/command-t.git'
" repos on local machine
"Plugin 'file:///User/XX/path/to/plugin'

call vundle#end()
filetype plugin indent on

"=====================================
" Setting for NeoComplete

"Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default' : '',
            \ 'vimshell' : $HOME.'/.vimshell_hist',
            \ 'scheme' : $HOME.'/.gosh_completions'
            \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"===========================
set t_Co=256
set laststatus=2

"let g:fencview_autodetect=0
"let g:fencview_auto_patterns='*.txt,*.md,*.htm{l\=},*.c,*.cpp,*.py,*.php'
"let g:vim_markdown_folding_disabled=1

"---------------------------------------------
" Gui-font
"--------------------------------------------
set wrap
if has("gui")
    "colo molokai
    "colo evening
    set lines=25 columns=80
    set guioptions=
    set guioptions+=m
    "set guioptions -=T
    "set guioptions -=r
    "set guioptions +=b
    "set guifont=courier_new:h10
    "set guifont=Monaco:h10
    set background=light
    let g:solarized_italic=0
    colo solarized
else
    "colo default
    "colo blue
    "colo evening
    colo molokai
endif

" filetype indentation
if has("autocmd")
    filetype on
    autocmd FileType ruby setlocal ts=2 sts=2 sw=2 et
    autocmd FileType lisp setlocal ts=2 sts=2 sw=2 et
    autocmd FileType python setlocal ts=4 sts=4 sw=4 et
    autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noet
    autocmd FileType html	setlocal ts=4 sts=4 sw=4 et
    autocmd FileType css	setlocal iskeyword+=-
endif

" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsListSnippets="<c-tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

"let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"
""let g:ycm_key_list_select_completion=[]
""let g:ycm_key_list_previous_completion=[]
"let g:ycm_error_symbol = '>>'
"let g:ycm_warning_symbol = '>*'
"nnoremap <space>gl :YcmCompleter GoToDeclaration<CR>
"nnoremap <space>gf :YcmCompleter GoToDefinition<CR>
"nnoremap <space>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
"nmap <F4> :YcmDiags<CR>

""================================
" setting form easymotion
" <Leader>f{char} to move to {char}
map  <space>f <Plug>(easymotion-bd-f)
nmap <space>f <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)
" Move to line
map  <space>l <Plug>(easymotion-bd-jk)
nmap <space>l <Plug>(easymotion-overwin-line)
" Move to word
map  <space>w <Plug>(easymotion-bd-w)
nmap <space>w <Plug>(easymotion-overwin-w)

" You can use other keymappings like <C-l> instead of <CR> if you want to
" use these mappings as default search and somtimes want to move cursor with
" EasyMotion.
function! s:incsearch_config(...) abort
    return incsearch#util#deepextend(deepcopy({
                \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
                \   'keymap': {
                \     "\<CR>": '<Over>(easymotion)'
                \   },
                \   'is_expr': 0
                \ }), get(a:, 1, {}))
endfunction

noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))

function! s:config_easyfuzzymotion(...) abort
    return extend(copy({
                \   'converters': [incsearch#config#fuzzyword#converter()],
                \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
                \   'keymap': {"\<CR>": '<Over>(easymotion)'},
                \   'is_expr': 0,
                \   'is_stay': 1
                \ }), get(a:, 1, {}))
endfunction

noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
