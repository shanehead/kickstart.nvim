local wk = require 'which-key'
local gitlab = require 'gitlab'
local builtin = require 'telescope.builtin'

-- Normal
local maps = {
  n = {
    ['<leader>q'] = { '<cmd>confirm qa<cr>', desc = 'Quit' },

    -- Buffers
    ['<leader>b'] = { name = 'Buffers' },
    ['<Tab>'] = { '<cmd>bnext<cr>', desc = 'Next buffer' },
    ['<S-Tab>'] = { '<cmd>bprevious<cr>', desc = 'Previous buffer' },

    -- Tabs
    ['<leader>bt'] = { name = 'Tabs' },
    ['<leader>btn'] = {
      function()
        vim.cmd.tabnext()
      end,
      desc = 'Next tab',
    },
    ['<leader>btp'] = {
      function()
        vim.cmd.tabprevious()
      end,
      desc = 'Previous tab',
    },
    ['<leader>btc'] = {
      function()
        vim.cmd.tabclose()
      end,
      desc = 'Close tab',
    },

    -- Neo-tree
    ['<leader>e'] = { '<cmd>Neotree toggle<cr>', desc = 'Toggle Explorer' },
    ['<leader>o'] = {
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
    ['<Char-0xAA>'] = { '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },

    -- Testing
    ['<leader>t'] = { name = 'Testing' },
    ['<leader>ta'] = {
      function()
        require('neotest').run.run(vim.loop.cwd())
      end,
      desc = 'Run All Test Files',
    },
    ['<leader>tc'] = {
      function()
        require('neotest').run.run()
      end,
      desc = 'Run nearest test',
    },
    ['<leader>tf'] = {
      function()
        require('neotest').run.run(vim.fn.expand '%')
        require('neotest').summary.open()
      end,
      desc = 'Run tests in current file',
    },
    ['<leader>tr'] = {
      function()
        require('neotest').run.run_last()
      end,
      desc = 'Run last test',
    },
    ['<leader>tw'] = {
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Toggle test output panel',
    },
    ['<leader>ts'] = {
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Toggle summary panel',
    },

    -- Coverage
    ['<leader>tvs'] = {
      function()
        local cov = require 'coverage'
        local id = cov.load(false)
        vim.fn.jobwait({ id }, 1000)
        cov.summary()
      end,
      desc = 'Coverage Summary',
    },
    ['<leader>tvt'] = {
      function()
        require('coverage').toggle()
      end,
      desc = 'Coverage Toggle',
    },

    -- Debugging
    ['<leader>d'] = { name = 'Debug' },
    ['<leader>dc'] = {
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = 'Debug nearest test',
    },
    ['<leader>dr'] = {
      function()
        require('neotest').run.run_last { strategy = 'dap' }
      end,
      desc = 'Debug last test',
    },
    ['<leader>dg'] = {
      function()
        require('dap').continue()
      end,
      desc = 'Start/Continue (F5)',
    },

    -- Gitlab
    ['<leader>g'] = { name = 'Git' },
    ['<leader>gl'] = { name = 'Gitlab' },
    ['<leader>glr'] = { gitlab.review, desc = 'Gitlab MR review' },
    ['<leader>gls'] = { gitlab.summary, desc = 'Gitlab MR summary' },
    ['<leader>glA'] = { gitlab.approve, desc = 'Gitlab MR approve' },
    ['<leader>glR'] = { gitlab.revoke, desc = 'Gitlab MR revoke' },
    ['<leader>glc'] = { gitlab.create_comment, desc = 'Gitlab MR create comment' },
    ['<leader>glm'] = { gitlab.move_to_discussion_tree_from_diagnostic, desc = 'Gitlab MR move to discussion tree' },
    ['<leader>gln'] = { gitlab.create_note, desc = 'Gitlab MR create note' },
    ['<leader>gld'] = { gitlab.toggle_discussions, desc = 'Gitlab MR toggle discussions' },
    ['<leader>glaa'] = { gitlab.add_assignee, desc = 'Gitlab MR add assignee' },
    ['<leader>glad'] = { gitlab.delete_assignee, desc = 'Gitlab MR delete assignee' },
    ['<leader>glp'] = { gitlab.pipeline, desc = 'Gitlab pipeline' },
    ['<leader>glo'] = { gitlab.open_in_browser, desc = 'Gitlab open in browser' },

    -- Markdown
    ['<leader>m'] = { name = 'Markdown' },
    ['<leader>mg'] = { ':Glow<cr>', desc = 'Markdown Glow' },

    -- Tmux navigator
    ['<C-h>'] = { '<cmd>TmuxNavigateLeft<cr>', desc = 'Move to left split' },
    ['<C-j>'] = { '<cmd>TmuxNavigateDown<cr>', desc = 'Move to below split' },
    ['<C-k>'] = { '<cmd>TmuxNavigateUp<cr>', desc = 'Move to above split' },
    ['<C-l>'] = { '<cmd>TmuxNavigateRight<cr>', desc = 'Move to right split' },

    -- Emoji
    ['<leader><leader>i'] = {
      function()
        require('emoji').insert()
      end,
      desc = 'Insert Emoji',
    },

    -- Telescope
    ['<leader>s'] = { name = 'Search' },
    ['<leader>sh'] = { builtin.help_tags, desc = '[S]earch [H]elp' },
    ['<leader>sk'] = { builtin.keymaps, desc = '[S]earch [K]eymaps' },
    ['<leader>sf'] = { builtin.find_files, desc = '[S]earch [F]iles' },
    ['<leader>sg'] = { builtin.live_grep, desc = '[S]earch by [G]rep' },
    ['<leader>sd'] = { builtin.diagnostics, desc = '[S]earch [D]iagnostics' },
    ['<leader>sr'] = { builtin.resume, desc = '[S]earch [R]esume' },
    ['<leader>s.'] = { builtin.oldfiles, desc = '[S]earch Recent Files ("." for repeat)' },
    ['<leader><leader>'] = { builtin.buffers, desc = '[ ] Find existing buffers' },

    -- Slightly advanced example of overriding default behavior and theme
    ['<leader>/'] = {
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
    ['<leader>s/'] = {
      function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },

    -- Spectre
    ['<leader>ss'] = { name = 'Spectre' },
    ['<leader>sss'] = {
      function()
        require('spectre').toggle()
      end,
      desc = 'Toggle Spectre',
    },
    ['<leader>ssw'] = {
      function()
        require('spectre').open_visual { select_word = true }
      end,
      desc = 'Search current word',
    },

    -- Rust
    ['<leader>r'] = { name = 'Rust' },
    ['<leader>rr'] = { '<cmd>RustRun!<cr>', desc = 'Run Current Rust file' },
  },

  -- Terminal
  t = {
    -- Terminal
    ['<Char-0xAA>'] = { '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
  },

  -- Visual
  v = {
    ['<leader>glc'] = { gitlab.create_multiline_comment, desc = 'Gitlab MR multiline comment' },
    ['<leader>glC'] = { gitlab.create_comment_suggestion, desc = 'Gitlab MR create suggestion' },

    -- Spectre
    ['<leader>ssw'] = {
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
  --   ['<C-i>'] = { '<cmd>IconPickerInsert<cr>', desc = 'Icon Picker Insert' },
  -- },
}

for mode, keymaps in pairs(maps) do
  for keymap, opts in pairs(keymaps) do
    if opts.name then
      local registration = {}
      registration[keymap] = opts
      wk.register(registration, { mode = mode })
    else
      local cmd = opts[1]
      local description = opts.desc
      vim.keymap.set(mode, keymap, cmd, { desc = description })
    end
  end
end
