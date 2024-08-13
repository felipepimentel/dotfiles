" init.vim

set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set clipboard=unnamedplus

call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'

call plug#end()

colorscheme gruvbox