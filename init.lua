-- Packer plugin manager configuration
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.cmd [[autocmd BufWritePost init.lua source <afile> | PackerCompile]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Packer can manage itself

  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Telescope for fuzzy searching
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- LSP configurations
  use 'neovim/nvim-lspconfig'

  -- Nvim-tree for file explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    }
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- General Neovim settings
vim.o.number = true            -- Enable line numbers
vim.o.relativenumber = true     -- Enable relative line numbers
vim.o.clipboard = 'unnamedplus' -- Use system clipboard

-- Function to toggle between relative and absolute line numbers
vim.api.nvim_set_keymap('n', '<leader>ln', ':set relativenumber!<CR>', { noremap = true, silent = true })

-- Key mapping for copy-paste (uses system clipboard)
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true }) -- Copy to system clipboard
vim.api.nvim_set_keymap('v', '<leader>p', '"+p', { noremap = true, silent = true }) -- Paste from system clipboard

-- Treesitter configuration (added support for typescript and rust)
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "python", "javascript", "typescript", "rust" },  -- Add desired languages
  highlight = {
    enable = true,  -- Enable syntax highlighting
    additional_vim_regex_highlighting = false,
  },
}

-- Telescope configuration (for fuzzy searching)
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    path_display = {"smart"},
  }
}

-- Example Telescope keybinding
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap = true, silent = true })

-- LSP configuration
local lspconfig = require'lspconfig'

-- Configure LSP for Lua using lua_ls (instead of deprecated sumneko_lua)
lspconfig.lua_ls.setup{
  settings = {
    Lua = {
      diagnostics = {
        globals = {'vim'}  -- Get rid of "undefined global 'vim'" warnings
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),  -- Make the server aware of Neovim runtime files
      },
    }
  }
}

-- LSP Configuration for TypeScript/JavaScript (using ts_ls instead of deprecated tsserver)
lspconfig.ts_ls.setup{}

-- LSP Configuration for Rust (using rust-analyzer)
lspconfig.rust_analyzer.setup{}

-- Nvim-tree setup for file explorer
require'nvim-tree'.setup {}

-- Keybinding for opening/closing the file explorer with Ctrl + n
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Auto open nvim-tree when opening nvim with a directory
vim.cmd([[
  autocmd VimEnter * if isdirectory(expand('%')) | NvimTreeOpen | endif
]])

