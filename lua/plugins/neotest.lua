return {
  {
    'nvim-neotest/neotest',
    ft = { 'rust', 'python' },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
      {
        'folke/neodev.nvim',
        opts = {},
      },
    },
    opts = function()
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
            coverage_file = './build/coverage',
            --coverage_command = "coverage json --data-file=./build/coverage -q -o -",
          },
        },
      }
    end,
  },
}
