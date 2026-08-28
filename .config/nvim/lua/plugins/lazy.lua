-- Install lazylazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 
    "onsails/lspkind.nvim",
    config = function()
      local lspkind = require("lspkind")
      lspkind.init({
        symbol_map = {
          Supermaven = "",
        },
      })
      vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {fg ="#6CC644"})
    end
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end
  },

  {
    "ziontee113/icon-picker.nvim",
    lazy = true,
    cmd = { "IconPickerNormal", "IconPickerYank" },
    config = function()
      require("icon-picker").setup({ disable_legacy_commands = true })
    end
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  { 'folke/zen-mode.nvim', lazy = true, cmd = "ZenMode" },

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    requires = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        sort = { sorter = "case_sensitive" },
        view = {
          width = 30,
          adaptive_size = true,
        },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      }
    end,
  },

  { "tpope/vim-surround" },

  { "ryanoasis/vim-devicons" },

  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'
      dashboard.section.header.val = {
        [[        ___                     ___          _____         ]],
        [[       /  /\      ___          /__/\        /  /::\        ]],
        [[      /  /:/_    /  /\         \  \:\      /  /:/\:\       ]],
        [[     /  /:/ /\  /  /:/          \  \:\    /  /:/  \:\      ]],
        [[    /  /:/ /:/ /__/::\      _____\__\:\  /__/:/ \__\:|     ]],
        [[   /__/:/ /:/  \__\/\:\__  /__/::::::::\ \  \:\ /  /:/     ]],
        [[   \  \:\/:/      \  \:\/\ \  \:\~~\~~\/  \  \:\  /:/      ]],
        [[    \  \::/        \__\::/  \  \:\  ~~~    \  \:\/:/       ]],
        [[     \  \:\        /__/:/    \  \:\         \  \::/        ]],
        [[      \  \:\       \__\/      \  \:\         \__\/         ]],
        [[       \__\/                   \__\/                       ]],
        [[        ___                       ___           ___        ]],
        [[       /  /\                     /  /\         /__/\       ]],
        [[      /  /:/_                   /  /::\       _\_ \:\      ]],
        [[     /  /:/ /\  ___     ___    /  /:/\:\     /__/\ \:\     ]],
        [[    /  /:/ /:/ /__/\   /  /\  /  /:/  \:\   _\_ \:\ \:\    ]],
        [[   /__/:/ /:/  \  \:\ /  /:/ /__/:/ \__\:\ /__/\ \:\ \:\   ]],
        [[   \  \:\/:/    \  \:\  /:/  \  \:\ /  /:/ \  \:\ \:\/:/   ]],
        [[    \  \::/      \  \:\/:/    \  \:\  /:/   \  \:\ \::/    ]],
        [[     \  \:\       \  \::/      \  \:\/:/     \  \:\/:/     ]],
        [[      \  \:\       \__\/        \  \::/       \  \::/      ]],
        [[       \__\/                     \__\/         \__\/       ]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", "<cmd>ene <CR>"),
        dashboard.button("SPC f o", "󰈞  Recently opened files"),
        dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
      }
      local handle = io.popen('fortune')
      local fortune = handle:read("*a")
      handle:close()
      dashboard.section.footer.val = fortune

      dashboard.config.opts.noautocmd = true

      vim.cmd [[autocmd User AlphaReady echo 'ready']]

      alpha.setup(dashboard.config)
    end
  },

  {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Downloads" },
      }
    end
  },


  {
    'rmagatti/goto-preview',
    config = function() require('goto-preview').setup {} end
  },

  { "catppuccin/nvim",         as = "catppuccin" },

  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  },

  {
    'terrortylor/nvim-comment',
    config = function()
      require("nvim_comment").setup({ create_mappings = false })
    end
  },

  { 'akinsho/bufferline.nvim', version = "*",    dependencies = 'nvim-tree/nvim-web-devicons' },

  -- { "chrisgrieser/nvim-spider" },

  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },

        -- messages = {
        --   -- This disables the timestamps that are causing the error
        --   enabled = true,
        --   view = "notify",
        --   view_error = "notify",
        --   view_warn = "notify",
        --   view_history = "messages",
        --   view_search = "virtualtext",
        --   -- Set this to false to disable the timestamp function that's causing errors
        --   view_timestamps = false,
        -- },
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
                { find = '%d fewer lines' },
                { find = '%d more lines' },
              },
            },
            opts = { skip = true },
          }
        },
        presets = {
          bottom_search = true,         -- use a classic bottom cmdline for search
          command_palette = true,       -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,
          lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
      })
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },


  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    }
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

  -- minuet-ai
  -- {
  --   'milanglacier/minuet-ai.nvim',
  --   config = function()
  --     require('minuet').setup {
  --       virtualtext = {
  --         auto_trigger_ft = {},
  --         keymap = {
  --           -- accept whole completion
  --           accept = '<A-A>',
  --           -- accept one line
  --           accept_line = '<A-a>',
  --           -- accept n lines (prompts for number)
  --           -- e.g. "A-z 2 CR" will accept 2 lines
  --           accept_n_lines = '<A-z>',
  --           -- Cycle to prev completion item, or manually invoke completion
  --           prev = '<A-[>',
  --           -- Cycle to next completion item, or manually invoke completion
  --           next = '<A-]>',
  --           dismiss = '<A-e>',
  --         },
  --       },
  --       lsp = {
  --         enabled_ft = { 'toml', 'lua', 'cpp' },
  --         -- Enables automatic completion triggering using `vim.lsp.completion.enable`
  --         enabled_auto_trigger_ft = { 'cpp', 'lua' },
  --       },
  --       provider = 'claude',
  --       provider_options = {
  --         -- claude = {
  --         --   max_tokens = 512,
  --         --   -- model = 'claude-3-7-sonnet-20250219 ',
  --         --   model = 'claude-3-5-haiku-20241022',
  --         --   system = "see [Prompt] section for the default value",
  --         --   few_shots = "see [Prompt] section for the default value",
  --         --   chat_input = "See [Prompt Section for default value]",
  --         --   stream = true,
  --         --   api_key = 'ANTHROPIC_API_KEY',
  --         --   optional = {
  --         --     -- pass any additional parameters you want to send to claude request,
  --         --     -- e.g.
  --         --     -- stop_sequences = nil,
  --         --   },
  --         -- },
  --         claude = {
  --           model = 'claude-3-5-haiku-20241022', -- Use Claude Haiku or another model
  --           system = nil,                        -- This will use the default system prompt
  --           few_shots = nil,                     -- This will use the default few shot examples
  --           chat_input = nil,                    -- This will use the default chat input
  --           stream = true,                       -- Enable streaming for faster results
  --           api_key = 'ANTHROPIC_API_KEY',       -- Use the environment variable
  --           optional = {
  --             -- Add any additional parameters here if needed
  --           },
  --         },
  --       }
  --     }
  --   end,
  -- },
  -- { 'nvim-lua/plenary.nvim' },
  -- -- optional, if you are using virtual-text frontend, nvim-cmp is not
  -- -- required.
  -- {
  --   'hrsh7th/nvim-cmp',
  --   dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  --   -- config = function()
  --   --   require('cmp').setup {
  --   --     -- mapping = {
  --   --     --   ["<A-y>"] = require('minuet').make_cmp_map()
  --   --     --   -- and your other keymappings
  --   --     -- },
  --   --     sources = {
  --   --       {
  --   --         -- Include minuet as a source to enable autocompletion
  --   --         { name = 'minuet' },
  --   --         -- and your other sources
  --   --       }
  --   --     },
  --   --     performance = {
  --   --       -- It is recommended to increase the timeout duration due to
  --   --       -- the typically slower response speed of LLMs compared to
  --   --       -- other completion sources. This is not needed when you only
  --   --       -- need manual completion.
  --   --       fetching_timeout = 2000,
  --   --     },
  --   --   }
  --   -- end,
  -- },
  -- AI Code Completion
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<C-l>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { 
          gitcommit = true,
          markdown = true,
        },
        color = {
          suggestion_color = "#808080",
          cterm = 244,
        },
        log_level = "info",
        disable_inline_completion = false,
        disable_keymaps = false,
      })
    end,
  },

  -- REPL
  {
    'milanglacier/yarepl.nvim',
    config = function()
      require('yarepl').setup {
        metas = { aider = require('yarepl.extensions.aider').create_aider_meta() }
      }
    end
  },

  -- Fancier statusline
  { 'nvim-lualine/lualine.nvim' },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim',        branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-telescope/telescope-symbols.nvim' },

  { "folke/twilight.nvim", lazy = true, cmd = "Twilight", opts = {} },

  -- Treesitter playground (duplicate treesitter removed)
  { "nvim-treesitter/playground", lazy = true },

  -- line indent pretty
  { "lukas-reineke/indent-blankline.nvim",  main = "ibl",     opts = {} },
  {
    "mbbill/undotree",
    lazy = true,
    cmd = "UndotreeToggle"
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },


})
