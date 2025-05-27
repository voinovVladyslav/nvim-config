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
                        configurationPreference = "filesystemFirst",
                        lineLength = 80,
                        fixAll = false,
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


            -- js/ts/vue

            vim.lsp.config('ts_ls', {
                init_options = {
                    plugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = "/home/vlad/.nvm/versions/node/v24.0.2/lib/@vue/typescript-plugin",
                            languages = { "javascript", "typescript", "vue" },
                        },
                    },
                },
                filetypes = {
                    "javascript",
                    "typescript",
                    "vue",
                },
            })
            vim.lsp.enable('ts_ls')
            vim.lsp.config('vue_ls', {
                filetypes = { 'vue', }
            })
            vim.lsp.enable('vue_ls')
            vim.lsp.enable('eslint')

            vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end)
            vim.keymap.set('n', '<leader>gr', function() vim.lsp.buf.references() end)
            vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end)

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
