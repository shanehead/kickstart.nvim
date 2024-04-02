local icons = require('utils.icons').kinds
local colors = require('onedarkpro.helpers').get_colors()

local lspkind_opts = {
  mode = 'symbol',
  symbol_map = icons,
  menu = {
    nvim_lsp = '(LSP)',
    codeium = '(Codeium)',
    ultisnips = '(US)',
    nvim_lua = '(Lua)',
    path = '(Path)',
    buffer = '(Buffer)',
    emoji = '(Emoji)',
    omni = '(Omni)',
  },
}

local hlgroups = {
  CmpItemAbbr = { fg = colors.white },
  CmpItemAbbrMatch = { fg = colors.blue, bold = true },
  CmpDoc = { bg = colors.darker_black },
  CmpDocBorder = { fg = colors.darker_black, bg = colors.darker_black },
  CmpBorder = { fg = colors.darker_black, bg = colors.darker_black },
  CmpPmenu = { bg = colors.darker_black },
  CmpSel = { bg = colors.selection, bold = true },
}

return { -- Autocompletion
  {
    'onsails/lspkind.nvim',
    lazy = true,
    opts = lspkind_opts,
    enabled = true,
    config = function(_, opts)
      require('lspkind').init(opts)
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        lazy = true,
        build = vim.fn.has 'win32' == 0 and
        "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp" or nil,
        dependencies = { 'rafamadriz/friendly-snippets' },
        opts = {
          history = true,
          delete_check_events = 'TextChanged',
          region_check_events = 'CursorMoved',
        },
        config = function(_, opts)
          if opts then
            require('luasnip').config.setup(opts)
          end
        end,
      },
      {
        'Exafunction/codeium.nvim',
        cmd = 'Codeium',
        build = ':Codeium Auth',
        opts = {},
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      luasnip.config.setup {}

      local function has_words_before()
        local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      local function border(hl_name)
        return {
          { '╭', hl_name },
          { '─', hl_name },
          { '╮', hl_name },
          { '│', hl_name },
          { '╯', hl_name },
          { '─', hl_name },
          { '╰', hl_name },
          { '│', hl_name },
        }
      end

      for hl_name, hl in pairs(hlgroups) do
        vim.api.nvim_set_hl(0, hl_name, hl)
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        formatting = {
          expandable_indicator = true,
          fields = { 'abbr', 'kind', 'menu' },
          format = lspkind.cmp_format(lspkind_opts),
        },
        completion = { completeopt = 'menu,menuone,noselect' },
        window = {
          completion = {
            border = border 'CmpBorder',
            side_padding = 1,
            winhighlight = 'Normal:CmpPmenu,CursorLine:CmpSel,Search:None',
            scrollbar = false,
          },
          documentation = {
            border = border 'CmpDocBorder',
            winhighlight = 'Normal:CmpDoc',
          },
        },

        mapping = cmp.mapping.preset.insert {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- For more advanced luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'codeium' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      }
    end,
  },
}
