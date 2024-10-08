local icons = require('utils.icons').misc
return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'olimorris/onedarkpro.nvim',
    },
    config = function()
      local colors = require('onedarkpro.helpers').get_colors()

      local theme = {
        normal = {
          a = { fg = colors.bg, bg = colors.green, gui = 'bold' },
          b = { fg = colors.fg, bg = colors.gray3, gui = 'bold' },
          c = { fg = colors.blue, bg = colors.gray2, gui = 'italic,bold' },
          y = { fg = colors.blue, bg = colors.gray3, gui = 'bold' },
          z = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
        },
        command = { a = { fg = colors.bg, bg = colors.yellow, gui = 'bold' } },
        insert = { a = { fg = colors.bg, bg = colors.blue, gui = 'bold' } },
        visual = { a = { fg = colors.bg, bg = colors.purple, gui = 'bold' } },
        terminal = { a = { fg = colors.bg, bg = colors.cyan, gui = 'bold' } },
        replace = { a = { fg = colors.bg, bg = colors.red1, gui = 'bold' } },
        inactive = {
          a = { fg = colors.gray1, bg = colors.bg, gui = 'bold' },
          b = { fg = colors.gray1, bg = colors.bg },
          c = { fg = colors.gray1, bg = colors.gray2 },
        },
      }

      local clients_lsp = function()
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
          return ''
        end

        local c = {}
        for _, client in pairs(clients) do
          table.insert(c, client.name)
        end
        return icons.ActiveLSP .. ' ' .. table.concat(c, ', ')
      end

      require('lualine').setup {
        options = {
          theme = theme,
          component_separators = '',
          section_separators = { left = '', right = '' },
          disabled_filetypes = { 'neo-tree', 'lspinfo' },
          ignore_focus = { 'lspinfo', 'neo-tree', 'telescope' },
        },
        globalstatus = true,
        sections = {
          lualine_a = {
            { 'mode', separator = { left = ' ', right = '' }, icon = '' },
          },
          lualine_b = {
            {
              'filetype',
              icon_only = true,
              padding = { left = 1, right = 0 },
            },
            {
              'filename',
              file_status = true,
              path = 1,
              shorting_target = 50,
              symbols = { modified = icons.FileModified, readonly = icons.FileReadOnly },
            },
          },
          lualine_c = {
            {
              'branch',
              icon = icons.GitBranch,
            },
            {
              'diff',
              symbols = { added = icons.GitAdd .. ' ', modified = icons.GitChange .. ' ', removed = icons.GitDelete .. ' ' },
              colored = true,
            },
          },
          lualine_x = {
            {
              'diagnostics',
              symbols = {
                error = icons.DiagnosticError .. ' ',
                warn = icons.DiagnosticWarn .. ' ',
                info = icons.DiagnosticInfo .. ' ',
                hint = icons.DiagnosticHint .. ' ',
              },
              update_in_insert = true,
            },
          },
          lualine_y = { clients_lsp },
          lualine_z = {
            { 'location', separator = { left = '', right = ' ' }, icon = { icons.ScrollText, align = 'right' } },
          },
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'location' },
        },

        tabline = {
          lualine_a = {
            {
              'buffers',
              separator = { left = '', right = '' },
              right_padding = 2,
              symbols = { alternate_file = '' },
              buffers_color = {
                -- Same values as the general color option can be used here.
                active = 'lualine_a_insert', -- Color for active buffer.
                inactive = 'lualine_b_inactive', -- Color for inactive buffer.
              },
            },
          },
        },
        extensions = { 'toggleterm', 'trouble', 'neo-tree', 'lazy', 'nvim-dap-ui' },
      }
    end,
  },
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    config = function()
      local colors = require('onedarkpro.helpers').get_colors()
      local navic = require 'nvim-navic'
      require('incline').setup {
        window = {
          padding = { left = 0, right = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          local ft_icon, ft_color = require('nvim-web-devicons').get_icon_color(filename)
          local modified = vim.bo[props.buf].modified and 'bold,italic' or 'bold'

          local function get_git_diff()
            local git_icons = { removed = icons.GitDelete, changed = icons.GitChange, added = icons.GitAdd }
            local signs = vim.b[props.buf].gitsigns_status_dict
            local labels = {}
            if signs == nil then
              return labels
            end
            for name, icon in pairs(git_icons) do
              if tonumber(signs[name]) and signs[name] > 0 then
                table.insert(labels, { icon .. ' ' .. signs[name] .. ' ', group = 'Diff' .. name })
              end
            end
            if #labels > 0 then
              table.insert(labels, 1, ' ')
              table.insert(labels, { icons.InclineSeparator })
            end
            return labels
          end

          local function get_diagnostic_label()
            local diag_icons = {
              error = icons.DiagnosticError,
              warn = icons.DiagnosticWarn,
              info = icons.DiagnosticInfo,
              hint = icons.DiagnosticHint,
            }
            local labels = {}

            for severity, icon in pairs(diag_icons) do
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
              if n > 0 then
                table.insert(labels, { icon .. ' ' .. n .. ' ', group = 'DiagnosticSign' .. severity })
              end
            end
            if #labels > 0 then
              table.insert(labels, 1, ' ')
              table.insert(labels, { icons.InclineSeparator })
            end
            return labels
          end

          local buffer = {
            { get_diagnostic_label() },
            { get_git_diff() },
            { (ft_icon and ' ' .. ft_icon or '') .. ' ', guifg = ft_color, guibg = colors.blue },
            { filename .. ' ', gui = modified, guifg = colors.bg, guibg = colors.blue },
          }

          if props.focused then
            for _, item in ipairs(navic.get_data(props.buf) or {}) do
              table.insert(buffer, {
                { ' > ', group = 'NavicSeparator' },
                { item.icon, group = 'NavicIcons' .. item.type },
                { item.name, group = 'NavicText' },
              })
            end
          end

          return buffer
        end,
      }
    end,
  },
}
