local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):
        match("%s") == nil
end

local function cmp_config()
    local cmp = require('cmp')
    local cmp_types = require("cmp.types")
    local snippy = require("snippy")

    cmp.setup({
        preselect = cmp_types.cmp.PreselectMode.None,
        snippet = {
            expand = function(args)
                snippy.expand_snippet(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif snippy.can_expand_or_advance() then
                    snippy.expand_or_advance()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif snippy.can_jump(-1) then
                    snippy.previous()
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "snippy" },
            { name = "nvim_lsp_signature_help" },
            { name = "path" },
        }, {
            { name = "buffer" },
        })
    })

    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } },
    })

    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = 'path' } },
            { { name = 'cmdline' } })
    })
end

local function lsp_config()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local lspconfig = require('lspconfig')

    lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false, },
            },
        },
    }

    lspconfig.rust_analyzer.setup { capabilities = capabilities, }

    lspconfig.cmake.setup { capabilities = capabilities, }

    lspconfig.clangd.setup { capabilities = capabilities }

    lspconfig.fortls.setup {
        capabilities = capabilities,
        cmd = {
            "fortls", "--notify_init", "--hover_signature",
            "--hover_language=fortran", "--use_signature_help",
            "--lowercase_intrinsics",
        },
    }

    lspconfig.pylsp.setup {
        capabilities = capabilities,
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = { maxLineLength = 100 },
                },
            },
        },
    }

    lspconfig.texlab.setup { capabilities = capabilities }
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
            tabline = {
                lualine_a = {
                    {
                        "tabs",
                        max_length = vim.opt.columns:get(),
                        mode = 2,
                    }
                },
            },
        },
        config = function(_, opts)
            require("lualine").setup(opts)
            vim.opt.showtabline = 1
        end,
    },
    {
        "neovim/nvim-lspconfig",
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
            }
        },
        config = lsp_config,
    },
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
            "dcampos/nvim-snippy",
            "dcampos/cmp-snippy",
            "honza/vim-snippets",
        },
        config = cmp_config,
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
