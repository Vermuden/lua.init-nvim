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

-- Set leader before lazy so all mappings pick it up
vim.g.mapleader = ','

require('lazy').setup({

  -- Colorscheme
  'folke/tokyonight.nvim',

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then return end
      configs.setup {
        ensure_installed = { "c", "lua", "python", "svelte", "javascript",
                             "typescript", "rust", "bash", "latex" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  },

  -- Vimtex (only loads for .tex files)
  {
    'lervag/vimtex',
    ft = { 'tex' },
  },

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
            '--line-number', '--column', '--smart-case', '--word-regexp',
          },
          prompt_prefix   = '> ',
          selection_caret = '> ',
          path_display    = { 'smart' },
        },
        extensions = {
          fzf = {
            fuzzy                   = false,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = 'smart_case',
          },
        },
      }
      require('telescope').load_extension('fzf')
    end,
  },

  -- Mason: installs LSP servers inside Neovim
  -- Run :MasonInstall lua-language-server typescript-language-server
  --   rust-analyzer texlab svelte-language-server
  {
    'mason-org/mason.nvim',
    opts = {},
  },

  -- LSP
  'neovim/nvim-lspconfig',

  -- Markdown → PDF (uses pandoc + zathura)
  {
    'arminveres/md-pdf.nvim',
    ft = { 'markdown' },
    config = function()
      require('md-pdf').setup({
        preview_cmd = function() return 'zathura' end,
      })
    end,
  },

  -- File explorer (updated org)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.g.loaded_netrw       = 1
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
        theme         = 'tokyonight',
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
          ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-e>'] = cmp.mapping.abort(),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
    end,
  },

}, {
  checker = { enabled = false },
})

-- ─── Colorscheme ──────────────────────────────────────────────────────────────
vim.cmd [[colorscheme tokyonight]]

-- ─── Vimtex ───────────────────────────────────────────────────────────────────
vim.g.vimtex_view_method    = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'

-- ─── General settings ─────────────────────────────────────────────────────────
vim.o.guifont        = 'FiraCode Nerd Font:h19'
vim.o.number         = true
vim.o.relativenumber = true
vim.o.clipboard      = 'unnamedplus'
vim.o.virtualedit    = 'onemore'

vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true

vim.opt.listchars = { space = '⋅', tab = '▸ ', eol = '↴' }
vim.opt.list      = false

-- ─── LSP (Neovim 0.11+ native API) ───────────────────────────────────────────
-- cmp capabilities shared across all servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library       = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
    },
  },
})

vim.lsp.config('ts_ls', {
  capabilities = capabilities,
})

vim.lsp.config('rust_analyzer', {
  capabilities = capabilities,
})

vim.lsp.config('texlab', {
  capabilities = capabilities,
})

vim.lsp.config('svelte', {
  capabilities = capabilities,
})

vim.lsp.enable({ 'lua_ls', 'ts_ls', 'rust_analyzer', 'texlab', 'svelte' })

-- LSP keymaps (set on attach so they only apply in LSP buffers)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local o = { buffer = event.buf }
    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,      o)
    vim.keymap.set('n', 'gd',         vim.lsp.buf.definition, o)
    vim.keymap.set('n', 'gr',         vim.lsp.buf.references, o)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,     o)
  end,
})

-- ─── Auto-open nvim-tree for directories ──────────────────────────────────────
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

-- Toggle listchars / relative numbers
vim.api.nvim_set_keymap('n', '<leader>ts', ':set list!<CR>',         opts)
vim.api.nvim_set_keymap('n', '<leader>ln', ':set relativenumber!<CR>', opts)

-- File explorer
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts)

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<CR>",               opts)
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<CR>",                opts)
vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", opts)

-- Vimtex
vim.api.nvim_set_keymap('n', '<leader>lc', '<cmd>VimtexCompile<CR>',     opts)
vim.api.nvim_set_keymap('n', '<leader>lv', '<cmd>VimtexView<CR>',        opts)
vim.api.nvim_set_keymap('n', '<leader>lq', '<cmd>VimtexCompileStop<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>le', '<cmd>VimtexErrors<CR>',      opts)

-- Markdown → PDF
vim.api.nvim_set_keymap('n', '<leader>mc', "<cmd>lua require('md-pdf').convert_md_to_pdf()<CR>", opts)

-- Spellcheck
vim.api.nvim_set_keymap('n', '<leader>sc', '<cmd>setlocal spell spelllang=de_20<CR>', opts)

-- ─── Installation notes ───────────────────────────────────────────────────────
-- System deps:  sudo dnf install pandoc latexmk texlive-scheme-full zathura zathura-pdf-mupdf wl-clipboard
-- LSP servers:  :MasonInstall lua-language-server typescript-language-server rust-analyzer texlab svelte-language-server
