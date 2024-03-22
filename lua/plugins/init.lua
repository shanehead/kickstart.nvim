local function get_telescope_opts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, map)
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
        require('neo-tree.sources.filesystem').navigate(state, state.path, filename)
      end)
      return true
    end,
  }
end

return {
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',    opts = {} },

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

  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
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
    'christoomey/vim-tmux-navigator',
    lazy = false,
    event = 'BufReadPre',
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
      ---@param t Terminal
      on_create = function(t)
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
            -- telescope_prompt = "require('onedarkpro.helpers').darken('#0c121c', 1)",
            -- telescope_results = "require('onedarkpro.helpers').darken('#0c121c', 1)",
            -- telescope_preview = "require('onedarkpro.helpers').darken('#0c121c', 1)",
            -- telescope_selection = "require('onedarkpro.helpers').darken('#0c121c', 1)",
          },
        },

        -- highlights = {
        --   -- Telescope
        --   -- TelescopeBorder = {
        --   --   fg = '${telescope_results}',
        --   --   bg = '${telescope_results}',
        --   -- },
        --   TelescopePromptPrefix = {
        --     fg = '${purple}',
        --   },
        --   TelescopePromptBorder = {
        --     --fg = '${telescope_prompt}',
        --     bg = '${telescope_prompt}',
        --   },
        --   TelescopePromptCounter = { fg = '${fg}' },
        --   TelescopePromptNormal = { fg = '${fg}', bg = '${telescope_prompt}' },
        --   TelescopePromptTitle = {
        --     fg = '${telescope_prompt}',
        --     bg = '${purple}',
        --   },
        --   TelescopePreviewTitle = {
        --     fg = '${telescope_results}',
        --     bg = '${green}',
        --   },
        --   TelescopeResultsTitle = {
        --     fg = '${blue}',
        --     bg = '${telescope_results}',
        --   },
        --   TelescopeMatching = { fg = '${blue}' },
        --   TelescopeNormal = { bg = '${telescope_results}' },
        --   TelescopeSelection = { fg = '${purple}', bg = '${telescope_selection}' },
        --   TelescopePreviewNormal = { bg = '${telescope_preview}' },
        --   -- TelescopePreviewBorder = { fg = '${telescope_preview}', bg = '${telescope_preview}' },
        -- },
        plugins = {
          telescope = true,
        },
        -- highlights = {
        --   ["@parameter"] = { fg = "${white}" },
        -- },
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
      dir = vim.env.HOME .. '/Documents/Obsidian', -- specify the vault location. no need to call 'vim.fn.expand' here
      use_advanced_uri = true,
      finder = 'telescope.nvim',
      mappings = {},

      templates = {
        subdir = 'templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
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
        '<leader>bd',
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
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
}
