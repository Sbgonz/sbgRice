let mapleader =","

if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
    autocmd VimEnter * PlugInstall
endif

call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'tpope/vim-surround' " all about surroundings
Plug 'junegunn/goyo.vim' " distraction-free writing in vim
Plug 'jreybert/vimagit' " perform git operation in a vim buffer
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-commentary'
" Plug 'ap/vim-css-color' " colorize code colors in css files
Plug 'lambdalisue/suda.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

set title
set bg=dark
set go=a
set mouse=a
set ignorecase
set smartcase
set nohlsearch  " no highlighting occurs
set spelllang=en,es
set termguicolors
set clipboard+=unnamedplus
set noshowmode
set noruler
set laststatus=0
set noshowcmd
set colorcolumn=80
set tabstop=4  " Indentation 2 spaces
set shiftwidth=4
set softtabstop=4
set shiftround
" set expandtab  " Insert spaces instead of <Tab>s
set nowrapscan
set dictionary+=~/.local/share/dic/zettKeys
set complete+=k


" Some basics:
    nnoremap c "_c
    set nocompatible
    filetype plugin on
    syntax on
    set encoding=utf-8
    set number relativenumber
    nnoremap <leader>l :ls<CR>:b<space>
" Enable autocompletion:
    set wildmode=longest,list,full
" Disables automatic commenting on newline:
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" Perform dot commands over visual blocks:
    vnoremap . :normal .<CR>
" Goyo plugin makes text more readable when writing prose:
    map <leader>f :Goyo \| set bg=light \| set linebreak<CR>
" Spell-check set to <leader>o, 'o' for 'orthography' ("en_us" for english:
    map <leader>o :setlocal spell! spelllang=es_es<CR>
" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
    set splitbelow splitright
" Make :grep use ripgrep
    set grepprg=rg\ --color=never\ --vimgrep\ --smart-case\ --follow

" FZF.vim config
let g:fzf_preview_window = ['hidden,right,50%,<70(up,50%)', 'ctrl-/']

" Zettelkasten nvim tools
    " FZF function to insert link between notes in the $ZETTEL
    function! HandleFZF(file)
        let filename = fnameescape(a:file)
        let filename_wo_timestamp = fnameescape(fnamemodify(a:file, ":t:s/^[0-9]*-//"))
    " Insert the markdown link to the file in the current buffer
        let mdlink = "[".filename_wo_timestamp."](".filename.")"
        put=mdlink
    endfunction
    command! -nargs=1 HandleFZF :call HandleFZF(<f-args>)
    " Map to call the function
    nnoremap <leader>f :call fzf#run({'sink':'HandleFZF', 'dir':'$ZETTEL'})

    " Search for content in the files of our $ZETTEL
    command! -nargs=1 Ngrep grep "<args>" --glob "*.md" $ZETTEL
    nnoremap <leader>nn :Ngrep
    " Show QuickFix list in vertical mode
    command! Vlist botright vertical copen | vertical resize 50
    nnoremap <leader>v :Vlist<CR>

" airline
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#fnamemod = ':t'

" Shortcutting split/buffers navigation, saving a keypress:
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
    nmap [b :bp<CR>
    nmap ]b :bn<CR>

" Replace ex mode with gq
    map Q gq

" Replace q! with qq
    cabbrev qq q!

" Check file in shellcheck:
    map <leader>s :!clear && shellcheck -x %<CR>

" Open my bibliography file in split
    map <leader>b :vsp<space>$BIB<CR>
    map <leader>r :vsp<space>$REFER<CR>

" Replace all is aliased to S.
    nnoremap S :%s//g<Left><Left>

" Compile document, be it groff/LaTeX/markdown/etc.
    map <leader>c :w! \| !compiler "<c-r>%"<CR>

" Open corresponding .pdf/.html or preview
    map <leader>p :!opout <c-r>%<CR><CR>

" Runs a script that cleans out tex build files whenever I close out of a .tex file.
    autocmd VimLeave *.tex !texclear %

" Ensure files are read as what I want:
    autocmd BufRead,BufNewFile *.md,*.txt set filetype=markdown
    autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
    autocmd BufRead,BufNewFile *.tex set filetype=tex

" Save file as sudo on files that require root permission
    cabbrev w!! SudaWrite

" Enable Goyo by default for mutt writing
    autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
    autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=light
    autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
    autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save. & reset cursor position
    autocmd BufWritePre * let currPos = getpos(".")
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufWritePre * %s/\n\+\%$//e
    autocmd BufWritePre *.[ch] %s/\%$/\r/e
    autocmd BufWritePre * cal cursor(currPos[1], currPos[2])

" When shortcut files are updated, renew bash and ranger configs with new material:
    autocmd BufWritePost bm-files,bm-dirs !shortcuts
" Run xrdb whenever Xdefaults or Xresources are updated.
    autocmd BufRead,BufNewFile Xresources,Xdefaults,xresources,xdefaults set filetype=xdefaults
    autocmd BufWritePost Xresources,Xdefaults,xresources,xdefaults !xrdb %
" Recompile dwmblocks on config edit.
    autocmd BufWritePost ~/.local/src/dwmblocks/config.h !cd ~/.local/src/dwmblocks/; sudo make install && { killall -q dwmblocks;setsid -f dwmblocks }

" Turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
    highlight! link DiffText MatchParen
endif

" Function for toggling the bottom statusbar:
let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
nnoremap <leader>h :call ToggleHiddenAll()<CR>

" Load command shortcuts generated from bm-dirs and bm-files via shortcuts script.
" Here leader is ";".
" So ":vs ;cfz" will expand into ":vs /home/<user>/.config/zsh/.zshrc"
" if typed fast without the timeout.
source ~/.config/nvim/shortcuts.vim
