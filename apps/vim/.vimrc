" Vim config file

" Set leader key to comma
let mapleader = ","

" Set tabstop to 4 spaces
set tabstop=4

" Set shiftwidth to 4 spaces
set shiftwidth=4

" Set expandtab to true
set expandtab

" Set number to true
set number

" Set relativenumber to true
set relativenumber

" Set cursorline to true
set cursorline

" Set background to dark
set background=dark

" Set termguicolors to true
set termguicolors

" Set encoding to utf-8
set encoding=utf-8

" Set fileformat to unix
set fileformat=unix

" Set fileencoding to utf-8
set fileencoding=utf-8

" Set nobackup to true
set nobackup

" Set nowritebackup to true
set nowritebackup

" Set noswapfile to true
set noswapfile

" Set undodir to ~/.vim/undo
set undodir=~/.vim/undo

" Set undofile to true
set undofile

" Set clipboard to unnamedplus
set clipboard=unnamedplus

" Set mouse to a
set mouse=a

" Set splitbelow to true
set splitbelow

" Set splitright to true
set splitright

" Set laststatus to 2
set laststatus=2

" Set statusline to %<%f\ %h%m%r%=%a\ %=%-14.(%l,%c%V%)\ %P
set statusline=%<%f\ %h%m%r%=%a\ %=%-14.(%l,%c%V%)\ %P

" Set cmdheight to 2
set cmdheight=2

" Set updatetime to 300
set updatetime=300

" Set shortmess to A
set shortmess=A

" Set completeopt to menuone,noinsert,noselect
set completeopt=menuone,noinsert,noselect

" Set pumheight to 10
set pumheight=10

" Set pumwidth to 60
set pumwidth=60

if has('nvim')
    " Set pumblend to 10
    set pumblend=10
    " Set pumvisible to true
    set pumvisible
    " Set pumtransparent to true
    set pumtransparent
    " Set winblend to 10
    set winblend=10
endif

" Set wildmode to list:longest
set wildmode=list:longest

" Set wildignore to */tmp/*,*.so,*.swp,*.zip,*.pdf,*.docx,*.doc,*.xls,*.xlsx,*.ppt,*.pptx,*.odt,*.ods,*.odp,*.css,*.sass,*.scss,*.less,*.styl,*.stylus,*.sublime-snippet,*.sublime-project
set wildignore=*/tmp/*,*.so,*.swp,*.zip,*.pdf,*.docx,*.doc,*.xls,*.xlsx,*.ppt,*.pptx,*.odt,*.ods,*.odp,*.css,*.sass,*.scss,*.less,*.styl,*.stylus,*.sublime-snippet,*.sublime-project

" Set wildmenu to true
set wildmenu

" Set lazyredraw to true
set lazyredraw

" Set showtabline to 2
set showtabline=2

" Set showbreak to ^\\n+++
set showbreak=^\\n+++

" Set list to true
set list

" Set listchars to tab:›\ ,trail:·,extends:›,precedes:‹,nbsp:·
set listchars=tab:›\ ,trail:·,extends:›,precedes:‹,nbsp:·

" Set conceallevel to 0
set conceallevel=0

" Set concealcursor to n
set concealcursor=n

" Set signcolumn to yes
set signcolumn=yes

" Set foldmethod to indent
set foldmethod=indent

" Set foldlevel to 99
set foldlevel=99

" Set foldopen to block,hor,insert,jump,mark,percent,quickfix,tag,undo
set foldopen=block,hor,insert,jump,mark,percent,quickfix,tag,undo

" Set foldclose to all
set foldclose=all

" Set diffopt to internal,algorithm:patience
set diffopt=internal,algorithm:patience

" Set grepformat to %p:%f:%l:%m
set grepformat=%p:%f:%l:%m

" Set grepprg to grep -nH --color=never
set grepprg=grep\ -nH\ --color=never