return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },
    config = function()
        require('telescope').setup {
            pickers = {
                find_files = {
                    hidden = true,
                    file_ignore_patterns = { '^%.git/' },
                },
                live_grep = {
                    additional_args = { '--hidden' },
                    file_ignore_patterns = { '^%.git/' },
                },
            },
            extensions = {
                fzf = {}
            }
        }
        require('telescope').load_extension('fzf')
        vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
        vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep)
        vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags)
        vim.keymap.set('n', '<leader>fs', require('telescope.builtin').search_history)
        vim.keymap.set('n', '<leader>fb', require('telescope.builtin').git_branches)
        vim.keymap.set('n', '<leader>fc', require('telescope.builtin').git_commits)
    end
}
