-- Set up nvim-treesitter
vim.cmd [[packadd nvim-treesitter]]
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",  -- Instala todos os parsers disponíveis. Alterar para uma lista específica, se necessário.
  highlight = {
    enable = true,           -- Ativa o realce de sintaxe
    additional_vim_regex_highlighting = false,  -- Use apenas o Treesitter para o realce
  },
}

-- Set up vim-plug
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug('neoclide/coc.nvim', {branch = 'release'})
Plug 'github/copilot.vim'
Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
Plug 'BurntSushi/ripgrep'

vim.call('plug#end')

-- General settings
vim.opt.number = true                       -- Exibe números de linha
vim.opt.syntax = 'on'                       -- Ativa o realce de sintaxe padrão
vim.opt.mouse = 'a'                         -- Habilita o uso do mouse em todas as partes do Neovim
vim.opt.clipboard = 'unnamedplus'           -- Usa o clipboard do sistema para operações de copiar/colar

-- NERDTree settings
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', {noremap = true, silent = true})
vim.g.NERDTreeShowHidden = 1                -- Exibe arquivos ocultos no NERDTree

-- vim-airline settings
vim.g['airline#extensions#tabline#enabled'] = 1  -- Habilita o tabline no vim-airline
vim.g['airline#extensions#tabline#formatter'] = 'unique_tail'  -- Define o formatter para 'unique_tail'

-- coc.nvim settings
vim.g.coc_global_extensions = {'coc-json', 'coc-html', 'coc-css', 'coc-tsserver', 'coc-pyright'}  -- Define extensões globais do coc.nvim

-- Python specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tabstop=4 shiftwidth=4 expandtab"  -- Configurações específicas para arquivos Python
})

-- Poetry integration
vim.g.python3_host_prog = vim.fn.trim(vim.fn.system('which python3'))  -- Configura o caminho do Python para integração com o Poetry

-- Useful shortcuts
local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<space>e', ':CocCommand explorer<CR>', keymap_opts)  -- Atalho para abrir o Coc Explorer
vim.api.nvim_set_keymap('n', '<space>f', ':CocCommand prettier.formatFile<CR>', keymap_opts)  -- Atalho para formatar o arquivo com Prettier
vim.api.nvim_set_keymap('n', '<F5>', ':w<CR>:!python3 %<CR>', keymap_opts)  -- Atalho para salvar e executar um script Python

-- LSP log level
vim.lsp.set_log_level("INFO")  -- Define o nível de log do LSP para 'INFO'
