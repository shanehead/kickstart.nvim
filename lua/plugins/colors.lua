return {
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
}
