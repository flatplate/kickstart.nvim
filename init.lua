--[[init
init
=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

local function is_win()
  return package.config:sub(1, 1) == '\\'
end

local function get_path_separator()
  if is_win() then
    return '\\'
  end
  return '/'
end

local function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. get_path_separator() .. ')')
end

local function read_env_file()
  local current_path = script_path()
  print("Reading env file " .. current_path)
  local env_file = io.open(current_path .. ".env", "r")
  if not env_file then
    print("Error: .env file not found")
    return {}
  end
  local env_vars = {}
  for line in env_file:lines() do
    local key, value = line:match("^%s*([^=]+)%s*=%s*(.+)%s*$")
    if key and value then
      env_vars[key] = value
    else
      print("Warning: Invalid line format: " .. line)
    end
  end
  env_file:close()
  return env_vars
end

local env_vars = read_env_file()
local function osDependentConfig(config)
  local isWindows = vim.loop.os_uname().sysname == 'Windows_NT'
  if isWindows then
    return config['windows']
  end
  return config['default']
end

local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    -- attach_mappings = function (prompt_bufnr, map)
    --   local actions = require "telescope.actions"
    --   actions.select_default:replace(function()
    --     actions.close(prompt_bufnr)
    --     local action_state = require "telescope.actions.state"
    --     local selection = action_state.get_selected_entry()
    --     local filename = selection.filename
    --     if (filename == nil) then
    --       filename = selection[1]
    --     end
    --     -- any way to open the file without triggering auto-close event of neo-tree?
    --     -- require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
    --   end)
    --   return true
    -- end
  }
end

local DEBOUNCE_DELAY = 300
local copilot_enabled = true

local timer = vim.loop.new_timer()
local function debouncedCopilotSuggest()
  if not copilot_enabled then
    return
  end
  timer:stop()
  timer:start(
    DEBOUNCE_DELAY,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Plug>(copilot-suggest)', true, true, true), 'm', true)
    end)
  )
end

local function neovideScale(amount)
  local temp = vim.g.neovide_scale_factor + amount
  if temp < 0.5 then
    return
  end
  vim.g.neovide_scale_factor = temp
end
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set shiftwidth and tabstop to 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true
vim.opt.guifont = osDependentConfig { windows = 'JetBrains Mono NL:h10', default = 'JetBrainsMono Nerd Font Mono:h10' }
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = false
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.makeprg =
"yarn tsc \\| sed 's/(\\(.*\\),\\(.*\\)):/:\\1:\\2:/' \\| sed 's/@cresta/packages/' \\| sed 's/:\\ /\\//g'"
vim.opt.tabstop = 4
vim.opt.wrap = false

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.colorcolumn = '120'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Normal mode mappings
vim.keymap.set('n', '<C-f>', function()
  vim.lsp.buf.execute_command { command = '_typescript.organizeImports', arguments = { vim.fn.expand '%:p' } }
  vim.defer_fn(function()
    vim.lsp.buf.format()
    vim.defer_fn(function()
      vim.cmd 'EslintFixAll'
    end, 10)
  end, 10)
end, { desc = 'Organize imports and ESLint fix' })

vim.keymap.set('n', '<leader>se', function()
  VisualSelectError()
end, { desc = 'Visual select error' })
vim.keymap.set('n', '<C-=>', function()
  neovideScale(0.1)
end, { desc = 'Increase scale' })
vim.keymap.set('n', '<C-->', function()
  neovideScale(-0.1)
end, { desc = 'Decrease scale' })
vim.keymap.set('n', '<C-s>', ':wa<cr>', { desc = 'Save all files' })
vim.keymap.set('n', '<C-t>', 'A // TODO(flatplate)<esc>', { desc = 'Add todo' })
vim.keymap.set('n', '<C-q>', '<C-w>q', { desc = 'Close current panel' })
vim.keymap.set('n', osDependentConfig { windows = '<C-\\>', default = "<C-'>" }, ':ToggleTerm<CR>',
  { desc = 'Open toggle term' })
vim.keymap.set('n', '<C-p>', '"qp', { desc = 'Paste from register q' })
vim.keymap.set('n', '<c-cr>', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<c-s-tab>', function()
  require('telescope.builtin').buffers { sort_lastused = true, ignore_current_buffer = true }
end, { desc = 'Switch buffer' })
vim.keymap.set('n', '<c-tab>', ':b#<cr>', { desc = 'Switch to last buffer' })
vim.keymap.set('n', '<c-`>', function()
  require('telescope.builtin').marks { sort_lastused = true }
end, { desc = 'Show marks' })
vim.keymap.set('n', '<leader>a', ':ArgWrap<cr>', { desc = 'Argument wrapping' })
vim.keymap.set('n', '<leader>df', ':GoPrintlnFileLine<CR>', { desc = 'Go print file line' })
vim.keymap.set('n', '<leader>nd', function()
  vim.notify.dismiss()
end, { desc = 'Dismiss notifications' })
vim.keymap.set('n', '<c-s-n>', ':cp<cr>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<c-n>', ':cn<cr>', { desc = 'Next quickfix item' })

-- Telescope mappings
vim.keymap.set('n', '<leader>fq', function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end, { desc = 'Live grep with args' })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files hidden=true<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fb', ':Telescope vim_bookmarks all<CR>', { desc = 'Find bookmarks' })
vim.keymap.set('n', '<leader>fp', function()
  require('telescope.builtin').live_grep { grep_open_files = true }
end, { desc = 'Search in open files' })
vim.keymap.set('n', '<leader>fg', function()
  local path = vim.fn.expand '%:p:h'
  require('telescope.builtin').git_status(getTelescopeOpts(vim.fn.getcwd(), path))
end, { desc = 'Telescope git diff files' })
vim.keymap.set('n', '<leader>ft', function()
  require('telescope.builtin').git_status { cwd = vim.fn.expand '%:p:h' }
end, { desc = 'Git status in current directory' })
vim.keymap.set('n', '<leader>fc', function()
  require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()
end, { desc = 'Grep word under cursor' })
vim.keymap.set('n', '<leader>fi', function()
  vim.cmd 'noau normal! "zyiw"'
  require('telescope.builtin').find_files { search_file = vim.fn.getreg 'z' }
end, { desc = 'Find files with word under cursor' })
vim.keymap.set('n', '<leader>fr', ':Telescope resume<CR>', { desc = 'Resume last Telescope' })
vim.keymap.set('n', '<leader>e', function()
  vim.cmd("Neotree toggle")
end, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>oo', function()
  vim.cmd("Neotree")
end, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>oi', function()
  vim.cmd("Neotree filesystem reveal_file=%")
end, { desc = 'Help tags' })

-- Other mappings
vim.keymap.set('n', '<leader>gl', ':Git blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', 'gv', ':vsplit<CR>gd', { desc = 'Split and go to definition' })
vim.keymap.set('n', '<leader>sr', 'yiw:%s/<C-R>*', { desc = 'Search and replace word under cursor (file)' })
vim.keymap.set('n', '<leader>ss', 'yiw:s/<C-R>*/', { desc = 'Search and replace word under cursor (line)' })
vim.keymap.set('n', '<leader>bb', function()
  require('harpoon.mark').add_file()
end, { desc = 'Add file to harpoon' })
vim.keymap.set('n', '<c-1>', function()
  require('harpoon.ui').toggle_quick_menu()
end, { desc = 'Harpoon quick menu' })
vim.keymap.set('n', '<leader>i', function()
  vim.lsp.buf.code_action {
    apply = true,
    context = {
      only = { 'source.addMissingImports.ts' },
    },
  }
  vim.cmd 'write'
end, { desc = 'Fix imports' })
vim.keymap.set('n', '<leader>gr', function()
  require('telescope.builtin').lsp_references { layout_strategy = 'cursor', layout_config = { width = 0.99, height = 0.4 } }
end, { desc = 'Telescope LSP references' })

-- Terminal mode mappings
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { desc = 'To normal mode in terminal' })
vim.keymap.set('t', osDependentConfig { windows = '<C-\\>', default = "<C-'>" }, '<C-\\><C-n>:ToggleTerm<CR>',
  { desc = 'Close toggle term' })

-- Insert mode mappings
vim.keymap.set('i', '<C-p>', '<esc>:Telescope oldfiles<CR>', { desc = 'Find old files' })
vim.keymap.set('i', '<c-s-tab>', function()
  require('telescope.builtin').buffers { sort_lastused = true, ignore_current_buffer = true }
end, { desc = 'Switch buffer' })
vim.keymap.set('i', '<c-tab>', '<esc>:b#<cr>a', { desc = 'Switch to last buffer' })
vim.keymap.set('i', 'jj', '<esc>', { desc = 'jj to escape' })
vim.keymap.set('i', '<c-l>', function()
  return vim.fn['copilot#Accept'] '<CR>'
end, { expr = true, silent = true, noremap = true, replace_keycodes = false, desc = 'Accept Copilot suggestion' })
vim.keymap.set('i', '<c-d>', '<c-o>dd',
  { silent = true, noremap = true, replace_keycodes = false, desc = 'Delete line in insert mode' })
vim.keymap.set('i', '<c-h>', '<C-o>diW',
  { silent = true, noremap = true, replace_keycodes = false, desc = 'Delete WORD' })

-- vim.keymap.set('i', '<c-i>', function()
--   require('cmp').mapping.complete()
-- end, { desc = 'Open suggestions' })
--
--

-- Visual mode mappings
vim.keymap.set('v', '<leader>re', function(opts)
  require('react-extract').extract_to_new_file(opts)
end, { desc = 'React extract to new file' })
vim.keymap.set('v', '<leader>rf', function(opts)
  require('react-extract').extract_to_current_file(opts)
end, { desc = 'React extract to current file' })
vim.keymap.set('v', '<leader>fc', function()
  require('telescope-live-grep-args.shortcuts').grep_visual_selection()
end, { desc = 'Grep visual selection' })
vim.keymap.set('v', '<c-cr>', function()
  vim.lsp.buf.range_code_action()
end, { desc = 'Range code action' })
-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_augroup('packer_conf', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  desc = 'Sync packer after modifying plugins.lua',
  group = 'packer_conf',
  pattern = 'plugins.lua',
  command = 'source <afile> | PackerSync',
})
vim.api.nvim_create_autocmd('TextChangedI', {
  callback = function()
    debouncedCopilotSuggest()
  end,
})
vim.api.nvim_create_user_command('CopyLines', function(opts)
  vim.cmd 'noau visual! qaq'
  vim.cmd('g/' .. opts.args .. '/y A')
  vim.cmd 'let @+ = @a'
end, { nargs = 1 })

vim.api.nvim_create_user_command('CopyFileAndLine', function(opts)
  vim.cmd 'let @*=join([expand("%"),  line(".")], ":")'
end, { nargs = 0 })

vim.api.nvim_create_user_command('ToggleCopilot', function(opts)
  copilot_enabled = not copilot_enabled
end, { nargs = 0 })

vim.api.nvim_create_user_command('CloseAllBuffers', function(opts)
  vim.cmd '%bd|e#'
end, { nargs = 0 })

vim.api.nvim_create_user_command('GoPrintlnFileLine', function(opts)
  local path = vim.fn.getreg '%'
  local file = path:match '([^/]+)$'

  local line_num = vim.api.nvim_win_get_cursor(0)[1]

  vim.cmd('let @z="' .. file .. ':' .. line_num .. '"')
  vim.cmd 'execute "normal ofmt.Println(\\""'
  vim.cmd 'execute "normal\\"zp"'
  vim.cmd 'execute "i\\")"'
end, { nargs = 0 })

vim.api.nvim_create_user_command('CopySearch', function(opts)
  local hits = {}

  -- This function gets executed for each occurrence of the search pattern
  local function replacer()
    table.insert(hits, vim.fn.submatch(0))
    return vim.fn.submatch(0)
  end

  -- Use the substitution command with the replacer function
  vim.api.nvim_exec(string.format '%%s///\\=v:lua.copy_matches_neovim.replacer()//gne', false)

  -- If no register is provided, use the clipboard register "+"
  reg = opts.reg or '+'

  -- Set the contents of the chosen register to the hits
  vim.fn.setreg(reg, table.concat(hits, '\n') .. '\n', 'l')
end, { range = true, register = true })

-- TODO Create an autocommand for autosave
-- context:  https://vi.stackexchange.com/questions/74/is-it-possible-to-make-vim-auto-save-files
-- autocmd CursorHold,CursorHoldI * update
vim.api.nvim_set_keymap('i', '<C-/>', 'copilot#Accept("<CR>")', { expr = true, silent = true })

vim.cmd [[
    augroup autosave_buffer
    au!
    au FocusLost * :silent! wa
    augroup END
    ]]
-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  ---- Add plugins, the packer syntax without the "use"
  -- p
  --
  -- You can disable default plugins as follows:
  {
    'kevinhwang91/nvim-hlslens',
    lazy = false,
    config = function()
      require('hlslens').setup()
    end,
  },
  {
    'ThePrimeagen/harpoon',
    lazy = false,
  },
  {
    's1n7ax/nvim-window-picker',
    lazy = false,
  },
  {
    'gennaro-tedesco/nvim-jqx',
    event = { 'BufReadPost' },
    ft = { 'json', 'yaml' },
  },
  { 'stevanmilic/nvim-lspimport', lazy = false },
  {
    'Vigemus/iron.nvim',
    lazy = false,
    config = function()
      local iron = require 'iron.core'

      iron.setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { 'zsh' },
            },
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = require('iron.view').split.right(100),
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_motion = '<space>sc',
          visual_send = '<space>sc',
          send_file = '<space>sf',
          send_line = '<space>sl',
          send_until_cursor = '<space>su',
          send_mark = '<space>sm',
          mark_motion = '<space>mc',
          mark_visual = '<space>mc',
          remove_mark = '<space>md',
          cr = '<space>s<cr>',
          interrupt = '<space>s<space>',
          exit = '<space>sq',
          clear = '<space>cl',
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'glacambre/firenvim',
    run = function()
      vim.fn['firenvim#install'](0)
    end,
    lazy = false,
  },
  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    lazy = false,
  },
  {
    'hrsh7th/nvim-cmp',
    -- override the options table that is used in the `require("cmp").setup()` call
    opts = function(_, opts)
      -- opts parameter is the default options table
      -- the function is lazy loaded so cmp is able to be required
      local cmp = require 'cmp'
      -- modify the mapping part of the table
      opts.mapping = {
        ['<C-i>'] = cmp.mapping.complete()
      }

      -- return the new table to be used
      return opts
    end,
  },
  {
    'napmn/react-extract.nvim',
    lazy = false,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    config = function()
      require('nvim-treesitter.configs').setup {
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<C-Space>', -- set to `false` to disable one of the mappings
            node_incremental = 'n',
            scope_incremental = 'm',
            node_decremental = 'N',
            scope_decremental = 'M',
          },
        },
      }
    end,
  },
  -- { 'HiPhish/rainbow-delimiters.nvim', lazy = false },
  { 'tpope/vim-fugitive',         lazy = false },
  {
    'toggleterm.nvim',
    opts = {

      direction = 'vertical',
      size = 80,
    },
  },
  { 'goolord/alpha-nvim',               lazy = false },
  {
    'jesseleite/nvim-noirbuddy',
    dependencies = {
      { 'tjdevries/colorbuddy.nvim' }
    },
    lazy = false,
    priority = 1000,
    opts = {
      -- All of your `setup(opts)` will go here
    },
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    config = function()
      require('gruvbox').setup {
        palette_overrides = {
          dark0 = '#111313',
          dark0_hard = '#111313',
          dark1 = '#1c1f1f',
          dark2 = '#222626',
          dark3 = '#333939',
          bright_red = '#f55954',
          bright_green = '#babb56',
          bright_yellow = '#f9bc51',
          bright_blue = '#83a5a8',
          bright_purple = '#d3869b',
          bright_aqua = '#8ec07c',
          bright_orange = '#f38d46',
          neutral_red = '#da341d',
          neutral_green = '#98974a',
          neutral_yellow = '#c7a931',
          neutral_blue = '#457598',
          neutral_purple = '#d17296',
          neutral_aqua = '#689d6a',
          neutral_orange = '#d65d3e',
          faded_red = '#FFF',
          faded_green = '#39540e',
          faded_yellow = '#856614',
          faded_blue = '#033658',
          faded_purple = '#6f2f61',
          faded_aqua = '#225b38',
          faded_orange = '#8e423e',
          gray = '#828389',
        },
        contrast = 'hard',
      }

      vim.cmd.colorscheme 'gruvbox'

      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  -- You can also add new plugins here as well:
  { 'prochri/telescope-all-recent.nvim' },
  {
    'ggandor/leap.nvim',
    config = function()
      require('leap').add_default_mappings()
    end,
    lazy = false,
  },
  { 'MattesGroeger/vim-bookmarks',  lazy = false },
  {
    'tom-anders/telescope-vim-bookmarks.nvim',
    config = function()
      require('telescope').load_extension 'vim_bookmarks'
    end,
  },
  { 'github/copilot.vim',           lazy = false },
  { 'alvan/vim-closetag',           lazy = false },
  { 'tpope/vim-fugitive',           lazy = false },
  { 'FooSoft/vim-argwrap',          lazy = false },
  { 'mattn/emmet-vim',              lazy = false },
  { 'ludovicchabant/vim-gutentags', lazy = false },
  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
    lazy = false,
  },
  { 'fatih/vim-go',              lazy = false },
  -- { 'sbdchd/neoformat', lazy = false },
  { 'petertriho/nvim-scrollbar', lazy = false },
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    config = function()
      vim.keymap.set('n', ']g', require('gitsigns').next_hunk, { desc = 'Jump to next git hunk' })
      vim.keymap.set('n', '[g', require('gitsigns').prev_hunk, { desc = 'Jump to previous git hunk' })
      vim.keymap.set('n', '<leader>gh', require('gitsigns').stage_hunk, { desc = 'Stage hunk' })
      vim.keymap.set('n', '<leader>gr', require('gitsigns').reset_hunk, { desc = 'Reset hunk' })
      -- vim.keymap.set('v', '<leader>hs', function() require('gitsigns').stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
      -- vim.keymap.set('v', '<leader>hr', function() require('gitsigns').reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
      vim.keymap.set('n', '<leader>gb', require('gitsigns').stage_buffer, { desc = 'Stage buffer' })
      vim.keymap.set('n', '<leader>gu', require('gitsigns').undo_stage_hunk, { desc = 'Undo stage hunk' })
      vim.keymap.set('n', '<leader>gR', require('gitsigns').reset_buffer, { desc = 'Reset buffer' })
      vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { desc = 'Preview hunk' })
    end
  },
  -- All other entries override the setup() call for default plugins
  --
  { 'numToStr/Comment.nvim',    opts = {} },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
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

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        opts = {
          defaults = {
            file_ignore_patterns = { 'node_modules', '.git', 'gen' },
          },
        }
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Lsp diagnostics
          map('<leader>ld', vim.diagnostic.open_float, '[L]sp [D]iagnostics')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>lr', vim.lsp.buf.rename, '[L]sp [R]ename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
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
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-j>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-k>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          -- ['<C-l>'] = cmp.mapping(function()
          --   if luasnip.expand_or_locally_jumpable() then
          --     luasnip.expand_or_jump()
          --   end
          -- end, { 'i', 's' }),
          -- ['<C-h>'] = cmp.mapping(function()
          --   if luasnip.locally_jumpable(-1) then
          --     luasnip.jump(-1)
          --   end
          -- end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  {
    dir = "~/Projects/elelem.nvim",
    dev = true,
    config = function()
      local elelem = require("elelem")
      elelem.setup({
        providers = {
          fireworks = {
            api_key = env_vars.FIREWORKS_API_KEY
          },
          anthropic = {
            api_key = env_vars.ANTHROPIC_API_KEY
          },
          openai = {
            api_key = env_vars.OPENAI_API_KEY
          },
          groq = {
            api_key = env_vars.GROQ_API_KEY
          },
        }
      })
      local quick_model = require("elelem").models.gpt4omini
      local smart_model = require("elelem").models.claude_3_5_sonnet
      local next_action_model = require("elelem").models.qwen
      if env_vars.LAPTOP == "work" then
        quick_model = require("elelem").models.claude_3_haiku
        smart_model = require("elelem").models.claude_3_5_sonnet
        next_action_model = require("elelem").models.claude_3_5_sonnet
      end
      -- Same as the comments below
      vim.keymap.set('n', '<leader>wq', function()
        elelem.search_quickfix(
          "Answer only what is asked short and concisely. Give references to the file names when you say something. ",
          quick_model)
      end, { desc = 'Search Quickfix' })
      vim.keymap.set('n', '<leader>wz', function()
        elelem.ask_llm(
          "Answer only what is asked short and concisely. Give references to the file names when you say something. ",
          quick_model)
      end, { desc = 'Search Quickfix' })
      vim.keymap.set('n', '<leader>ww', function()
        elelem.search_current_file("Answer only what is asked short and concisely. ", quick_model)
      end, { desc = 'Query Current File' })
      vim.keymap.set('n', '<leader>we', function()
        elelem.search_current_file("", smart_model)
      end, { desc = 'Query Current File with sonnet' })
      vim.keymap.set('n', '<leader>wa', function()
        elelem.append_llm_output(
          "You write code that will be put in the lines marked with [Append here] and write code for what the user asks. Do not provide any explanations, just write code. Only return code. Only code no explanation",
          smart_model)
      end, { desc = 'Append to cursor location with sonnet' })
      vim.keymap.set('n', '<leader>wd', function()
        elelem.append_llm_output(
          "You write code that will be put in the lines marked with [Append here] and write code for what the user asks. Do not provide any explanations, just write code. Only return code. Only code no explanation",
          quick_model)
      end, { desc = 'Append to cursor location with mini' })
      vim.keymap.set('n', '<leader>wf', function()
        elelem.context_picker()
      end)
      vim.keymap.set('v', '<leader>wca', function()
        elelem.context.add_visual_selection()
      end, { desc = 'Add visual selection to context' })
      vim.keymap.set('n', '<leader>wca', function()
        elelem.context.add_current_buffer()
      end, { desc = 'Add current buffer to context' })
      vim.keymap.set('n', '<leader>wcc', function()
        elelem.init_new_chat()
      end, { desc = 'Init new chat' })
      vim.keymap.set('n', '<leader>wcn', function()
        elelem.ask_chat(
          "You are chatting with a developer in their IDE. If you need more context, you can use lsp commands such as go to definition on any piece of code",
          smart_model)
      end, { desc = 'Ask chat' })
      vim.keymap.set('n', '<leader>wn', function()
        local file = io.open('/Users/ural/.config/nvim/prompts/next_change.md', 'r')
        if file then
          local content = file:read('*all')
          file:close()

          -- Use the content as prompt
          elelem.ask_next_change(content, next_action_model)
          return
        end
        elelem.ask_next_change(
          "You are a code assistant, you guess the next actions the user will take given the last change the user made. You respond in git diff format. Try to guess only the most obvious repetitive changes. if you can't guess the next change respond with [no change]. Do not include the change in the prompt in the diff, assume it already changed. Only return the actually changed parts in the diff.",
          next_action_model)
      end, { desc = 'Ask chat' })
      vim.keymap.set('n', '<leader>wr', function()
        elelem.apply_changes()
      end, { desc = 'Ask chat' })

      vim.keymap.set('v', '<leader>ww', function()
        elelem.search_visual_selection("", quick_model)
      end, { desc = 'Query selection with gpt mini' })
      vim.keymap.set('v', '<leader>we', function()
        elelem.search_visual_selection("", smart_model)
      end, { desc = 'Query selection with sonnet' })
      vim.keymap.set('v', '<leader>wa', function()
        elelem.append_llm_output_visual(
          "You write code that will be put in the lines marked with [Append here] and write code for what the user asks. Do not provide any explanations, just write code. Only return code. Only code no explanation",
          smart_model)
      end, { desc = 'Append selection with sonnet' })
    end
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>ou", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })

      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
      }
    end,
    lazy = false,
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et[Append here]
