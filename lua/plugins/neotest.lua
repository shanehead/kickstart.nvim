return {
  { 'mfussenegger/nvim-dap' },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = 'mfussenegger/nvim-dap',
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.after.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.after.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
    },
    config = function(_)
      local path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(path)
    end,
  },

  {
    'nvim-neotest/neotest',
    ft = { 'rust', 'python', 'go' },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-go',
      --   {
      --     'folke/neodev.nvim',
      --     opts = {},
      --   },
    },
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      local rustaceanvim_avail, rustaceanvim = pcall(require, 'rustaceanvim.neotest')
      if rustaceanvim_avail then
        table.insert(opts.adapters, rustaceanvim)
      end

      return {
        -- your neotest config here
        log_level = vim.log.levels.INFO,
        adapters = {
          require 'neotest-python' {
            dap = { justMyCode = false },
          },
        },
      }
    end,
    config = function(_, opts)
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace 'neotest'
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)
      require('neotest').setup(opts)
    end,
  },
  {
    'andythigpen/nvim-coverage',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/neotest',
      'nvim-neotest/neotest-python',
    },
    config = function()
      require('coverage').setup {
        commands = true,
        auto_reload = true,
        lang = {
          python = {
            -- todo: Get from pyproject.toml if present
            coverage_file = './build/coverage',
            --coverage_command = "coverage json --data-file=./build/coverage -q -o -",
          },
        },
      }
    end,
  },
}
