vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when copying (yanking) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Disables <C-l> for netrw to allow global mapping work instead",
  pattern = "netrw",
  callback = function()
    pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<C-l>")
  end,
})
