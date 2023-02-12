return {
    {
        "rebelot/kanagawa.nvim",
        priority = 100,
        opts = {
            dimInactive = true,
        },
        config = function(_, opts)
            require('kanagawa').setup(opts)
            if vim.g.started_by_firenvim then
                vim.o.background = "light"
            end
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
            tabline = {
                lualine_a = {
                    {
                        "tabs",
                        max_length = vim.o.columns,
                        mode = 2,
                    }
                },
            },
        },
        config = function(_, opts)
            require("lualine").setup(opts)
            vim.o.showtabline = 1
        end,
    },
    "neovim/nvim-lspconfig",
    {
        "j-hui/fidget.nvim",
        config = true,
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
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
        },
    },
    {
        "glacambre/firenvim",
        build = function() vim.fn['firenvim#install'](0) end,
        init = function()
            vim.g.firenvim_config = {
                localSettings = {
                    [".*"] = {
                        takeover = "never",
                    },
                },
            }
        end,
    }
}
