local function lsp_config(_, opts)
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local lspconfig = require('lspconfig')

    lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false, },
                format = { defaultConfig = { align_array_table = "false" } },
            },
        },
    }

    lspconfig.rust_analyzer.setup { capabilities = capabilities, }

    lspconfig.clangd.setup { capabilities = capabilities }

    lspconfig.fortls.setup {
        capabilities = capabilities,
        cmd = {
            "fortls", "--notify_init", "--hover_signature",
            "--hover_language=fortran", "--use_signature_help",
            "--lowercase_intrinsics",
        },
    }

    lspconfig.jsonls.setup { capabilities = capabilities }

    lspconfig.basedpyright.setup {
        capabilities = capabilities,
        basedpyright = {
            diagnosticMode = "openFilesOnly",
            disableOrganizeImports = true,
        },
    }

    lspconfig.ruff.setup {
        capabilities = capabilities,
        init_options = {
            settings = {
                lint = {
                    extendSelect = { "I" },
                },
            },
        },
    }

    lspconfig.texlab.setup { capabilities = capabilities }

    lspconfig.tinymist.setup {
        capabilities = capabilities,
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern("typst.toml", ".git")(fname)
                or vim.fn.getcwd()
        end,
    }

    if opts.inlay_hints.enabled then
        vim.lsp.inlay_hint.enable(true)
    end
end

return {
    {
        "rebelot/kanagawa.nvim",
        priority = 100,
        opts = {
            dimInactive = true,
        },
        config = function(_, opts)
            require('kanagawa').setup(opts)
            vim.cmd("colorscheme kanagawa")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            sections = {
                lualine_b = { 'branch', 'diff' },
                lualine_c = { { 'filename', newfile_status = true, path = 1 } },
                lualine_x = { 'diagnostics' },
            },
            inactive_sections = {
                lualine_c = { { 'filename', newfile_status = true, path = 1 } },
                lualine_x = { 'diagnostics', 'location' },
            },
        },
    },
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                mode = "tabs",
                numbers = function(opts)
                    return string.format("%s", opts.raise(opts.ordinal))
                end,
                show_buffer_close_icons = false,
                show_close_icon = false,
                hover = { enable = false },
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(_, level)
                    local icon = ""
                    icon = level:match("warning") and "" or icon
                    icon = level:match("error") and "" or icon
                    return icon
                end,
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = true },
        },
        dependencies = {
            {
                "folke/neodev.nvim",
                opts = {
                    override = function(root_dir, library)
                        local stat = vim.loop.fs_stat(root_dir .. "/nvim.lua")
                        if stat and stat.type then
                            library.enabled = true
                            library.plugins = true
                        end
                    end,
                },
            },
            "saghen/blink.cmp",
        },
        config = lsp_config,
    },
    {
        "j-hui/fidget.nvim",
        config = true,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })()
        end,
        config = function()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "fortran", "python", "cmake", "just", "typst" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text_pos = "right_align",
            },
            current_line_blame_formatter = "<abbrev_sha>, <author_time:%Y-%m-%d> - <summary>",
        },
    },
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "*",
        opts = {
            completion = {
                list = { selection = { preselect = false, auto_insert = true } },
            },
            keymap = {
                preset = "enter",
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.is_menu_visible() then
                            return require("blink.cmp").select_next()
                        elseif cmp.snippet_active() then
                            return cmp.snippet_forward()
                        end
                    end,
                    "fallback",
                },
                ["<S-Tab>"] = {
                    function(cmp)
                        if cmp.is_menu_visible() then
                            return require("blink.cmp").select_prev()
                        elseif cmp.snippet_active() then
                            return cmp.snippet_backward()
                        end
                    end,
                    "fallback",
                },
            },
            signature = {
                enabled = true,
                window = { border = "rounded" },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "glacambre/firenvim",
        cond = not not vim.g.started_by_firenvim,
        build = function()
            require("lazy").load({ plugins = { "firenvim" }, wait = true })
            vim.fn['firenvim#install'](0)
        end,
        init = function()
            vim.g.firenvim_config = {
                localSettings = {
                    [".*"] = {
                        takeover = "never",
                    },
                },
            }
        end,
        config = function()
            if vim.g.started_by_firenvim then
                vim.opt.background = "light"
            end
        end,
    }
}
