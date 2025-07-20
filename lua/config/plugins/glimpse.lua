return {
    {
        dir = "~/projects/glimpse.nvim",
        config = function()
            local glimpse = require "glimpse"
            glimpse.setup()
            vim.keymap.set("n", "<leader>o", glimpse.open_glimpse)
        end
    }
}
