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

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
    'folke/tokyonight.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- You can configure highlights by doing something like
      --vim.cmd.hi 'Comment gui=none'
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
        local toggle = function()
          t:toggle()
        end
        vim.keymap.set({ 'n', 't', 'i' }, "<C-'>", toggle, { desc = 'Toggle terminal', buffer = t.bufnr })
        vim.keymap.set({ 'n', 't', 'i' }, '<F7>', toggle, { desc = 'Toggle terminal', buffer = t.bufnr })
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
}
