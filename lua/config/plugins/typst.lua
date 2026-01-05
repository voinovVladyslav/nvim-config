return {{
    'chomosuke/typst-preview.nvim',
    -- ft = 'typst',
    lazy = false,
    version = '1.*',
    opts = {
        open_cmd="firefox %s"
    }, -- lazy.nvim will implicitly calls `setup {}`
}}
