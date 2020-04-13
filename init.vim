command! Vimrc :e $MYVIMRC
command! Source :source %

call plug#begin(stdpath("data") . "/plugged")
Plug 'dracula/vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'terryma/vim-multiple-cursors'
Plug 'easymotion/vim-easymotion'
Plug 'preservim/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/deoplete-clangx'
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'ncm2/float-preview.nvim'
Plug 'vim-scripts/CursorLineCurrentWindow'
Plug 'sheerun/vim-polyglot'
Plug '~/vim-lldb', { 'do': ':UpdateRemotePlugins' }
call plug#end()

" Load project specific vimrc
if filereadable('.vimrc')
    execute 'source .vimrc'
endif

set termguicolors
colorscheme dracula

set number
set cursorline
set showcmd
set mouse=a
set lazyredraw
set scrolloff=5 
set tabstop=4
set shiftwidth=4
set expandtab
filetype indent plugin on
" Indent case labels in the same level as switch
set cindent
set cinoptions=:0
syntax enable
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vimsyn_embed = 'P'

set smartcase
let mapleader = '\'
" Clear search register (highlight) after doing a search 
nnoremap <Leader>h :let @/ = ""<CR>
" Force clearing search register after reloading vimrc
call feedkeys("\\h")

noremap Y y$
noremap j gj
noremap k gk
noremap gy "+y
nmap gY "+Y
noremap gp "+p
noremap gP "+P

inoremap <A-h> <C-\><C-o>b
inoremap <A-l> <C-\><C-o>w
inoremap <A-BS> <C-w>

set splitbelow
set splitright
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
" Swap window
nnoremap <A-r> <C-w>r

" :help NERDTree
" Toggle nerdtree and refresh
function! ToggleTree()
    NERDTreeToggle
    if g:NERDTree.IsOpen()
        call feedkeys('R')
    endif 
endfunction
nnoremap <Leader>e :call ToggleTree()<CR>
let g:NERDTreeShowHidden = 1
let g:NERDTreeWinPos = "right"

" Open terminal and start insertion
function! OpenTerminal()
    terminal
    call feedkeys('a')
endfunction
nnoremap <Leader>s :call OpenTerminal()<CR>
" Exit from terminal
tnoremap <C-e> <C-\><C-n>

" :help easymotion
nmap <Leader>/ <Plug>(easymotion-bd-w)

" :help vim-multiple-cursors
" Explicitly define key mappings to prevent some key mapping collisions
let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_start_word_key = '<C-n>'
let g:multi_cursor_next_key = '<C-n>'
let g:multi_cursor_prev_key = '<C-p>'
let g:multi_cursor_skip_key = '<C-x>'
let g:multi_cursor_quit_key = '<Esc>'

" Explicitly define key mappings to prevent some key mapping collisions
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''

" :help ctrlp
let g:ctrlp_map = '<Leader>p'
" Force searching files under cwd
let g:ctrlp_working_path_mode = ''
" List all files ignoring .git and files in .gitignore
let g:ctrlp_user_command = "if git rev-parse --git-dir &> /dev/null ; for file in (git ls-files --cached --others --exclude-standard) ; if test -f $file ; echo $file ; end ; end ; else ; find %s -type f ; end"
" Refresh files on open
function! CtrlpRefresh()
    CtrlPClearCache
endfunction
let g:ctrlp_buffer_func = { 'enter': 'CtrlpRefresh' }

function! OpenOtherWindow(...)
    let split_command = get(a:, 1, 'split')
    let curr_winnr = winnr()
    wincmd o
    execute 'vertical '.split_command
    if curr_winnr > 1
        wincmd r
    endif
endfunction

" :help quickfix
" Call build script and show quickfix in the other window if error happens
function! Build()
    execute '!'.g:project_build_script.' 2>.vimqf'
    call feedkeys('\<CR>')
    echom v:shell_error
    if v:shell_error == 0
        cclose
    else
        cfile .vimqf
        call OpenOtherWindow('copen')
        wincmd p
        wincmd =
    endif
endfunction
if exists("g:project_build_script")
    nnoremap <Leader>b :call Build()<CR>
    nnoremap <Leader>n :cnext<CR>
endif

" :help deoplete-contents
set completeopt=menu,menuone,noselect
set pumheight=20
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('auto_complete_popup', 'manual')
call deoplete#custom#option('min_pattern_length', 0)
inoremap <expr> <C-n> g:deoplete#complete()
inoremap <expr> <C-p> g:deoplete#complete()
call deoplete#custom#option('sources', { 'c': ['clangx'], 'cpp': ['clangx'], 'python': ['jedi', 'buffer'], '_': ['buffer']} )
let clang_options = []
if exists('g:project_include_dir')
    for include_dir in g:project_include_dir
        call add(clang_options, '-I'.include_dir)
    endfor
endif
call deoplete#custom#var('clangx', 'clang_binary', trim(system('which clang')))
call deoplete#custom#var('clangx', 'default_c_options', clang_options)
call deoplete#custom#var('clangx', 'default_cpp_options', clang_options)
let g:deoplete#sources#jedi#show_docstring = 1

nnoremap <A-q> :call VimLLDB_ToggleDebugger()<CR>
nnoremap <A-x> :call VimLLDB_Launch()<CR>
nnoremap <A-z> :call VimLLDB_Kill()<CR>
nnoremap <A-c> :call VimLLDB_Resume()<CR>
nnoremap <A-v> :call VimLLDB_Pause()<CR>
nnoremap <A-b> :call VimLLDB_ToggleBreakpoint()<CR>
nnoremap <A-n> :call VimLLDB_StepOver()<CR>
nnoremap <A-m> :call VimLLDB_StepInto()<CR>
nnoremap <A-,> :call VimLLDB_StepOut()<CR>

