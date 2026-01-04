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
            local util = require("lspconfig.util")

            local function get_tsdk()
                local root_dir = util.root_pattern("package.json", "tsconfig.json", ".git")(vim.fn.expand("%:p"))
                if root_dir then
                    local tsdk = root_dir .. "/node_modules/typescript/lib"
                    if vim.fn.isdirectory(tsdk) == 1 then
                        return tsdk
                    end
                end
                -- fallback global path
                return vim.fn.expand("~/.nvm/versions/node/v24.0.2/lib/node_modules/typescript/lib")
            end

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
            vim.lsp.config('vue_ls', {
                filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
                cmd = { "vue-language-server", "--stdio" },
                root_markers = { "package.json" },
                init_options = {
                    typescript = {
                        tsdk = get_tsdk()
                    },
                    vue = {
                        hybridMode = false,
                    },
                },
            })
            vim.lsp.enable('vue_ls')
            vim.lsp.config('tsserver', {})
            vim.lsp.enable('tsserver')

            vim.lsp.config('rust_analyzer', {
                on_attach = function(client, bufnr)
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end,
                settings = {
                    ['rust-analyzer'] = {
                        diagnostics = {
                            enable = false,
                        },
                        imports = {
                            granularity = {
                                group = "module",
                            },
                            prefix = "self",
                        },
                        cargo = {
                            buildScripts = {
                                enable = true,
                            },
                        },
                        procMacro = {
                            enable = true
                        },
                    },
                }
            })
            -- rust
            vim.lsp.enable('rust_analyzer')

            -- go
            vim.lsp.enable('gopls')
            local lspconfig = require("lspconfig")

            lspconfig.gopls.setup({
              cmd = { "gopls" },
              filetypes = { "go", "gomod", "gowork", "gotmpl" },
              root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),

              settings = {
                gopls = {
                  gofumpt = true,
                  staticcheck = true,
                  analyses = {
                    unusedparams = true,
                    shadow = true,
                  },
                },
              },
            })


            -- typst
            vim.lsp.config(
                'tinymist',
                {
                    cmd = { "tinymist" },
                    filetypes = { "typst" },
                }
            )
            vim.lsp.enable('tinymist')


            vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end)
            vim.keymap.set('n', '<leader>gr', function() vim.lsp.buf.references() end)
            vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end)
            vim.keymap.set('n', '<leader>lf', function()
                vim.lsp.buf.format()
                vim.cmd(":w")
            end)

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    if client.name == 'ruff' then
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end

                    if client.name == 'rust_analyzer' then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                    end
                end
            })
        end
    }
}
