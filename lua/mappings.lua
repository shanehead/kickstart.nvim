local wk = require 'which-key'
local gitlab = require 'gitlab'
local builtin = require 'telescope.builtin'
local icons = require('utils.icons').misc

-- Normal
local maps = {
  n = {
    { 'gb', '<C-t>', desc = 'Go Back (Previous Tag)' },

    { '<leader>q', '<cmd>confirm qa<cr>', desc = 'Quit' },
    { '<leader>w', '<cmd>w<cr>', desc = 'Save', icon = icons.Save },

    -- Clear search on esc
    { '<esc>', '<cmd>noh<cr><esc>', desc = 'Escape and Clear hlsearch' },

    -- Sizing windows
    { '|', '<cmd>vsplit<cr>', desc = 'Vertical Split' },
    { '\\', '<cmd>split<cr>', desc = 'Horizontal Split' },

    { '<C-Up>', '<cmd>resize +2<cr>', desc = 'Increase Window Height' },
    { '<C-Down>', '<cmd>resize -2<cr>', desc = 'Decrease Window Height' },
    { '<C-Left>', '<cmd>vertical resize -2<cr>', desc = 'Decrease Window Width' },
    { '<C-Right>', '<cmd>vertical resize +2<cr>', desc = 'Increase Window Width' },

    -- Buffers
    { '<leader>b', group = 'Buffers', icon = { icon = icons.Tab, color = 'green' } },
    { '<leader>bc', '<cmd>bd|e#<cr>', desc = 'Close other buffers' },
    --{'<leader>bb', '<cmd>BufferLinePick<cr>', 'Pick Buffer' },
    { '<Tab>', '<cmd>bnext<cr>', desc = 'Next buffer' },

    { '<S-Tab>', '<cmd>bprevious<cr>', desc = 'Previous buffer' },

    -- Tabs
    { '<leader>bt', icon = { icon = icons.Tab, color = 'green' }, group = 'Tabs' },
    {
      '<leader>btn',
      function()
        vim.cmd.tabnext()
      end,
      desc = 'Next tab',
    },
    {
      '<leader>btp',
      function()
        vim.cmd.tabprevious()
      end,
      desc = 'Previous tab',
    },
    {
      '<leader>btc',
      function()
        vim.cmd.tabclose()
      end,
      desc = 'Close tab',
    },

    -- Neo-tree
    { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle Explorer' },
    {
      '<leader>o',
      function()
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd.wincmd 'p'
        else
          vim.cmd.Neotree 'focus'
        end
      end,
      desc = 'Toggle Explorer Focus',
    },

    -- Terminal
    { '<Char-0xAA>', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },

    -- Testing
    { '<leader>t', icon = icons.Testing, group = 'Testing' },
    {
      '<leader>ta',
      function()
        require('neotest').run.run(vim.loop.cwd())
      end,
      desc = 'Run All Test Files',
    },
    {
      '<leader>tc',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run nearest test',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
        require('neotest').summary.open()
      end,
      desc = 'Run tests in current file',
    },
    {
      '<leader>tr',
      function()
        require('neotest').run.run_last()
      end,
      desc = 'Run last test',
    },
    {
      '<leader>tw',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Toggle test output panel',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Toggle summary panel',
    },

    -- Coverage
    {
      '<leader>tvs',
      function()
        local cov = require 'coverage'
        local id = cov.load(false)
        vim.fn.jobwait({ id }, 1000)
        cov.summary()
      end,
      desc = 'Coverage Summary',
    },
    {
      '<leader>tvt',
      function()
        require('coverage').toggle()
      end,
      desc = 'Coverage Toggle',
    },

    -- Debugging
    { '<leader>d', icon = { icon = icons.Debugger, color = 'purple' }, group = 'Debug' },
    {
      '<leader>dc',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = 'Debug nearest test',
    },
    {
      '<leader>dr',
      function()
        require('neotest').run.run_last { strategy = 'dap' }
      end,
      desc = 'Debug last test',
    },
    {
      '<leader>dg',
      function()
        require('dap').continue()
      end,
      desc = 'Start/Continue',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },

    -- Git
    { '<leader>g', icon = { icon = icons.Git, color = 'red' }, group = 'Git' },
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },

    -- Gitlab
    { '<leader>gl', icon = { icon = icons.GitLab, color = 'red' }, group = 'Gitlab' },
    { '<leader>glr', gitlab.review, desc = 'Gitlab MR review' },
    { '<leader>gls', gitlab.summary, desc = 'Gitlab MR summary' },
    { '<leader>glA', gitlab.approve, desc = 'Gitlab MR approve' },
    { '<leader>glR', gitlab.revoke, desc = 'Gitlab MR revoke' },
    { '<leader>glc', gitlab.create_comment, desc = 'Gitlab MR create comment' },
    { '<leader>glm', gitlab.move_to_discussion_tree_from_diagnostic, desc = 'Gitlab MR move to discussion tree' },
    { '<leader>gln', gitlab.create_note, desc = 'Gitlab MR create note' },
    { '<leader>gld', gitlab.toggle_discussions, desc = 'Gitlab MR toggle discussions' },
    { '<leader>glaa', gitlab.add_assignee, desc = 'Gitlab MR add assignee' },
    { '<leader>glad', gitlab.delete_assignee, desc = 'Gitlab MR delete assignee' },
    { '<leader>glp', gitlab.pipeline, desc = 'Gitlab pipeline' },
    { '<leader>glo', gitlab.open_in_browser, desc = 'Gitlab open in browser' },

    -- Markdown
    { '<leader>m', icon = { icon = icons.Markdown, color = 'azure' }, group = 'Markdown' },
    { '<leader>mg', ':Glow<cr>', desc = 'Markdown Glow' },

    -- Navigator
    { '<C-h>', '<cmd>NavigatorLeft<cr>', desc = 'Move to left split' },
    { '<C-j>', '<cmd>NavigatorDown<cr>', desc = 'Move to below split' },
    { '<C-k>', '<cmd>NavigatorUp<cr>', desc = 'Move to above split' },
    { '<C-l>', '<cmd>NavigatorRight<cr>', desc = 'Move to right split' },

    -- Emoji
    { '<leader><leader>', icon = icons.Toolbox, group = 'Misc' },
    {
      '<leader><leader>i',
      function()
        require('emoji').insert()
      end,
      desc = 'Insert Emoji',
    },

    -- Telescope
    { '<leader>s', icon = icons.Spectre, group = 'Search' },
    { '<leader>sh', builtin.help_tags, desc = 'Search Help' },
    { '<leader>sk', builtin.keymaps, desc = 'Search Keymaps' },
    { '<leader>sf', builtin.find_files, desc = 'Search Files' },
    { '<leader>sg', builtin.live_grep, desc = 'Search by Grep' },
    { '<leader>sd', builtin.diagnostics, desc = 'Search Diagnostics' },
    { '<leader>sr', builtin.resume, desc = 'Search Resume' },
    { '<leader>s.', builtin.oldfiles, desc = 'Search Recent Files ("." for repeat)' },
    --{'<leader><leader>', builtin.buffers, desc = '[ ] Find existing buffers' },
    { '<leader>f', icon = icons.Search, group = 'Find' },
    {
      '<leader>fb',
      function()
        require('telescope.builtin').buffers()
      end,
      desc = 'Find buffers',
    },
    {
      '<leader>ff',
      function()
        require('telescope.builtin').find_files()
      end,
      desc = 'Find files',
    },
    {
      '<leader>fF',
      function()
        require('telescope.builtin').find_files { hidden = true, no_ignore = true }
      end,
      desc = 'Find all files',
    },
    {
      '<leader>fw',
      function()
        require('telescope.builtin').live_grep()
      end,
      desc = 'Find words',
    },
    {
      '<leader>fW',
      function()
        require('telescope.builtin').live_grep {
          additional_args = function(args)
            return vim.list_extend(args, { '--hidden', '--no-ignore' })
          end,
        }
      end,
      desc = 'Find words in all files',
    },

    -- Slightly advanced example of overriding default behavior and theme
    {
      '<leader>/',
      function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer',
    },

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    {
      '<leader>s/',
      function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },

    -- Spectre
    { '<leader>ss', icon = icons.Spectre, group = 'Spectre' },
    {
      '<leader>sss',
      function()
        require('spectre').toggle()
      end,
      desc = 'Toggle Spectre',
    },
    {
      '<leader>ssw',
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Search current word',
    },

    -- Rust
    { '<leader>r', icon = icons.Rust, group = 'Rust' },
    { '<leader>rr', '<cmd>RustRun!<cr>', desc = 'Run Current Rust file' },

    -- Notes
    { '<leader>n', icon = icons.Note, group = 'Notes' },
    { '<leader>nt', '<Esc>i- [ ] ', desc = 'Todo Checkbox' },

    -- Lsp
    { '<leader>l', icon = icons.ActiveLSP, group = 'LSP' },
    { '<leader>ld', vim.diagnostic.open_float, desc = 'Hover diagnostics' },

    -- Trouble
    { '<leader>x', icon = icons.Trouble, group = 'Trouble' },
  },

  -- Terminal
  t = {
    -- Terminal
    { '<Char-0xAA>', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
  },

  -- Visual
  v = {
    { '<leader>glc', gitlab.create_multiline_comment, desc = 'Gitlab MR multiline comment' },
    { '<leader>glC', gitlab.create_comment_suggestion, desc = 'Gitlab MR create suggestion' },

    -- Spectre
    {
      '<leader>ssw',
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Search current word',
    },
  },

  -- Insert
  -- todo: This was triggering on Tab in Insert mode??
  -- i = {
  --
  --   -- Icon Picker
  --   {'<C-i>', '<cmd>IconPickerInsert<cr>', desc = 'Icon Picker Insert' },
  -- },
}

for mode, keymaps in pairs(maps) do
  for _, keymap in ipairs(keymaps) do
    local registration = keymap
    registration.mode = mode
    if registration.icon and type(registration.icon) == 'string' then
      registration.icon = { icon = registration.icon, color = 'blue' }
    end
    wk.add(keymap)
  end
end
