""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"        _   _       _                  _____             __ _               "
"       | \ | |     (_)                / ____|           / _(_)              "
"       |  \| |_   ___ _ __ ___       | |     ___  _ __ | |_ _  __ _         "
"       | . ` \ \ / / | '_ ` _ \      | |    / _ \| '_ \|  _| |/ _` |        "
"       | |\  |\ V /| | | | | | |     | |___| (_) | | | | | | | (_| |        "
"       |_| \_| \_/ |_|_| |_| |_|      \_____\___/|_| |_|_| |_|\__, |        "
"                                                               __/ |        "
"                                                              |___/         "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"{ Header and Licence
"{{ header info
" Description: This is my Nvim configuration which supports Mac, Linux and
" Windows, with various plugins configured. This configuration evolves as I
" learn more about Nvim and becomes more proficient in using Nvim. Since this
" configuration file is very long (more than 1000 lines!), you should read it
" carefully and only take the settings and options which suits you.  I would
" not recommend downloading this file and replace your own init.vim. Good
" configurations are built over time and take your time to polish.
" Author: jdhao (jdhao@hotmail.com). Blog: https://jdhao.github.io
" Update: 2019-05-11 19:46:55+0800
"}}

"{{ License: MIT License
"
" Copyright (c) 2018 Jie-dong Hao
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.
"}}
"}

"{ Variable
"{{ builtin variables
" path to Python 3 interpreter (must be an absolute path), make startup
" faster.  see https://neovim.io/doc/user/provider.html. Change this variable
" in accordance with your system.
if executable('python')
    if has('win32') " for Windows
        " the output of `system()` function contains a newline character which
        " should be removed
        let g:python3_host_prog=substitute(system('where python'), '.exe\n\+$', '', 'g')
    elseif has('unix') " for Linux and Mac
        let g:python3_host_prog=substitute(system('which python'), '\n\+$', '', 'g')
    endif
else
    echoerr 'Python executable is not found, either you have not installed Python
        \ or you have not set the Python executable path correctly'
endif

" set custom mapping <leader> (use `:h mapleader` for more info)
let mapleader = ','
"}}

"{{ disable loading certain plugin
" do not load netrw by default since I do not use it, see
" https://github.com/bling/dotvim/issues/4
let g:loaded_netrwPlugin = 1

" do not load tohtml.vim
let g:loaded_2html_plugin = 1

" do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
" related to compressed files)
let g:loaded_zipPlugin = 1
let loaded_gzip = 1
let g:loaded_tarPlugin = 1

" do not use builtin matchit.vim and matchparen.vim
let loaded_matchit = 1
let g:loaded_matchparen = 1
"}}
"}

"{ Custom functions
" remove trailing white space, see https://goo.gl/sUjgFi
function! s:StripTrailingWhitespaces() abort
   let l:save = winsaveview()
    " vint: next-line -ProhibitCommandRelyOnUser -ProhibitCommandWithUnintendedSideEffect
   keeppatterns %s/\s\+$//e
   call winrestview(l:save)
endfunction

" create command alias safely, see https://bit.ly/2ImFOpL
" the following two functions are taken from answer below on SO
" https://stackoverflow.com/a/10708687/6064933
function! Cabbrev(key, value) abort
  execute printf('cabbrev <expr> %s (getcmdtype() == ":" && getcmdpos() <= %d) ? %s : %s',
    \ a:key, 1+len(a:key), Single_quote(a:value), Single_quote(a:key))
endfunction

function! Single_quote(str) abort
  return "'" . substitute(copy(a:str), "'", "''", 'g') . "'"
endfunction

" check the syntax group in the current cursor position,
" see http://tinyurl.com/yyzgswxz and http://tinyurl.com/y3lxozey
function! s:SynGroup() abort
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
nnoremap <silent> <leader>st :call <SID>SynGroup()<CR>

" the following two functions are from
" https://stackoverflow.com/a/5703164/6064933 (with adaptation)
" check if a colorscheme exists in runtimepath
function! HasColorscheme(name) abort
    let l:pat = 'colors/'.a:name.'.vim'
    return !empty(globpath(&runtimepath, l:pat))
endfunction

" check if an Airline theme exists in runtimepath
function! HasAirlinetheme(name) abort
    let l:pat = 'autoload/airline/themes/'.a:name.'.vim'
    return !empty(globpath(&runtimepath, l:pat))
endfunction

" generate random integer in the range [Low, High] in pure vimscrpt,
" adapted from http://tinyurl.com/y2o6rj3o
function! RandInt(Low, High) abort
    let l:milisec = str2nr(matchstr(reltimestr(reltime()), '\v\.\zs\d+'))
    return l:milisec % (a:High - a:Low + 1) + a:Low
endfunction

" custom fold expr, adapted from https://vi.stackexchange.com/a/9094/15292
function! VimFolds(lnum)
    let l:cur_line = getline(a:lnum)
    let l:next_line = getline(a:lnum+1)

    if l:cur_line =~# '^"{'
        return '>' . (matchend(l:cur_line, '"{*')-1)
    else
        if l:cur_line ==# '' && (matchend(l:next_line, '"{*')-1) == 1
            return 0
        else
            return '='
        endif
    endif
endfunction

" custom fold text, adapted from https://vi.stackexchange.com/a/3818/15292
" and https://vi.stackexchange.com/a/6608/15292
function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &foldcolumn + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let chunks = split(line, "\t", 1)
    let line = join(map(chunks[:-2], 'v:val . repeat(" ", &tabstop - strwidth(v:val) % &tabstop)'), '') . chunks[-1]

    let line = strpart(line, 0, windowwidth - 2 - len(foldedlinecount))
    " let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 80
    let fillcharcount = &textwidth - len(line) - len(foldedlinecount) - 8
    let l_fillcount = fillcharcount/2
    let r_fillcount = fillcharcount - l_fillcount
    return line . '...'. repeat('-', l_fillcount) . ' (' . foldedlinecount . ' L) ' . repeat('-', r_fillcount)
endfunction
"}

"{ Builtin options and settings
" changing fillchars for folding, so there is no garbage charactes
set fillchars=fold:\ ,vert:\|

" paste mode toggle, it seems that neovim's bracketed paste mode
" does not work very well for nvim-qt, so we use good-old paste mode
set pastetoggle=<F12>

" split window below/right when creating horizontal/vertical windows
set splitbelow splitright

" Time in milliseconds to wait for a mapped sequence to complete
" see https://goo.gl/vHvyu8 for more info
set timeoutlen=800
set updatetime=1000

" clipboard settings, always use clipboard for all delete, yank, change, put
" operation, see https://goo.gl/YAHBbJ
set clipboard+=unnamedplus

set noswapfile  " disable creating swapfiles, see https://goo.gl/FA6m6h

" general tab settings
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces to use for autoindent
set expandtab       " expand tab to spaces so that tabs are spaces

set showmatch             " highlight matching bracket
set matchpairs+=<:>,「:」 " matching pairs of characters

" show line number and relative line number
set number relativenumber

" ignore case in general, but become case-sensitive when uppercase present
set ignorecase smartcase

" encoding settings for vim
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
scriptencoding utf-8  " set the script encoding (`:h :scriptencoding`)

" line will break at predefined characters
set linebreak
" character to show before the lines that have been soft-wrapped
set showbreak=↪

" list all items and start selecting matches
set wildmode=list:longest,full

set cursorline      " whether to show the line cursor is in
set colorcolumn=80  " set a ruler at column 80, see https://goo.gl/vEkF5i
set signcolumn=yes  " always show sign column

set scrolloff=5  " minimum lines to keep above and below cursor

" use mouse to select window and resizing window, etc
if has('mouse')
    set mouse=a  " enable mouse in several mode
    set mousemodel=popup  " set the behaviour of mouse
endif

" do not show mode on command line since vim-airline can show it
set noshowmode

set fileformats=unix,dos  " fileformats to use for new file

set concealcursor=c  " the mode in which cursorline text can be concealed

" the way to show the result of substitution in real time for preview
set inccommand=nosplit

" ignore files or folders when globbing
set wildignore+=*.o,*.obj,*.bin,*.dll,*.exe
set wildignore+=*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**
set wildignore+=*.jpg,*.png,*.jpeg,*.gif,*.bmp,*.tiff
set wildignore+=*.pyc
set wildignore+=*.DS_Store
set wildignore+=*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz,*.pdf

" Ask for confirmation when handling unsaved or read-only files
set confirm

" use visual bells to indicate errors, do not use errorbells
set visualbell noerrorbells

set foldlevel=0  " the level we start to fold

set history=500  " the number of command and search history to keep

" use list mode and customized listchars
set list listchars=tab:▸\ ,extends:❯,precedes:❮,nbsp:+  ",trail:·,eol:¬

set autowrite  " auto write the file based on some condition

" show hostname, full path of file and lastmod time on the window title.
" The meaning of the format str for strftime can be found in
" http://tinyurl.com/l9nuj4a. The function to get lastmod time is drawn from
" http://tinyurl.com/yxd23vo8
set title
set titlestring=%{hostname()}\ \ %F\ \ \ %{strftime('%Y-%m-%d\ %H:%M',getftime(expand('%')))}

set undofile  " persistent undo even after you close and file and reopen it

" do not show "match xx of xx" and other messages during auto-completion
set shortmess+=c

set completeopt+=noinsert  " auto select the first completion entry
set completeopt+=menuone   " show menu even if there is only one item
set completeopt-=preview   " disable the preview window, see also https://goo.gl/18zNPD

" settings for popup menu
set pumheight=15  " maximum number of items to show in popup menu
set pumblend=10  " pesudo-blend effect for popup menu

" scan files given by `dictionary` option
set complete+=k,kspell complete-=w complete-=b complete-=u complete-=t

set showtabline=2  " whether to show tabline to see currently opened files

" align indent to next multiple value of shiftwidth, for its meaning,
" see http://tinyurl.com/y5n87a6m
set shiftround

set virtualedit=block  " virtual edit is useful for visual block edit

" correctly break multi-byte characters such as CJK,
" see http://tinyurl.com/y4sq6vf3
set formatoptions+=mM

" dictionary files for different systems
let $MY_DICT = stdpath('config') . '/dict/words'
set dictionary+=$MY_DICT
set spelllang=en,cjk  " spell languages

" tilde ~ is an operator (thus must be followed by motion like `c` or `d`)
set tildeop

" set pyx version to use python3 by default
set pyxversion=3
"}

"{ Custom key mappings
" save key strokes (now we do not need to press shift to enter command mode)
" vim-sneak has also mapped ;, so using the below mapping will break the map
" used by vim-sneak
nnoremap ; :

" quick way to open command window
nnoremap q; q:

" quicker <Esc> in insert mode, you must pick a rarely used character
" combination
inoremap <silent> jk <Esc>

" paste non-linewise text above or below current cursor,
" see https://stackoverflow.com/a/1346777/6064933
nnoremap <leader>p m`o<ESC>p``
nnoremap <leader>P m`O<ESC>p``

" shortcut for faster save and quit
nnoremap <silent> <leader>w :update<CR>
" saves the file if modified and quit
nnoremap <silent> <leader>q :x<CR>
" quit all opened buffers
nnoremap <silent> <leader>Q :qa<CR>

" navigation in the location and quickfix list
nnoremap [l :lprevious<CR>zv
nnoremap ]l :lnext<CR>zv
nnoremap [L :lfirst<CR>zv
nnoremap ]L :llast<CR>zv
nnoremap [q :cprevious<CR>zv
nnoremap ]q :cnext<CR>zv
nnoremap [Q :cfirst<CR>zv
nnoremap ]Q :clast<CR>zv

" close location list or quickfix list if they are present,
" see https://goo.gl/uXncnS
nnoremap<silent> \x :windo lclose <bar> cclose<CR>

" close a buffer and switching to another buffer, do not close the
" window, see https://goo.gl/Wd8yZJ
nnoremap <silent> \d :bprevious <bar> bdelete #<CR>

" toggle search highlight, see https://goo.gl/3H85hh
nnoremap <silent><expr> <Leader>hl (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Disable arrow key in vim, see https://goo.gl/s1yfh4
" disable arrow key in normal and insert mode (use faster way!)
nnoremap <Up> <nop>
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>
inoremap <Up> <nop>
inoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Right> <nop>

" insert a blank line below or above current line (do not move the cursor)
" see https://stackoverflow.com/a/16136133/6064933
nnoremap <expr> oo 'm`' . v:count1 . 'o<Esc>``'
nnoremap <expr> OO 'm`' . v:count1 . 'O<Esc>``'

" nnoremap oo @='m`o<c-v><Esc>``'<cr>
" nnoremap OO @='m`O<c-v><Esc>``'<cr>

" the following two mappings work, but if you change double quote to single, it
" work not work
" nnoremap oo @="m`o\<lt>Esc>``"<cr>
" nnoremap oo @="m`o\e``"<cr>

" insert a space after current character
nnoremap <silent> <Space><Space> a<Space><ESC>h

" yank from current cursor position to end of line (make it consistant with
" the behavior of D, C)
nnoremap Y y$

" move cursor based on physical lines not the actual lines.
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap $ g$
nnoremap ^ g^
nnoremap 0 g0

" do not include white space character when using $ in visual mode,
" see https://goo.gl/PkuZox
vnoremap $ g_

" jump to matching pairs easily in normal mode
nmap <Tab> %

" go to start or end of line easier
nnoremap H ^
nnoremap L $

" resize windows using <Alt> and h,j,k,l, inspiration from
" https://goo.gl/vVQebo (bottom page).
" If you enable mouse support, shorcut below may not be necessary
nnoremap <silent> <M-h> <C-w><
nnoremap <silent> <M-l> <C-w>>
nnoremap <silent> <M-j> <C-W>-
nnoremap <silent> <M-k> <C-W>+

" fast window switching, inspiration from
" https://stackoverflow.com/a/4373470/6064933
nnoremap <silent> <M-left> <C-w>h
nnoremap <silent> <M-right> <C-w>l
nnoremap <silent> <M-down> <C-w>j
nnoremap <silent> <M-up> <C-w>k

" continuous visual shifting (does not exit Visual mode), `gv` means
" to reselect previous visual area, see https://goo.gl/m1UeiT
vnoremap < <gv
vnoremap > >gv

" when completion menu is shown, use <cr> to select an item
" and do not add an annoying newline, otherwise, <enter> is just what it is,
" for more info , see https://goo.gl/KTHtrr and https://goo.gl/MH7w3b
inoremap <expr> <cr> ((pumvisible())?("\<C-Y>"):("\<cr>"))
" use <esc> to close auto-completion menu
inoremap <expr> <esc> ((pumvisible())?("\<C-e>"):("\<esc>"))

" edit and reload init.vim quickly
nnoremap <silent> <leader>ev :edit $MYVIMRC<cr>
nnoremap <silent> <leader>sv :silent update $MYVIMRC <bar> source $MYVIMRC <bar>
    \ echomsg "Nvim config successfully reloaded!"<cr>

nnoremap <silent> <leader><Space> :call <SID>StripTrailingWhitespaces()<CR>

" reselect the text that has just been pasted
nnoremap <leader>v `[V`]

" use sane regex expression (see `:h magic` for more info)
nnoremap / /\v

" find and replace (like Sublime Text 3)
nnoremap <C-H> :%s/

" change current working directory locally and print cwd after that
" see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
nnoremap <silent> <leader>cd :lcd %:p:h<CR>:pwd<CR>

" use Esc to quit builtin terminal
tnoremap <ESC>   <C-\><C-n>

" toggle spell checking (autosave does not play well with z=, so we disable it
" when we are doing spell checking)
nnoremap <silent> <F11> :set spell! <bar> :AutoSaveToggle<cr>
inoremap <silent> <F11> <C-O>:set spell! <bar> :AutoSaveToggle<cr>

" decrease indent level in insert mode with shift+tab
inoremap <S-Tab> <ESC><<i
"}

"{ Auto commands
" automatically save current file and execute it when pressing the <F9> key
" it is useful for small script
augroup filetype_auto_build_exec
    autocmd!
    autocmd FileType python nnoremap <buffer> <F9> :execute 'w !python'
                \ shellescape(@%, 1)<CR>
    autocmd FileType cpp nnoremap <F9> :w <CR> :!g++ -Wall -std=c++11 %
                \ -o %<&&./%<<CR>
augroup END

" do not use smart case in command line mode
" extracted from https://goo.gl/vCTYdK
augroup dynamic_smartcase
    autocmd!
    autocmd CmdLineEnter : set nosmartcase
    autocmd CmdLineLeave : set smartcase
augroup END

" set textwidth for text file types
augroup text_file_width
    autocmd!
    " sometimes, automatic filetype detection is not right, so we need to
    " detect the filetype based on the file extensions
    autocmd FileType text,tex setlocal textwidth=79
    autocmd BufNewFile,BufRead *.md,*.MD,*.markdown setlocal textwidth=79
augroup END

" do not use number and relative number for terminal inside nvim
augroup term_settings
    autocmd!
    " donot use number and relatiev number for terminal
    autocmd TermOpen * setlocal norelativenumber nonumber
    " go to insert mode by default to start typing command
    autocmd TermOpen * startinsert
augroup END

" start insert mode when open the command window
augroup cmd_mode_settings
    autocmd!
    autocmd CmdwinEnter [:]  startinsert
augroup END

" more accurate syntax highlighting? (see `:h syn-sync`)
augroup accurate_syn_highlight
    autocmd!
    autocmd BufEnter * :syntax sync fromstart
augroup END

" Return to last edit position when opening a file (see ':h line()')
augroup resume_edit_position
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   execute "normal! g`\"zvzz"
        \ | endif
augroup END

augroup vim_script_setting
    autocmd!
    " set the folding related options for vim script. Setting folding option in
    " modeline is annoying in that the modeline get executed each time the window
    " focus is lost (see http://tinyurl.com/yyqyyhnc)
    autocmd FileType vim set foldmethod=expr foldlevel=0 foldlevelstart=-1
    autocmd FileType vim set foldexpr=VimFolds(v:lnum) foldtext=MyFoldText()
    " autocmd FileType vim set foldexpr=VimFolds(v:lnum)

    " Simply set formatoptions without autocmd does not work for vim filetype
    " because the options are overruled by vim's default ftplugin for vim
    " script unfortunately. The following way to use autocmd seems quick and
    " dirty and may not even work (I do this because I don't want to
    " split my vim config).  For more discussions, see
    " http://tinyurl.com/yyznar7r and http://tinyurl.com/zehso5h

    " some format options when editting text file
    " donot insert comment leader after hitting o or O
    autocmd FileType vim setlocal formatoptions-=o

    " donot insert comment leader after hitting <Enter> in insert mode
    autocmd FileType vim setlocal formatoptions-=r

    " use :help command for keyword when pressing `K` in vim file,
    " see `:h K` and https://bre.is/wC3Ih-26u
    autocmd FileType vim setlocal keywordprg=:help
augroup END
"}

"{ Plugin install part
"{{ Vim-plug Install and plugin initialization
" auto-install vim-plug on different systems.
" For Windows, only Windows 10 with curl command installed are tested (after
" Windows 10 build 17063, source: http://tinyurl.com/y23972tt)
" The following script to install vim-plug are adapted from vim-plug tips: https://bit.ly/2IhJDNb
if !executable('curl')
    echomsg 'You have to install curl to install vim-plug or install vim-plug
            \ yourself following the guide on vim-plug git repository'
else
    let g:VIM_PLUG_PATH = stdpath('config') . '/autoload/plug.vim'
    if empty(glob(g:VIM_PLUG_PATH))
        echomsg 'Installing Vim-plug on your system'
        silent execute '!curl -fLo ' . g:VIM_PLUG_PATH . ' --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

        augroup plug_init
            autocmd!
            autocmd VimEnter * PlugInstall --sync | quit |source $MYVIMRC
        augroup END
    endif
endif
"}}

"{{ autocompletion related plugins
" set up directory to install all the plugins depending on the platform
if has('win32')
    let g:PLUGIN_HOME=expand('~/AppData/Local/nvim/plugged')
else
    let g:PLUGIN_HOME=expand('~/.local/share/nvim/plugged')
endif

call plug#begin(g:PLUGIN_HOME)
" settings for deoplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" snippet engine and snippet template
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" for insert mode completion
Plug 'ervandew/supertab'

" python source for deoplete
Plug 'zchee/deoplete-jedi', { 'for': 'python' }

" vim source for deoplete
Plug 'Shougo/neco-vim', { 'for': 'vim' }

" for English word auto-completion
Plug 'deathlyfrantic/deoplete-spell'
"}}

"{{ python-related plugins
" Python completion, goto definition etc.
Plug 'davidhalter/jedi-vim', { 'for': 'python' }

" python syntax highlighting and more
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' }

" python indent (follows the PEP8 style)
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}

" python code folding
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
"}}

"{{ search related plugins
" super fast movement with vim-sneak
Plug 'justinmk/vim-sneak'

" improve vim incsearch
Plug 'haya14busa/is.vim'

" show match number for incsearch
Plug 'osyo-manga/vim-anzu'

" stay after pressing * and search selected text
Plug 'haya14busa/vim-asterisk'

" another grep tool (similar to Sublime Text Ctrl+Shift+F)
" TODO: worth trying and exploring
Plug 'dyng/ctrlsf.vim'

" a grep tool
Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

" file search, tag search and more
if has('win32')
    Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
else
    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
endif
" another similar plugin is command-t
" Plug 'wincent/command-t'

" only use fzf for Linux and Mac since fzf does not work well for Windows
if has('unix')
    " fuzzy file search and more
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
endif
"}}

"{{ color, theme, look
" fancy and cute start screen
Plug 'mhinz/vim-startify'

" A list of colorscheme plugin you may want to try. Find what suits you.
Plug 'morhetz/gruvbox'
Plug 'sjl/badwolf'
Plug 'ajmwagar/vim-deus'
" Plug 'lifepillar/vim-solarized8'
" Plug 'sickill/vim-monokai'
" Plug 'whatyouhide/vim-gotham'
" Plug 'arcticicestudio/nord-vim'
" Plug 'rakr/vim-one'
" Plug 'kaicataldo/material.vim'

" colorful status line and theme
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" show indent lines for better comprehension of the code structure
" currently, blank lines inside the indent block do not show indent guides,
" see https://github.com/Yggdroot/indentLine/issues/25
Plug 'Yggdroot/indentLine'
"}}

"{{ plugin to deal with URL
" highlight URLs inside vim
Plug 'itchyny/vim-highlighturl'

" For Windows and Mac, we can open URL in browser. For Linux, it may not be
" possible since we maybe in a server which disables GUI
if has('win32') || has('macunix')
    " open URL in browser
    Plug 'tyru/open-browser.vim'
endif
"}}

"{{ navigation and tags plugin
" file explorer for vim
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

" only install these plugins if ctags are installed on the system
if executable('ctags')
    " plugin to manage your tags
    Plug 'ludovicchabant/vim-gutentags'

    " show file tags in vim window
    Plug 'majutsushi/tagbar', { 'on': ['TagbarToggle', 'TagbarOpen'] }
endif
"}}

"{{ file editting plugin
" automatic insertion and deletion of a pair of characters
Plug 'jiangmiao/auto-pairs'

" comment plugin
Plug 'scrooloose/nerdcommenter'

" multiple cursor plugin like Sublime Text?
" Plug 'mg979/vim-visual-multi'

" title character case
Plug 'christoomey/vim-titlecase'

" autosave files on certain events
Plug '907th/vim-auto-save'

" graphcial undo history, see https://github.com/mbbill/undotree
" Plug 'mbbill/undotree'

" another plugin to show undo history is: http://tinyurl.com/jlsgjy5
" Plug 'simnalamburt/vim-mundo'

if has('win32') || has('macunix')
    " manage your yank history
    Plug 'svermeulen/vim-yoink'
endif

" show marks in sign column for quicker navigation
Plug 'kshenoy/vim-signature'

" another good plugin to show signature
" Plug 'jeetsukumaran/vim-markology'

" handy unix command inside Vim (Rename, Move etc.)
Plug 'tpope/vim-eunuch'

" repeat vim motions
Plug 'tpope/vim-repeat'

" show the content of register in preview window
" Plug 'junegunn/vim-peekaboo'
if has('macunix')
    " IME toggle for Mac
    Plug 'rlue/vim-barbaric'
endif
"}}

"{{ linting, formating
" auto format tools
Plug 'sbdchd/neoformat'
" Plug 'Chiel92/vim-autoformat'

" syntax check and make
Plug 'neomake/neomake'

" another linting plugin
" Plug 'w0rp/ale'
"}}

"{{ git related plugins
" show git change (change, delete, add) signs in vim sign column
Plug 'mhinz/vim-signify'
" another similar plugin
" Plug 'airblade/vim-gitgutter'

" git command inside vim
Plug 'tpope/vim-fugitive'

" git commit browser
Plug 'junegunn/gv.vim', { 'on': 'GV' }
"}}

"{{ plugins for markdown writing
" distraction free writing
Plug 'junegunn/goyo.vim', { 'for': 'markdown' }

" only light on your cursor line to help you focus
Plug 'junegunn/limelight.vim', {'for': 'markdown'}

" markdown syntax highlighting
Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'markdown' }

" another markdown plugin
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" If we are on Win or Mac, preview the markdown in system default browser.
if has('win32') || has('macunix')
    " markdown previewing
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': 'markdown' }
endif

" faster footnote generation
Plug 'vim-pandoc/vim-markdownfootnotes', { 'for': 'markdown' }

" vim tabular plugin for manipulate tabular, required by markdown plugins
Plug 'godlygeek/tabular'

" markdown JSON header highlight plugin
Plug 'elzr/vim-json', { 'for': ['json', 'markdown'] }
"}}

"{{ text object plugins
" additional powerful text object for vim, this plugin should be studied
" carefully to use its full power
Plug 'wellle/targets.vim'

" Plugin to manipulate characer pairs quickly
Plug 'tpope/vim-surround'

" add indent object for vim (useful for languages like Python)
Plug 'michaeljsmith/vim-indent-object'

" create custom text object (needed by vim-text-object-entire)
Plug 'kana/vim-textobj-user'

" text object for entire buffer, add `ae` and `ie`
Plug 'kana/vim-textobj-entire'
"}}

"{{ LaTeX editting and previewing plugin
" Only use these plugin on Windows and Mac and when LaTeX is installed
if ( has('macunix') || has('win32') ) && executable('latex')
    " vimtex use autoload feature of Vim, so it is not necessary to use `for`
    " keyword of vim-plug to try to lazy-load it,
    " see http://tinyurl.com/y3ymc4qd
    Plug 'lervag/vimtex'

    " Plug 'matze/vim-tex-fold', {'for': 'tex'}
    " Plug 'Konfekt/FastFold'
endif
"}}

"{{ tmux related plugins
" Since tmux is only available on Linux and Mac, we only enable these plugins
" for Linux and Mac
if has('unix') && executable('tmux')
    " let vim detect tmux focus event correctly, see
    " http://tinyurl.com/y4xd2w3r and http://tinyurl.com/y4878wwm
    Plug 'tmux-plugins/vim-tmux-focus-events'

    " .tmux.conf syntax highlighting and setting check
    Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
endif
"}}

"{{ misc plugins
" automatically toggle line number based on several conditions
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" highlight yanked region
Plug 'machakann/vim-highlightedyank'

" quickly run a code script
Plug 'thinca/vim-quickrun'

" modern matchit implementation
Plug 'andymass/vim-matchup'

" simulating smooth scroll motions with physcis
Plug 'yuttie/comfortable-motion.vim'

Plug 'tpope/vim-scriptease'
Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}
call plug#end()
"}}
"}

"{ Plugin settings
"{{ vim-plug settings
" use shortnames for common vim-plug command to reduce typing
" To use these shortcut: first activate command line with `:`, then input the
" short alias name, e.g., `pi`, then press <space>, the alias will be expanded
" to the original command automatically
call Cabbrev('pi', 'PlugInstall')
call Cabbrev('pud', 'PlugUpdate')
call Cabbrev('pug', 'PlugUpgrade')
call Cabbrev('ps', 'PlugStatus')
call Cabbrev('pc', 'PlugClean')
"}}

"{{ auto-completion related
"""""""""""""""""""""""""""" deoplete settings""""""""""""""""""""""""""
" wheter to enable deoplete automatically after start nvim
let g:deoplete#enable_at_startup = 0

" start deoplete when we go to insert mode
augroup deoplete_start
    autocmd!
    autocmd InsertEnter * call deoplete#enable()
augroup END

" maximum candidate window length
call deoplete#custom#source('_', 'max_menu_width', 80)

" minimum character length needed to start completion,
" see https://goo.gl/QP9am2
call deoplete#custom#source('_', 'min_pattern_length', 1)

" whether to disable completion for certain syntax
" call deoplete#custom#source('_', {
"     \ 'filetype': ['vim'],
"     \ 'disabled_syntaxes': ['String']
"     \ })
call deoplete#custom#source('_', {
    \ 'filetype': ['python'],
    \ 'disabled_syntaxes': ['Comment']
    \ })

" ignore certain sources, because they only cause nosie most of the time
call deoplete#custom#option('ignore_sources', {
   \ '_': ['around', 'buffer', 'tag']
   \ })

" candidate list item limit
call deoplete#custom#option('max_list', 30)

"The number of processes used for the deoplete parallel feature.
call deoplete#custom#option('num_processes', 16)

" Delay the completion after input in milliseconds.
call deoplete#custom#option('auto_complete_delay', 100)

" enable or disable deoplete auto-completion
call deoplete#custom#option('auto_complete', v:true)

" automatically close function preview windows after completion
" see https://goo.gl/Bn5n39
" autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" deoplete tab-complete, see https://goo.gl/LvwZZY
" inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"

"""""""""""""""""""""""""UltiSnips settings"""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use
" https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger='<tab>'

" shortcut to go to next position
let g:UltiSnipsJumpForwardTrigger='<c-j>'

" shortcut to go to previous position
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" directory `my_snippets` should be put under your config directory (use
" `:echo stdpath('config')` to show the config directory).
let g:UltiSnipsSnippetDirectories=['UltiSnips', 'my_snippets']

"""""""""""""""""""""""""supertab settings""""""""""""""""""""""""""
" auto-close method preview window
"let g:SuperTabClosePreviewOnPopupClose = 1

" use the default top to bottom way for scroll, see https://goo.gl/APdo9V
let g:SuperTabDefaultCompletionType = '<c-n>'

" shortcut to navigate forward and backward in completion menu
" see https://is.gd/AoSv4m
let g:SuperTabMappingForward = '<tab>'
let g:SuperTabMappingBackward = '<s-tab>'
"}}

"{{ python-related
""""""""""""""""""deoplete-jedi settings"""""""""""""""""""""""""""
" whether to show doc string
let g:deoplete#sources#jedi#show_docstring = 0

" for large package, set autocomplete wait time longer
let g:deoplete#sources#jedi#server_timeout = 50

" ignore jedi errors during completion
let g:deoplete#sources#jedi#ignore_errors = 1

""""""""""""""""""""""""jedi-vim settings"""""""""""""""""""
" disable autocompletion, because I use deoplete for auto-completion
let g:jedi#completions_enabled = 0

" show function call signature
let g:jedi#show_call_signatures = '1'

"""""""""""""""""""""""""" semshi settings """""""""""""""""""""""""""""""
" do not highlight variable under cursor, it is distracting
let g:semshi#mark_selected_nodes=0

" do not show error sign since neomake is specicialized for that
let g:semshi#error_sign=v:false
"}}

"{{ search related
"""""""""""""""""""""""""""""vim-sneak settings"""""""""""""""""""""""
let g:sneak#label = 1
nmap f <Plug>Sneak_s
xmap f <Plug>Sneak_s
onoremap <silent> f :call sneak#wrap(v:operator, 2, 0, 1, 1)<CR>
nmap F <Plug>Sneak_S
xmap F <Plug>Sneak_S
onoremap <silent> F :call sneak#wrap(v:operator, 2, 1, 1, 1)<CR>

" immediately after entering sneak mode, you can press f and F to go to next
" or previous match
let g:sneak#s_next = 1

""""""""""""""""""""""""""""is.vim settings"""""""""""""""""""""""
" to make is.vim work together well with vim-anzu and put current match in
" the center of the window
" `zz`: put cursor line in center of the window
" `zv`: open a fold to reveal the text when cursor step into it
nmap n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)zzzv
nmap N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)zzzv

"""""""""""""""""""""""""""""vim-anzu settings"""""""""""""""""""""""
" do not show search index in statusline since it is shown on command line
let g:airline#extensions#anzu#enabled = 0

" maximum number of words to search
let g:anzu_search_limit = 500000

"""""""""""""""""""""""""""""vim-asterisk settings"""""""""""""""""""""
nmap *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)
nmap #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)
nmap g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)
nmap g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)

"""""""""""""""""""""""""fzf settings""""""""""""""""""""""""""
" only use fzf on Mac and Linux, since it doesn't work well for Windows
if has('unix')
    " hide status line when open fzf window
    augroup fzf_hide_statusline
        autocmd!
        autocmd! FileType fzf
        autocmd  FileType fzf set laststatus=0 noshowmode noruler
                    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
    augroup END

    " search file recursively under current folder
    nnoremap <silent> <leader>f :FZF<cr>

    " search file recursively under HOME (You may do want to do this!)
    " nnoremap <silent> <leader>F :FZF ~<cr>

    """""""""""""""""""""""""fzf.vim settings""""""""""""""""""
    " Customize fzf colors to match your color scheme
    let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }

    " [Tags] Command to generate tags file
    let g:fzf_tags_command = 'ctags -R'

    " floating windows only works for latest nvim version
    " floating window searching for fzf
    let $FZF_DEFAULT_OPTS = '--layout=reverse'

    " use floating window to open the fzf search window
    let g:fzf_layout = { 'window': 'call OpenFloatingWin()' }

    function! OpenFloatingWin()

        let height = &lines - 3
        let width = float2nr(&columns - (&columns * 2 / 10))
        let col = float2nr((&columns - width) / 2)

        " set up the attribute of floating window
        let opts = {
                \ 'relative': 'editor',
                \ 'row': height * 0.3,
                \ 'col': col + 20,
                \ 'width': width * 2 / 3,
                \ 'height': height / 2
                \ }

        let buf = nvim_create_buf(v:false, v:true)
        let win = nvim_open_win(buf, v:true, opts)

        " floating window highlight setting
        call setwinvar(win, '&winhl', 'Normal:Pmenu')

        setlocal
                \ buftype=nofile
                \ nobuflisted
                \ bufhidden=hide
                \ nonumber
                \ norelativenumber
                \ signcolumn=no
    endfunction
endif
"}}

"{{ URL related
""""""""""""""""""""""""""""open-browser.vim settings"""""""""""""""""""
if has('win32') || has('macunix')
    " disable netrw's gx mapping.
    let g:netrw_nogx = 1

    " use another mapping for the open URL method
    nmap ob <Plug>(openbrowser-smart-search)
    vmap ob <Plug>(openbrowser-smart-search)
endif

"{{ navigation and tags
""""""""""""""""""""""" nerdtree settings """"""""""""""""""""""""""
" toggle nerdtree window and keep cursor in file window,
" adapted from http://tinyurl.com/y2kt8cy9
nnoremap <silent> <Space>s :NERDTreeToggle<CR>:wincmd p<CR>

" reveal currently editted file in nerdtree widnow,
" see https://goo.gl/kbxDVK
nnoremap <silent> <Space>f :NERDTreeFind<CR>

" ignore certain files and folders
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" exit vim when the only window is nerdtree window, see
" https://github.com/scrooloose/nerdtree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
"     \ b:NERDTree.isTabTree()) | q | endif

" automatically show nerdtree window on entering nvim,
" see https://github.com/scrooloose/nerdtree, but now the cursor
" is in nerdtree window, so we need to change it to the file window,
" extracted from https://goo.gl/vumpvo
" autocmd VimEnter * NERDTree | wincmd l

" delete a file buffer when you have deleted it in nerdtree
let NERDTreeAutoDeleteBuffer = 1

" show current root as realtive path from HOME in status bar,
" see https://github.com/scrooloose/nerdtree/issues/891
let NERDTreeStatusline="%{exists('b:NERDTree')?fnamemodify(b:NERDTree.root.path.str(), ':~'):''}"

" disable bookmark and 'press ? for help ' text
let NERDTreeMinimalUI=0

""""""""""""""""""""""""""" tagbar settings """"""""""""""""""""""""""""""""""
" shortcut to toggle tagbar window
nnoremap <silent> <Space>t :TagbarToggle<CR>
"}}

"{{ file editting
"""""""""""""""""""""""""""""auto-pairs settings"""""""""""""""""""""""""
augroup filetype_custom_autopair
autocmd!
    " only use the following character pairs for tex file
    au FileType tex let b:AutoPairs = {'(':')', '[':']', '{':'}'}

    " add `<>` pair to filetype vim
    au FileType vim let b:AutoPairs = AutoPairsDefine({'<' : '>'})

    " do not use `"` for vim script since `"` is also used for comment
    au FileType vim let b:AutoPairs = {'(':')', '[':']', '{':'}', "'":"'", "`":"`", '<':'>'}
augroup END

""""""""""""""""""""""""""""nerdcommenter settings"""""""""""""""""""
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" use one space after # comment character in python,
" see http://tinyurl.com/y4hm29o3
let g:NERDAltDelims_python = 1

" Align line-wise comment delimiters flush left instead
" of following code indentation
let g:NERDDefaultAlign = 'left'

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

""""""""""""""""""""""""""""vim-titlecase settings"""""""""""""""""""""""
" do not use the default mapping provided
let g:titlecase_map_keys = 0

nmap <leader>gt <Plug>Titlecase
vmap <leader>gt <Plug>Titlecase
nmap <leader>gT <Plug>TitlecaseLine

""""""""""""""""""""""""vim-auto-save settings"""""""""""""""""""""""
" enable autosave on nvim startup
let g:auto_save = 1

" a list of events to trigger autosave
let g:auto_save_events = ['InsertLeave', 'TextChanged']

" show autosave status on command line
let g:auto_save_silent = 0

""""""""""""""""""""""""""""vim-yoink settings"""""""""""""""""""""""""
if has('win32') || has('macunix')
    " ctrl-n and ctrl-p will not work if you add the TextChanged event to
    " vim-auto-save events
    " nmap <c-n> <plug>(YoinkPostPasteSwapBack)
    " nmap <c-p> <plug>(YoinkPostPasteSwapForward)

    nmap p <plug>(YoinkPaste_p)
    nmap P <plug>(YoinkPaste_P)

    " cycle the yank stack with the following mappings
    nmap [y <plug>(YoinkRotateBack)
    nmap ]y <plug>(YoinkRotateForward)

    " not change the cursor position
    nmap y <plug>(YoinkYankPreserveCursorPosition)
    xmap y <plug>(YoinkYankPreserveCursorPosition)

    " move cursor to end of paste after multiline paste
    let g:yoinkMoveCursorToEndOfPaste = 0

    " record yanks in system clipboard
    let g:yoinkSyncSystemClipboardOnFocus = 1
endif

""""""""""""""""""""""""""""""vim-signature settings""""""""""""""""""""""""""
" change mark highlight to be more visible
augroup signature_highlight
autocmd!
autocmd ColorScheme * highlight SignatureMarkText cterm=bold ctermbg=10
    \ gui=bold guifg=#aeee04
augroup END
"}}

"{{ linting and formating
"""""""""""""""""""""""""""""" neomake settings """""""""""""""""""""""
" when to activate neomake
call neomake#configure#automake('nrw', 50)

" change warning signs and color, see https://goo.gl/eHcjSq
" highlight NeomakeErrorMsg ctermfg=227 ctermbg=237
let g:neomake_warning_sign={'text': '!', 'texthl': 'NeomakeWarningSign'}
let g:neomake_error_sign={'text': '✗'}

" which linter to enable for Python source file linting
" let g:neomake_python_enabled_makers = ['flake8', 'pylint']
let g:neomake_python_enabled_makers = ['flake8', 'pylint']

" whether to open quickfix or location list automatically
let g:neomake_open_list = 0
"}}

"{{ git-related
"""""""""""""""""""""""""vim-signify settings""""""""""""""""""""""""""""""
" the VCS to use
let g:signify_vcs_list = [ 'git' ]

" change the sign for certain operations
let g:signify_sign_change = '~'
"}}

"{{ Markdown writing
"""""""""""""""""""""""""goyo.vim settings""""""""""""""""""""""""""""""
" make goyo and limelight work together automatically
augroup goyo_work_with_limelight
    autocmd!
    autocmd! User GoyoEnter Limelight
    autocmd! User GoyoLeave Limelight!
augroup END

"""""""""""""""""""""""""vim-pandoc-syntax settings"""""""""""""""""""""""""
" do not conceal urls (seems does not work)
let g:pandoc#syntax#conceal#urls = 1

" use pandoc-syntax for markdown files, it will disable conceal feature for
" links, use it at your own risk
augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

"""""""""""""""""""""""""plasticboy/vim-markdown settings"""""""""""""""""""
" disable header folding
let g:vim_markdown_folding_disabled = 1

" whether to use conceal feature in markdown
let g:vim_markdown_conceal = 1

" disable math tex conceal and syntax highlight
let g:tex_conceal = ''
let g:vim_markdown_math = 0

" support front matter of various format
let g:vim_markdown_frontmatter = 1  " for YAML format
let g:vim_markdown_toml_frontmatter = 1  " for TOML format
let g:vim_markdown_json_frontmatter = 1  " for JSON format

" let the TOC window autofit so that it doesn't take too much space
let g:vim_markdown_toc_autofit = 1

"""""""""""""""""""""""""markdown-preview settings"""""""""""""""""""
" only setting this for suitable platforms
if has('win32') || has('macunix')
    " do not close the preview tab when switching to other buffers
    let g:mkdp_auto_close = 0

    " shortcut to start markdown previewing
    nnoremap <M-m> :MarkdownPreview<CR>
    nnoremap <M-S-m> :MarkdownPreviewStop<CR>
endif

""""""""""""""""""""""""vim-markdownfootnotes settings""""""""""""""""""""""""
" replace the default mappings provided by the plugin
imap ^^ <Plug>AddVimFootnote
nmap ^^ <Plug>AddVimFootnote

imap @@ <Plug>ReturnFromFootnote
nmap @@ <Plug>ReturnFromFootnote
"}}

"{{ LaTeX editting
""""""""""""""""""""""""""""vimtex settings"""""""""""""""""""""""""""""
if ( has('macunix') || has('win32')) && executable('latex')
    " enhanced matching with matchup plugin
    let g:matchup_override_vimtex = 1

    " set up LaTeX flavor
    let g:tex_flavor = 'latex'

    " deoplete configurations for autocompletion to work
    call deoplete#custom#var('omni', 'input_patterns', {
              \ 'tex': g:vimtex#re#deoplete
              \})

    let g:vimtex_compiler_latexmk = {
         \ 'backend' : 'nvim',
         \ 'background' : 1,
         \ 'build_dir' : 'build',
         \ 'callback' : 1,
         \ 'continuous' : 1,
         \ 'executable' : 'latexmk',
         \ 'options' : [
         \   '-verbose',
         \   '-file-line-error',
         \   '-synctex=1',
         \   '-interaction=nonstopmode',
         \ ],
         \}

    " Compile on initialization, cleanup on quit
    augroup vimtex_event_1
       au!
       au User VimtexEventInitPost call vimtex#compiler#compile()
       au User VimtexEventQuit     call vimtex#compiler#clean(0)
    augroup END

    " TOC settings
    let g:vimtex_toc_config = {
          \ 'name' : 'TOC',
          \ 'layers' : ['content', 'todo', 'include'],
          \ 'resize' : 1,
          \ 'split_width' : 50,
          \ 'todo_sorted' : 0,
          \ 'show_help' : 1,
          \ 'show_numbers' : 1,
          \ 'mode' : 2,
          \}

    " viewer settings for different platforms
    if has('win32')
        let g:vimtex_view_general_viewer = 'SumatraPDF'
        let g:vimtex_view_general_options_latexmk = '-reuse-instance'
        let g:vimtex_view_general_options
            \ = '-reuse-instance -forward-search @tex @line @pdf'
    endif

    if has('macunix')
        " let g:vimtex_view_method = "skim"
        let g:vimtex_view_general_viewer
                \ = '/Applications/Skim.app/Contents/SharedSupport/displayline'
        let g:vimtex_view_general_options = '-r @line @pdf @tex'

        " This adds a callback hook that updates Skim after compilation
        let g:vimtex_compiler_callback_hooks = ['UpdateSkim']

        function! UpdateSkim(status)
            if !a:status | return | endif

            let l:out = b:vimtex.out()
            let l:tex = expand('%:p')
            let l:cmd = [g:vimtex_view_general_viewer, '-r']

            if !empty(system('pgrep Skim'))
                call extend(l:cmd, ['-g'])
            endif

            if has('nvim')
                call jobstart(l:cmd + [line('.'), l:out, l:tex])
            elseif has('job')
                call job_start(l:cmd + [line('.'), l:out, l:tex])
            else
                call system(join(l:cmd + [line('.'), shellescape(l:out), shellescape(l:tex)], ' '))
            endif
        endfunction
    endif
endif
"}}

"{{ status line, look
"""""""""""""""""""""""""indentLine settings""""""""""""""""""""""""""
" whether to enable indentLine
let g:indentLine_enabled = 1

" the character used for indicating indentation
" let g:indentLine_char = '┊'
let g:indentLine_char = '│'

" whether to use conceal color by indentLine
let g:indentLine_setColors = 0

" show raw code when cursor is current line (mainly for markdown file)
" see https://github.com/plasticboy/vim-markdown/issues/395
let g:indentLine_concealcursor = ''

" disable indentline for certain filetypes
augroup indentline_disable_ft
    autocmd!
    autocmd FileType help,startify :IndentLinesDisable
augroup END

"""""""""""""""""""""""""""vim-airline setting""""""""""""""""""""""""""""""
" set a airline theme only if it exists, else we resort to default color
let s:candidate_airlinetheme = ['alduin', 'ayu_mirage', 'base16_flat',
    \ 'monochrome', 'base16_grayscale', 'lucius', 'base16_tomorrow',
    \ 'base16_adwaita', 'biogoo', 'distinguished', 'gruvbox', 'jellybeans',
    \ 'luna', 'raven', 'seagull', 'term', 'vice', 'zenburn']
let s:idx = RandInt(0, len(s:candidate_airlinetheme)-1)
let s:theme = s:candidate_airlinetheme[s:idx]

if HasAirlinetheme(s:theme)
    let g:airline_theme=s:theme
endif

" tabline settings
" show tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
" buffer number display format
let g:airline#extensions#tabline#buffer_nr_format = '%s. '

" show buffer number for easier switching between buffer
" see https://github.com/vim-airline/vim-airline/issues/1149
let g:airline#extensions#tabline#buffer_nr_show = 1

" whether to show function or other tags on status line
let g:airline#extensions#tagbar#enabled = 0

" skip empty sections if nothing to show
" extract from https://vi.stackexchange.com/a/9637/15292
let g:airline_skip_empty_sections = 1

"make airline more beautiful, see https://goo.gl/XLY19H for more info
let g:airline_powerline_fonts = 1

" show only hunks which is non-zero (git-related)
let g:airline#extensions#hunks#non_zero_only = 1

" enable gutentags integration
let g:airline#extensions#gutentags#enabled = 1

" custom status line symbols
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
"}}

"{{ misc plugin setting
""""""""""""""""""" vim-highlightedyank settings """"""""""""""
" reverse the highlight color for yanked text for better visuals
highlight HighlightedyankRegion cterm=reverse gui=reverse

" let highlight endures longer
let g:highlightedyank_highlight_duration = 1000

""""""""""""""""""""""""""""vim-matchup settings"""""""""""""""""""""""""""""
" whether to enable matching inside comment or string
let g:matchup_delim_noskips = 0

" change highlight color of matching bracket for better visual effects
augroup matchup_matchparen_highlight
  autocmd!
  autocmd ColorScheme * highlight MatchParen cterm=underline gui=underline
augroup END

" show matching keyword as underlined text to reduce color clutter
augroup matchup_matchword_highlight
    autocmd!
    autocmd ColorScheme * hi MatchWord cterm=underline gui=underline
augroup END

""""""""""""""""""""""""""quickrun settings"""""""""""""""""""""""""""""
let g:quickrun_no_default_key_mappings = 1
nnoremap<silent> <F9> :QuickRun<CR>
let g:quickrun_config = {'outputter/buffer/close_on_empty': 1}

""""""""""""""""""""""""comfortable-motion settings """"""""""""""""""""""
let g:comfortable_motion_scroll_down_key = 'j'
let g:comfortable_motion_scroll_up_key = 'k'

" mouse settings
noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(40)<CR>
noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-40)<CR>
"}}
"}

"{ Colorscheme and highlight settings
"{{ general settings about colors
" enable true colors support (do not use this option if your terminal does not
" support true colors. For a comprehensive list of terminals supporting true
" colors, see https://github.com/termstandard/colors and
" https://bit.ly/2InF97t)
set termguicolors

" use dark background (better for the eye, IMHO)
set background=dark
"}}

"{{ colorscheme settings
""""""""""""""""""""""""""""gruvbox settings"""""""""""""""""""""""""""
" we should check if theme exists before using it, otherwise you will get
" error message when starting Nvim
if HasColorscheme('gruvbox')
    " italic options should be put before colorscheme setting,
    " see https://goo.gl/8nXhcp
    let g:gruvbox_italic=1
    let g:gruvbox_contrast_dark='hard'
    let g:gruvbox_italicize_strings=1
    colorscheme gruvbox
else
    " fall back to a pre-installed theme
    colorscheme desert
endif

""""""""""""""""""""""""""" deus settings"""""""""""""""""""""""""""""""""
" colorscheme deus

""""""""""""""""""""""""""" solarized8 settings"""""""""""""""""""""""""
" solarized colorscheme without bullshit
" let g:solarized_term_italics=1
" let g:solarized_visibility="high"
" colorscheme solarized8_high

""""""""""""""""""""""""""" nord-vim settings"""""""""""""""""""""""""
" let g:nord_italic = 1
" let g:nord_underline = 1
" let g:nord_italic_comments = 1
" colorscheme nord

""""""""""""""""""""""""""" vim-one settings"""""""""""""""""""""""""""""
" let g:one_allow_italics = 1
" colorscheme one

"""""""""""""""""""""""""""material.vim settings""""""""""""""""""""""""""
" let g:material_terminal_italics = 1
" " theme_style can be 'default', 'dark' or 'palenight'
" let g:material_theme_style = 'dark'
" colorscheme material

"""""""""""""""""""""""""""badwolf settings""""""""""""""""""""""""""
" let g:badwolf_darkgutter = 0
" " Make the tab line lighter than the background.
" let g:badwolf_tabline = 2
" colorscheme badwolf
"}}
"}

"{ A list of resources which inspire me
" this list is non-exhaustive as I can not remember the source of many
" settings

" - http://stevelosh.com/blog/2010/09/coming-home-to-vim/
" - https://github.com/tamlok/tvim/blob/master/.vimrc
" - https://nvie.com/posts/how-i-boosted-my-vim/
" - https://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/
" - https://sanctum.geek.nz/arabesque/vim-anti-patterns/
" - https://github.com/gkapfham/dotfiles/blob/master/.vimrc

" The ascii art on the frontpage is generated using http://tinyurl.com/y6szckgd
"}
