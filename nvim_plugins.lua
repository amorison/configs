local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):
        match("%s") == nil
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
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
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

            ---@diagnostic disable-next-line: missing-fields
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
                documentation = { auto_show = true },
            },
            keymap = {
                preset = "enter",
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.is_menu_visible() then
                            return require("blink.cmp").select_next()
                        elseif cmp.snippet_active() then
                            return cmp.snippet_forward()
                        elseif has_words_before() then
                            return cmp.show()
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
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    path = { opts = { show_hidden_files_by_default = true } },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "glacambre/firenvim",
        lazy = not vim.g.started_by_firenvim,
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
