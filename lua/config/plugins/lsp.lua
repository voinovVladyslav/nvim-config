return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                -- must load before lspconfig, it prepends mason/bin to PATH
                'mason-org/mason.nvim',
                config = function()
                    require('mason').setup()

                    local ensure_installed = {
                        'vue-language-server',
                        'vtsls',
                    }

                    local registry = require('mason-registry')
                    registry.refresh(function()
                        for _, name in ipairs(ensure_installed) do
                            local pkg = registry.get_package(name)
                            if not pkg:is_installed() then
                                pkg:install()
                            end
                        end
                    end)
                end,
            },
            {
                'saghen/blink.cmp'
            },
            {
                'b0o/schemastore.nvim'
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
                    },
                    format = {
                        enable = true
                    }
                }
            })
            vim.lsp.enable('ruff')


            vim.lsp.config(
                'basedpyright',
                {
                    settings = {
                        basedpyright = {
                            -- Using Ruff's import organizer
                            disableOrganizeImports = true,
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true
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
            vim.lsp.enable('basedpyright')

            -- js/ts/vue
            -- vue_ls v3 handles only html/css in .vue files, vtsls does TS
            -- through @vue/typescript-plugin, vue_ls forwards requests to it
            local vue_plugin = {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath('data')
                    .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                languages = { 'vue' },
                configNamespace = 'typescript',
            }

            vim.lsp.config('vtsls', {
                cmd = { 'vtsls', '--stdio' },
                filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
                settings = {
                    vtsls = {
                        tsserver = {
                            globalPlugins = { vue_plugin },
                        },
                    },
                },
                root_dir = function(bufnr, cb)
                    local root = vim.fs.root(bufnr, { 'tsconfig.json', 'package.json', 'jsconfig.json' })
                    if root then cb(root) end
                end,
                capabilities = require('blink.cmp').get_lsp_capabilities({
                    textDocument = {
                        completion = {
                            completionItem = {
                                labelDetailsSupport = true,
                                resolveSupport = {
                                    properties = { 'documentation', 'detail', 'labelDetails' },
                                },
                            },
                        },
                    },
                }),
            })
            vim.lsp.enable('vtsls')

            vim.lsp.config('vue_ls', {
                filetypes = { 'vue' },
                cmd = { "vue-language-server", "--stdio" },
                root_markers = { "package.json" },
            })
            vim.lsp.enable('vue_ls')

            -- rust
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
            vim.lsp.enable('rust_analyzer')

            -- go
            vim.lsp.config('gopls', {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_markers = { "go.work", "go.mod", ".git" },

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
            vim.lsp.enable('gopls')


            -- typst
            vim.lsp.config(
                'tinymist',
                {
                    cmd = { "tinymist" },
                    filetypes = { "typst" },
                }
            )
            vim.lsp.enable('tinymist')


            -- C
            vim.lsp.enable('clangd')


            -- json
            vim.lsp.config('jsonls', {
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            })
            vim.lsp.enable('jsonls')


            -- yaml
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        -- disable built-in schemastore, use schemastore.nvim instead
                        schemaStore = { enable = false, url = "" },
                        schemas = vim.tbl_extend('force', require('schemastore').yaml.schemas(), {
                            kubernetes = { "k8s/**/*.yaml", "k8s/**/*.yml" },
                        }),
                        validate = true,
                    },
                },
            })
            vim.lsp.enable('yamlls')


            vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end)
            vim.keymap.set('n', '<leader>gr', function() vim.lsp.buf.references() end)
            vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end)
            vim.keymap.set('n', '<leader>io', function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.organizeImports" }, diagnostics = {}, },
                    apply = true,
                })
            end)
            vim.keymap.set('n', '<leader>lf', function()
                vim.lsp.buf.format()
            end)

            vim.keymap.set('n', 'K', function()
                vim.lsp.buf.hover({ border = "rounded" })
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
