return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                'saghen/blink.cmp'
            },
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            -- lua
            vim.lsp.enable("lua_ls")

            -- python
            vim.lsp.config('ruff', {
                init_options = {
                    settings = {
                        -- Ruff language server settings go here
                    }
                }
            })

            vim.lsp.enable('ruff')

            vim.lsp.config(
                'pyright',
                {
                    settings = {
                        pyright = {
                            -- Using Ruff's import organizer
                            disableOrganizeImports = true,
                        },
                        python = {
                            analysis = {
                                -- Ignore all files for analysis to exclusively use Ruff for linting
                                ignore = { '*' },
                            },
                        },
                    },
                }
            )


            vim.lsp.enable('pyright')

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    if client.name == 'ruff' then
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end


                    if client:supports_method("textDocument/formatting") then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                            end
                        })
                    end
                end
            })
        end
    }
}
