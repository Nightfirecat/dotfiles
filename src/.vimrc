" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
	finish
endif

" Get the defaults that most users want
source $VIMRUNTIME/defaults.vim

" Don't keep context lines around cursor
set scrolloff=0

" do not keep backup files or undo files (they clutter filesystem)
set nobackup
set noundofile

" Put these in an autocmd group so that we can delete them easily
augroup vimrc
	au!

	" For all text files set 'textwidth' to 80 characters
	autocmd FileType text setlocal textwidth=80
augroup END

" Add optional packages
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
	packadd! matchit
endif

" Enable re-use of the same window to switch from an unsaved buffer without
" saving it first. Also allows you to keep an undo history for multiple files
" when re-using the same window in this way.
set hidden

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
if &t_Co > 2 || has("gui_running")
	set hlsearch
endif

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behavior deviates from that of Vi, it does what most users coming
" from other editors would expect.
set nostartofline

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

" Use 4-width tabs
" Force tabs over spaces for indentation
" Use one tab when using Vim shifts
set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

" Jump to last position when reopening a file
if has('autocmd')
	au BufReadPost * if line ("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	autocmd BufReadPost COMMIT_EDITMSG | exe "normal! gg"
endif

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>
