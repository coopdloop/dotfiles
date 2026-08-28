-- telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<cr>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<cr>")

-- tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

-- icon picker
vim.keymap.set("n", "<leader>ic", ":IconPickerNormal<cr>", { noremap = true, silent = true })

-- twilight
vim.keymap.set("n", "<leader>il", ":Twilight<cr>")

-- zen mode
vim.keymap.set("n", "<leader>zm", ":ZenMode<cr>")

-- format code using LSP
vim.keymap.set("n", "<leader>pp", vim.lsp.buf.format)

-- -- format code using LSP
-- vim.keymap.set("n", "<leader>pp", vim.lsp.buf.format)

-- markdown preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<cr>")

-- nvim-comment
vim.keymap.set({ "n", "v" }, "<leader>/", ":CommentToggle<cr>")

------------------
-- goto-preview --
------------------
--
-- note: lsp config (from lsp.lua)
-- nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
-- nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
-- nmap('gt', vim.lsp.buf.type_definition, 'Type [D]efinition')
-- nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

vim.keymap.set('n', '<leader>gd', ":lua require('goto-preview').goto_preview_definition()<CR>")
vim.keymap.set('n', '<leader>gt', ":lua require('goto-preview').goto_preview_type_definition()<CR>")
vim.keymap.set('n', '<leader>gi', ":lua require('goto-preview').goto_preview_implementation()<CR>")
vim.keymap.set('n', '<leader>gp', ":lua require('goto-preview').close_all_win()<CR>")


-- LSP code actions
vim.keymap.set('n', '<leader>ca', ":lua vim.lsp.buf.code_action()<CR>")

-- LSP diagnostics
vim.api.nvim_set_keymap('n', '<leader>cd', ":lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })

vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end, opts)

-- Toggle Undotree
vim.keymap.set('n', '<C-u>', ":UndotreeToggle<CR>")


-- Aider
local keymap = vim.api.nvim_set_keymap

-- general keymap from yarepl
keymap('n', '<Leader>as', '<Plug>(REPLStart-aider)', {
    desc = 'Start an aider REPL',
})
keymap('n', '<Leader>af', '<Plug>(REPLFocus-aider)', {
    desc = 'Focus on aider REPL',
})
keymap('n', '<Leader>ah', '<Plug>(REPLHide-aider)', {
    desc = 'Hide aider REPL',
})
keymap('v', '<Leader>ar', '<Plug>(REPLSendVisual-aider)', {
    desc = 'Send visual region to aider',
})
keymap('n', '<Leader>arr', '<Plug>(REPLSendLine-aider)', {
    desc = 'Send lines to aider',
})
keymap('n', '<Leader>ar', '<Plug>(REPLSendOperator-aider)', {
    desc = 'Send Operator to aider',
})

-- special keymap from aider
keymap('n', '<Leader>ae', '<Plug>(AiderExec)', {
    desc = 'Execute command in aider',
})
keymap('n', '<Leader>ay', '<Plug>(AiderSendYes)', {
    desc = 'Send y to aider',
})
keymap('n', '<Leader>an', '<Plug>(AiderSendNo)', {
    desc = 'Send n to aider',
})
keymap('n', '<Leader>ap', '<Plug>(AiderSendPaste)', {
    desc = 'Send /paste to aider',
})
keymap('n', '<Leader>aa', '<Plug>(AiderSendAbort)', {
    desc = 'Send abort to aider',
})
keymap('n', '<Leader>aq', '<Plug>(AiderSendExit)', {
    desc = 'Send exit to aider',
})
keymap('n', '<Leader>ag', '<cmd>AiderSetPrefix<cr>', {
    desc = 'set aider prefix',
})
keymap('n', '<Leader>ama', '<Plug>(AiderSendAskMode)', {
    desc = 'Switch aider to ask mode',
})
keymap('n', '<Leader>amA', '<Plug>(AiderSendArchMode)', {
    desc = 'Switch aider to architect mode',
})
keymap('n', '<Leader>amc', '<Plug>(AiderSendCodeMode)', {
    desc = 'Switch aider to code mode',
})
keymap('n', '<Leader>aG', '<cmd>AiderRemovePrefix<cr>', {
    desc = 'remove aider prefix',
})
keymap('n', '<Leader>a<space>', '<cmd>checktime<cr>', {
    desc = 'sync file changes by aider to nvim buffer',
})
