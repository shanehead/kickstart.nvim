local function get_telescope_opts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, _)
      local actions = require 'telescope.actions'
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if filename == nil then
          filename = selection[1]
        end
        -- any way to open the file without triggering auto-close event of neo-tree?
        require('neo-tree.sources.filesystem').navigate(state, state.path, filename, function() end)
      end)
      return true
    end,
  }
end

return {
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup {
        icons = {
          group = '', -- symbol prepended to a group
        },
        window = {
          winblend = 5,
        },
      }
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = true,
      keywords = {
        TODO = { alt = { 'todo' } },
        NOTE = { alt = { 'note' } },
      },
    },
  },
  {
    'harrisoncramer/gitlab.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'stevearc/dressing.nvim', -- Recommended but not required. Better UI for pickers.
      enabled = true,
    },
    build = function()
      require('gitlab.server').build(true)
    end, -- Builds the Go binary
    config = function()
      require('gitlab').setup {
        debug = { go_request = false, go_response = false }, -- Which values to log
      }
    end,
  },
  {
    'allaman/emoji.nvim',
    version = '1.0.0', -- optionally pin to a tag
    -- ft = "markdown", -- adjust to your needs
    event = { 'BufEnter', 'InsertEnter' },
    dependencies = {
      -- optional for nvim-cmp integration
      'hrsh7th/nvim-cmp',
      -- optional for telescope integration
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      enable_cmp_integration = true,
    },
  },

  {
    'nvim-pack/nvim-spectre',
    event = { 'BufEnter', 'InsertEnter' },
  },
  {
    '2kabhishek/nerdy.nvim',
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = 'Nerdy',
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
  },
  {
    'Saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    init = function()
      vim.api.nvim_create_autocmd('BufRead', {
        group = vim.api.nvim_create_augroup('CmpSourceCargo', { clear = true }),
        pattern = 'Cargo.toml',
        callback = function()
          require('cmp').setup.buffer { sources = { { name = 'crates' } } }
          require 'crates'
        end,
      })
    end,
    opts = {
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
    },
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      local rustaceanvim_avail, rustaceanvim = pcall(require, 'rustaceanvim.neotest')
      if rustaceanvim_avail then
        table.insert(opts.adapters, rustaceanvim)
      end
    end,
  },
  {
    'lukas-reineke/headlines.nvim',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup {
        markdown = {
          headline_highlights = { 'Headline1', 'Headline2', 'Headline3', 'Headline4' },
          fat_headlines = true,
          fat_headline_upper_string = '▃',
          fat_headline_lower_string = '',
        },
      }
      vim.api.nvim_set_hl(0, 'Headline1', { fg = '#6893bf', bg = '#2b3d4f', italic = true, bold = true })
      vim.api.nvim_set_hl(0, 'Headline2', { fg = '#80a665', bg = '#3d4f2f', italic = false, bold = true })
      vim.api.nvim_set_hl(0, 'Headline3', { fg = '#4c9a91', bg = '#224541', italic = false })
      vim.api.nvim_set_hl(0, 'Headline4', { fg = '#c99076', bg = '#66493c', italic = false })
      vim.api.nvim_set_hl(0, 'CodeBlock', { bg = '#444444' })
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {
      filesystem = {
        group_empty_dirs = false,
      },
      window = {
        mappings = {
          F = 'find_in_path',
        },
      },
      commands = {
        find_in_path = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require('telescope.builtin').live_grep(get_telescope_opts(state, path))
        end,
      },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    cmd = { 'ToggleTerm', 'TermExec' },
    opts = {
      highlights = {
        Normal = { link = 'Normal' },
        NormalNC = { link = 'NormalNC' },
        NormalFloat = { link = 'NormalFloat' },
        FloatBorder = { link = 'FloatBorder' },
        StatusLine = { link = 'StatusLine' },
        StatusLineNC = { link = 'StatusLineNC' },
        WinBar = { link = 'WinBar' },
        WinBarNC = { link = 'WinBarNC' },
      },
      size = 10,
      on_create = function()
        vim.opt.foldcolumn = '0'
        vim.opt.signcolumn = 'no'
      end,
      shading_factor = 2,
      direction = 'float',
      float_opts = { border = 'rounded' },
    },
  },
  {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup {
        log_level = 'error',
        auto_save_eanbled = true,
        auto_restore_enabled = true,
        pre_save_cmds = { 'Neotree close' },
      }
    end,
  },
  {
    'olimorris/onedarkpro.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('onedarkpro').setup {
        styles = {
          comments = 'italic',
          keywords = 'bold,italic',
          functions = 'bold,italic',
          parameters = 'bold',
        },
        colors = {
          onedark_vivid = {
            bg = '#0c121c',
          },
        },

        highlights = {
          TelescopePromptTitle = {
            fg = '${purple}',
            bold = true,
          },
          TelescopePreviewTitle = {
            fg = '${purple}',
            bold = true,
          },
          TelescopeResultsTitle = {
            fg = '${purple}',
            bold = true,
          },
        },
        plugins = {
          -- todo: Not sure this is really needed, I think these are on by default
          telescope = true,
          nvim_cmp = true,
          lsp_semantic_tokens = true,
          neotest = true,
          neo_tree = true,
          nvim_dap = true,
          nvim_dap_ui = true,
          nvim_lsp = true,
          trouble = true,
          which_key = true,
        },
      }
      vim.cmd 'colorscheme onedark_vivid'
    end,
  },
  {
    'epwalsh/obsidian.nvim',
    -- the obsidian vault in this default config  ~/obsidian-vault
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
    -- event = { "bufreadpre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
    event = {

      'BufReadPre ' .. vim.fn.expand '~' .. '/Documents/Obsidian/**.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/Documents/Obsidian/**.md',
      'BufReadPre ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/**.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/**.md',
    },
    keys = {
      {
        'gf',
        function()
          if require('obsidian').util.cursor_on_markdown_link() then
            return '<cmd>ObsidianFollowLink<CR>'
          else
            return 'gf'
          end
        end,
        noremap = false,
        expr = true,
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      --dir = vim.env.HOME .. '/Documents/Obsidian', -- specify the vault location. no need to call 'vim.fn.expand' here
      dir = vim.fn.expand '~' .. '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian',
      use_advanced_uri = true,
      finder = 'telescope.nvim',
      mappings = {},

      templates = {
        subdir = 'templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
      },
      ui = {
        enable = true, -- set to false to disable all additional syntax features
        update_debounce = 200, -- update delay after a text change (in milliseconds)
        -- Define how various check-boxes are displayed
        checkboxes = {
          -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
          [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
          -- Replace the above with this if you don't have a patched font:
          -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
          -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

          -- You can also add more custom ones...
        },
        -- Use bullet marks for non-checkbox lists.
        bullets = { char = '•', hl_group = 'ObsidianBullet' },
        external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
        -- Replace the above with this if you don't have a patched font:
        -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = 'ObsidianRefText' },
        highlight_text = { hl_group = 'ObsidianHighlightText' },
        tags = { hl_group = 'ObsidianTag' },
        block_ids = { hl_group = 'ObsidianBlockID' },
        hl_groups = {
          -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
          ObsidianTodo = { bold = true, fg = '#f78c6c' },
          ObsidianDone = { bold = true, fg = '#89ddff' },
          ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
          ObsidianTilde = { bold = true, fg = '#ff5370' },
          ObsidianBullet = { bold = true, fg = '#89ddff' },
          ObsidianRefText = { underline = true, fg = '#c792ea' },
          ObsidianExtLinkIcon = { fg = '#c792ea' },
          ObsidianTag = { italic = true, fg = '#89ddff' },
          ObsidianBlockID = { italic = true, fg = '#89ddff' },
          ObsidianHighlightText = { bg = '#75662e' },
        },
      },

      note_frontmatter_func = function(note)
        -- This is equivalent to the default frontmatter function.
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and require('obsidian').util.table_length(note.metadata) > 0 then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,

      follow_url_func = vim.ui.open,
    },
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<leader>c',
        function()
          local bd = require('mini.bufremove').delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.bufname()), '&Yes\n&No\n&Cancel')
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = 'Delete Buffer',
      },
      {
        '<leader>bD',
        function()
          require('mini.bufremove').delete(0, true)
        end,
        desc = 'Delete Buffer (Force)',
      },
    },
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      require('nvim-navic').setup {
        lsp = {
          auto_attach = true,
        },
      }
    end,
  },
  -- {
  --   'echasnovski/mini.surround',
  --   version = false,
  --   config = function()
  --     require('mini.surround').setup {
  --       -- These are the default mappings
  --       mappings = {
  --         add = 'sa', -- Add surrounding in Normal and Visual modes
  --         delete = 'sd', -- Delete surrounding
  --         find = 'sf', -- Find surrounding (to the right)
  --         find_left = 'sF', -- Find surrounding (to the left)
  --         highlight = 'sh', -- Highlight surrounding
  --         replace = 'sr', -- Replace surrounding
  --         update_n_lines = 'sn', -- Update `n_lines`
  --
  --         suffix_last = 'l', -- Suffix to search with "prev" method
  --         suffix_next = 'n', -- Suffix to search with "next" method
  --       },
  --     }
  --   end,
  -- },
  {
    'numToStr/Navigator.nvim',
    config = function()
      require('Navigator').setup {
        mux = 'auto',
      }
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>lf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
		-- stylua: ignore
		keys = {
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
  },
  {
    'folke/trouble.nvim',
    branch = 'dev', -- IMPORTANT!
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xq',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      cmdline = {
        enabled = true,
        view = 'cmdline',
      },

      routes = {
        {
          filter = {
            --todo: Not sure how the "pattern" works here. Like regex?
            any = {
              { event = 'msg_show', kind = '' },
              { event = 'msg_show', find = 'E486' },
              { event = 'msg_show', find = 'line less' },
              { event = 'msg_show', find = 'yanked' },
              { event = 'msg_show', find = 'changes?;' },
              { event = 'msg_show', find = 'more lines?;' },
              { event = 'msg_show', find = 'fewer lines?;' },
            },
          },
          opts = { skip = true },
        },
      },

      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
  {
    'windwp/nvim-autopairs',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require('nvim-autopairs').setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    lazy = true,
    main = 'window-picker',
    config = function()
      require('window-picker').setup {
        picker_config = { statusline_winbar_picker = { use_winbar = 'always' } },
      }
      local colors = require('onedarkpro.helpers').get_preloaded_colors()
      vim.api.nvim_set_hl(0, 'WindowPickerWinBar', { fg = colors.red, bg = colors.black })
      vim.api.nvim_set_hl(0, 'WindowPickerWinBarNC', { fg = colors.red, bg = colors.black })
    end,
  },
}
