-- vim.g.python3_host_prog = os.getenv("HOME") .. '/virtualenvs/nvim-venv/bin/python' -- python code environment

-- Performance optimizations
vim.opt.lazyredraw = true -- Don't redraw while executing macros
vim.opt.regexpengine = 1 -- Use old regexp engine (faster for some patterns)
vim.opt.synmaxcol = 300 -- Don't highlight very long lines
vim.opt.timeoutlen = 300 -- Faster key sequence timeout
vim.opt.ttimeoutlen = 10 -- Faster escape sequences

vim.opt.spell = true
vim.opt.encoding = "utf-8" -- set encoding
vim.opt.nu = true -- enable line numbers
vim.opt.relativenumber = true -- relative line numbers

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- convert tabs to spaces
-- vim.wo.wrap = false -- do not wrap lines
vim.opt.autoindent = true -- auto indentation
vim.opt.list = true -- show tab characters and trailing whitespace
vim.opt.formatoptions:remove("t") -- no auto-intent of line breaks, keep line wrap enabled
vim.opt.listchars = "tab:»\\ ,extends:›,precedes:‹,nbsp:·,trail:·" -- show tab characters and trailing whitespace

vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- unless capital letter in search

vim.opt.swapfile = false -- do not use a swap file for the buffer
vim.opt.backup = false -- do not keep a backup file
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- set directory where undo files are stored
vim.opt.undofile = true -- save undo history to a file

vim.opt.hlsearch = false -- do not highlight all matches on previous search pattern
vim.opt.incsearch = true -- incrementally highlight searches as you type

vim.opt.termguicolors = true -- enable true color support

vim.opt.scrolloff = 8 -- minimum number of lines to keep above and below the cursor
vim.opt.sidescrolloff = 8 --minimum number of columns to keep above and below the cursor
vim.opt.signcolumn = "yes" -- always show the sign column, to avoid text shifting when signs are displayed
vim.opt.isfname:append("@-@") -- include '@' in the set of characters considered part of a file name

vim.opt.updatetime = 300 -- Time in milliseconds to wait before triggering the plugin events after a change

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.py",
  callback = function()
    vim.opt.textwidth = 79
    vim.opt.colorcolumn = "79"
  end
}) -- python formatting

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.js", "*.html", "*.css", "*.lua"},
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.shiftwidth = 2
  end
}) -- javascript formatting

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
      if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
        vim.cmd("normal! g`\"")
      end
    end
}) -- return to last edit position when opening files


local HighlightYank = vim.api.nvim_create_augroup('HighlightYank', {})
vim.api.nvim_create_autocmd('TextYankPost', {
    group = HighlightYank,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
}) -- highlight yanked text using the 'IncSearch' highlight group for 40ms

local CleanOnSave = vim.api.nvim_create_augroup('CleanOnSave', {})
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  group = CleanOnSave,
  pattern = "*",
  command = [[%s/\s\+$//e]],
}) -- remove trailing whitespace from all lines before saving a file)

-- Black formatting moved to LSP formatting for better performance

-- vim.api.nvim_create_autocmd('LspAttach', {
--     callback = function(args)
--         local client_id = args.data.client_id
--         local bufnr = args.buf
--         local client = vim.lsp.get_client_by_id(client_id)
--         if not client then
--             return
--         end
--
--         if client.server_capabilities.completionProvider and client.name ~= 'minuet' then
--             vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
--         end
--     end,
--     desc = 'Enable built-in auto completion',
-- })
