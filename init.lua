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

-- Remove 'source <afile>' to prevent errors on save
vim.cmd [[autocmd BufWritePost init.lua PackerCompile]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Packer can manage itself

  -- Add the tokyonight colorscheme
  use 'folke/tokyonight.nvim'

  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Vimtex for Latex editing
  use 'lervag/vimtex'

  -- Telescope for fuzzy searching
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
 

  -- LSP configurations
  use 'neovim/nvim-lspconfig'

  -- Nvim-tree for file explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    }
  }

  -- Optional: Status line customization
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Optional: Autocompletion plugins
  use 'hrsh7th/nvim-cmp'         -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'     -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'         -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip' -- Snippet source for nvim-cmp

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Vimtex settings
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'


-- Set the colorscheme to tokyonight
vim.cmd[[colorscheme tokyonight]]

-- Set the GUI font (only works in GUI versions)
vim.o.guifont = 'FiraCode Nerd Font:h17'  -- Replace with your desired font and size

-- Function to toggle between relative and absolute line numbers
vim.api.nvim_set_keymap('n', '<leader>ln', ':set relativenumber!<CR>', { noremap = true, silent = true })

-- Configure 'listchars' to display spaces and tabs
vim.opt.listchars = { space = '⋅', tab = '▸ ', eol = '↴' }
vim.opt.list = false  -- Initially disable 'list' option


-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "python", "javascript", "typescript", "rust", "bash", "latex" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Telescope configuration
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--word-regexp'
    },
    prompt_prefix = "> ",
    selection_caret = "> ",
    path_display = {"smart"},
    extensions = {
        fzf = {
            fuzzy = false, -- only show direct matches in search
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    }
  }
}

require('telescope').load_extension('fzf')

-- General Neovim settings
vim.o.number = true              -- Enable line numbers
vim.o.relativenumber = true      -- Enable relative line numbers
vim.o.clipboard = 'unnamedplus'  -- Use system clipboard

vim.opt.tabstop = 4 -- number of spaces a tab char represents
vim.opt.softtabstop = 4 -- number of spaces to insert with the tab key in insert mode
vim.opt.shiftwidth = 4 -- Number of spaces for each indentation level
vim.opt.expandtab = true -- convert tabs to spaces


-- Keybindings

-- Set the leader key to comma (',')
vim.g.mapleader = ','

-- General
local opts = { noremap = true, silent = true}

-- Key mappings for copy and paste (uses system clipboard)
-- Copy in visual mode
vim.api.nvim_set_keymap('v', '<leader>c', '"+y', opts)
-- Copy current line in normal mode
vim.api.nvim_set_keymap('n', '<leader>c', '"+yy', opts)
-- Paste in normal mode
vim.api.nvim_set_keymap('n', '<leader>v', '"+p', opts )
-- Paste in visual mode
vim.api.nvim_set_keymap('v', '<leader>v', '"+p', opts)


-- Key mapping to toggle the 'list' option
vim.api.nvim_set_keymap('n', '<leader>ts', ':set list!<CR>', { noremap = true, silent = true })

-- Telescope keybindings
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", opts)

-- Vimtex keybindings
vim.api.nvim_set_keymap('n', '<leader>lc', '<cmd>VimtexCompile<CR>', opts) -- compile Document
vim.api.nvim_set_keymap('n', '<leader>lv', '<cmd>VimtexView<CR>', opts) -- View PDF
vim.api.nvim_set_keymap('n', '<leader>lq', '<cmd>VimtexCompileStop<CR>', opts) -- stop compilation
vim.api.nvim_set_keymap('n', '<leader>le', '<cmd>VimtexErrors<CR>', opts) -- show errors


-- Keybinding for opening/closing the file explorer with Ctrl + n
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts )


-- LSP configuration
local status_ok, lspconfig = pcall(require, 'lspconfig')
if status_ok then
  -- Set up LSP with nvim-cmp capabilities
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Configure LSP for Lua using lua_ls
  lspconfig.lua_ls.setup{
    capabilities = capabilities,
    settings = {
      Lua = {
        diagnostics = {
          globals = {'vim'}
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
      }
    }
  }

  -- LSP Configuration for TypeScript/JavaScript using ts_ls
  lspconfig.ts_ls.setup{
    capabilities = capabilities,
  }

  -- LSP Configuration for Rust
  lspconfig.rust_analyzer.setup{
    capabilities = capabilities,
  }

  -- Configuration for latex
  lspconfig.texlab.setup{
	  capabilities = capabilities
  }
end

-- Nvim-tree setup
require'nvim-tree'.setup {}


-- Auto open nvim-tree when opening nvim with a directory
vim.cmd([[
  autocmd VimEnter * if isdirectory(expand('%')) | NvimTreeOpen | endif
]])

-- Lualine configuration
require('lualine').setup {
  options = {
    theme = 'tokyonight',
    icons_enabled = true,
  }
}

-- Set up nvim-cmp
local cmp_status_ok, cmp = pcall(require, 'cmp')
if cmp_status_ok then
  cmp.setup({
    snippet = {
      expand = function(args)
        require'luasnip'.lsp_expand(args.body)
      end,
    },
    mapping = {
        ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
            local selected = cmp.get_selected_entry()
            if selected then
            cmp.confirm({ select = false }) -- Only confirm explicitly selected item, without auto choosing first entry (no auto select)
            else
                fallback()
            end
            else
                fallback() -- Use Enter for newline if no item is selected
            end
        end, { 'i', 's' }),
        ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), -- Navigate down
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), -- Navigate up
        ['<C-e>'] = cmp.mapping.abort(), -- Abort completion
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    },
  })
end

-- Key Mappings and Functions Summary

-- Leader Key: ',' (comma)

-- Copy and Paste using System Clipboard
-- Visual Mode: ',c' to copy selection to clipboard
-- Normal Mode: ',c' to copy current line to clipboard
-- Normal Mode: ',v' to paste from clipboard after cursor
-- Visual Mode: ',v' to replace selection with clipboard content

-- Toggle Relative Line Numbers
-- Normal Mode: ',ln' toggles relative line numbers on/off

-- Toggle Display of Spaces and Tabs
-- Normal Mode: ',ts' toggles visibility of whitespace characters

-- Open/Close Nvim-Tree File Explorer
-- Normal Mode: Ctrl + n to toggle file explorer

-- Telescope Fuzzy Finder
-- Normal Mode: ',ff' to find files
-- Normal Mode: ',fg' to live grep/search within files

-- Autocompletion Shortcuts (nvim-cmp)
-- Insert Mode:
--   Ctrl + p     : Previous suggestion
--   Ctrl + n     : Next suggestion
--   Ctrl + d     : Scroll documentation up
--   Ctrl + f     : Scroll documentation down
--   Ctrl + Space : Trigger autocomplete
--   Ctrl + e     : Close autocomplete menu
--   Enter        : Confirm selection

-- Additional Features:

-- Line Numbering:
--   - Absolute and relative line numbers enabled by default
--   - Toggle with ',ln'

-- Display of Spaces and Tabs:
--   - Spaces shown as '⋅', tabs as '▸ ', end-of-line as '↴'
--   - Toggle visibility with ',ts'

-- System Clipboard Integration:
--   - Uses 'unnamedplus' clipboard setting for seamless copy/paste

-- Colorscheme:
--   - 'tokyonight' colorscheme applied

-- GUI Font Configuration:
--   - Font set to 'FiraCode Nerd Font:h17' (for GUI versions of Neovim)

-- Treesitter Configuration:
--   - Enhanced syntax highlighting for languages: c, lua, python, javascript, typescript, rust, bash

-- Telescope Configuration:
--   - Powerful fuzzy finder for files and text within project

-- LSP Configurations:
--   - Lua: 'lua_ls' for Lua language support
--   - TypeScript/JavaScript: 'tsserver' for TypeScript and JavaScript
--   - Rust: 'rust_analyzer' for Rust language support

-- Nvim-Tree File Explorer:
--   - File explorer with file icons
--   - Toggle with 'Ctrl + n'
--   - Auto-opens when Neovim is started with a directory

-- Lualine Status Line:
--   - Customized status line with 'tokyonight' theme

-- Autocompletion with nvim-cmp:
--   - Integrated autocompletion with LSP and LuaSnip snippets
--   - Use the key mappings listed above for navigation and selection

-- Plugins Used:

-- 'wbthomason/packer.nvim'              -- Plugin manager
-- 'folke/tokyonight.nvim'               -- Colorscheme
-- 'nvim-treesitter/nvim-treesitter'     -- Treesitter for syntax highlighting
-- 'nvim-telescope/telescope.nvim'       -- Fuzzy finder
-- 'neovim/nvim-lspconfig'               -- LSP configurations
-- 'kyazdani42/nvim-tree.lua'            -- File explorer
-- 'kyazdani42/nvim-web-devicons'        -- File icons
-- 'nvim-lualine/lualine.nvim'           -- Status line
-- 'hrsh7th/nvim-cmp'                    -- Autocompletion plugin
-- 'hrsh7th/cmp-nvim-lsp'                -- LSP source for nvim-cmp
-- 'L3MON4D3/LuaSnip'                    -- Snippet engine
-- 'saadparwaiz1/cmp_luasnip'            -- Snippet source for nvim-cmp
