-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader before lazy so mappings are correct
vim.g.mapleader = ','

require('lazy').setup({

  -- Colorscheme
  'folke/tokyonight.nvim',

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "lua", "python", "svelte", "javascript", "typescript", "rust", "bash", "latex" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  },

  -- Vimtex
  'lervag/vimtex',

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case', '--word-regexp'
          },
          prompt_prefix = '> ',
          selection_caret = '> ',
          path_display = { 'smart' },
        },
        extensions = {
          fzf = {
            fuzzy = false,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
        },
      }
      require('telescope').load_extension('fzf')
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason: installs LSP servers inside Neovim (no system packages needed)
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- mason-lspconfig bridges Mason installs → lspconfig
      -- Run :MasonInstall lua-language-server ts_ls rust_analyzer texlab svelte-language-server
      -- to install all servers, or use :Mason UI to browse and install.
      require('mason-lspconfig').setup {
        -- Automatically set up any server installed via Mason
        handlers = {
          -- Default handler for all servers
          function(server_name)
            lspconfig[server_name].setup { capabilities = capabilities }
          end,
          -- Custom handler for lua_ls (needs vim globals)
          lua_ls = function()
            lspconfig.lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { 'vim' } },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file('', true),
                    checkThirdParty = false,
                  },
                },
              },
            }
          end,
        },
      }
    end,
  },

  -- File explorer (updated org: nvim-tree/nvim-tree.lua)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Disable netrw (recommended by nvim-tree)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require('nvim-tree').setup {}
    end,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'tokyonight',
        icons_enabled = true,
      },
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local selected = cmp.get_selected_entry()
              if selected then
                cmp.confirm({ select = false })
              else
                fallback()
              end
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<Tab>']  = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-p>']  = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-e>']  = cmp.mapping.abort(),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
    end,
  },

}, {
  -- lazy.nvim options
  checker = { enabled = false }, -- set to true to auto-check for plugin updates
})

-- ─── Colorscheme ──────────────────────────────────────────────────────────────
vim.cmd [[colorscheme tokyonight]]

-- ─── Vimtex ───────────────────────────────────────────────────────────────────
vim.g.vimtex_view_method   = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'

-- ─── General settings ─────────────────────────────────────────────────────────
vim.o.guifont       = 'FiraCode Nerd Font:h19'
vim.o.number        = true
vim.o.relativenumber = true
vim.o.clipboard     = 'unnamedplus'
vim.o.virtualedit   = 'onemore'

vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true

vim.opt.listchars   = { space = '⋅', tab = '▸ ', eol = '↴' }
vim.opt.list        = false

-- ─── Auto-open nvim-tree when opening a directory ─────────────────────────────
vim.cmd [[
  autocmd VimEnter * if isdirectory(expand('%')) | NvimTreeOpen | endif
]]

-- ─── Keybindings ──────────────────────────────────────────────────────────────
local opts = { noremap = true, silent = true }

-- Copy / paste (system clipboard)
vim.api.nvim_set_keymap('v', '<leader>c', '"+y',  opts)
vim.api.nvim_set_keymap('n', '<leader>c', '"+yy', opts)
vim.api.nvim_set_keymap('n', '<leader>v', '"+p',  opts)
vim.api.nvim_set_keymap('v', '<leader>v', '"+p',  opts)

-- Toggle listchars
vim.api.nvim_set_keymap('n', '<leader>ts', ':set list!<CR>', opts)

-- Toggle relative line numbers
vim.api.nvim_set_keymap('n', '<leader>ln', ':set relativenumber!<CR>', opts)

-- File explorer
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts)

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>",              opts)
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>",               opts)
vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", opts)

-- Vimtex
vim.api.nvim_set_keymap('n', '<leader>lc', '<cmd>VimtexCompile<CR>',     opts)
vim.api.nvim_set_keymap('n', '<leader>lv', '<cmd>VimtexView<CR>',        opts)
vim.api.nvim_set_keymap('n', '<leader>lq', '<cmd>VimtexCompileStop<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>le', '<cmd>VimtexErrors<CR>',      opts)

-- Spellcheck
vim.api.nvim_set_keymap('n', '<leader>sc', '<cmd>setlocal spell spelllang=de_20<CR>', opts)
