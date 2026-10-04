return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            ts.install({
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
                "python",
                "rust",
                "go",
                "html",
                "htmldjango",
                "javascript",
                "typescript",
                "vue",
                "terraform",
                "scss",
                "css",
                "git_rebase",
                "toml",
            })

            local max_filesize = 100 * 1024 -- 100 KB

            local function start(buf)
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return
                end
                pcall(vim.treesitter.start, buf)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang then
                        return
                    end
                    -- auto install missing parsers (replaces old `auto_install = true`)
                    if not vim.list_contains(ts.get_installed(), lang)
                        and vim.list_contains(ts.get_available(), lang) then
                        ts.install(lang):await(vim.schedule_wrap(function()
                            if vim.api.nvim_buf_is_valid(args.buf) then
                                start(args.buf)
                            end
                        end))
                        return
                    end
                    start(args.buf)
                end,
            })
        end,
    },
}
