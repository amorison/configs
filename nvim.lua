local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "rebelot/kanagawa.nvim",
        priority = 100,
        config = function()
            require('kanagawa').setup({
                dimInactive = true,
                overrides = {
                    MatchParen = { bg = "#aa435c", fg = "#f4a261" },
                },
            })
            if vim.g.started_by_firenvim then
                vim.o.background = "light"
            end
            vim.cmd("colorscheme kanagawa")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
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
})

vim.o.relativenumber = true
vim.o.number = true
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.mouse = nil
vim.o.termguicolors = true

vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.o.list = true
vim.o.listchars = "tab:•·❯,trail:•"

vim.keymap.set('n', '<Space>', '<Nop>', { silent = true, noremap = true })
vim.g.mapleader = ' '
vim.keymap.set('n', '<Leader><Space>', ':nohlsearch<Bar>:echo<CR>', { silent = true, noremap = true })

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

require("lualine").setup({
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
})
vim.o.showtabline = 1

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):
        match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(key, true, true, true),
        mode,
        true)
end

vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, { silent = true })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true })
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, { buffer = args.buf })
        vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, { buffer = args.buf })
    end,
})
vim.api.nvim_create_autocmd('BufWritePre', {
    callback = vim.lsp.buf.formatting_sync
})

local cmp = require('cmp')
local cmp_types = require("cmp.types")

cmp.setup({
    preselect = cmp_types.cmp.PreselectMode.None,
    snippet = {
        expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs( -4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"]( -1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources(
        { { name = 'nvim_lsp' }, { name = 'vsnip' } },
        { { name = 'nvim_lsp_signature_help' }, { name = 'buffer' } })
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require('lspconfig')

lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
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
