return { {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                vue = {"prettier"},
                typescript = {"prettier"},
                javascript = { "prettier", },
                json = { "prettier", },
            },
        })
    end
} }
