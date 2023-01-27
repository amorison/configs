vim.o.relativenumber = true
vim.o.number = true
vim.o.cursorline = true
vim.o.mouse = nil
vim.o.termguicolors = true

vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

vim.o.list = true
vim.o.listchars = "tab:•·❯,trail:•"

vim.keymap.set('n', '<Space>', ':nohlsearch<Bar>:echo<CR>')

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd("packadd packer.nvim")
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'rebelot/kanagawa.nvim'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    }
    use 'neovim/nvim-lspconfig'
    use 'j-hui/fidget.nvim'

    use 'lewis6991/gitsigns.nvim'

    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/vim-vsnip'
    use {
        'glacambre/firenvim',
        run = function() vim.fn['firenvim#install'](0) end
    }

    if packer_bootstrap then
        require("packer").sync()
    end
end)

local hi_grp = vim.api.nvim_create_augroup("custom_hi", { clear = true })
vim.api.nvim_create_autocmd({"VimEnter", "WinEnter"}, {
    command = [[match At80thCol /\%>79v.*\n\@!\%<81v/]],
    group = hi_grp,
})

require("gitsigns").setup({
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text_pos = "right_align",
    },
    current_line_blame_formatter = "<abbrev_sha>, <author_time:%Y-%m-%d> - <summary>",
})

require("lualine").setup({
    sections = {
        lualine_b = {'branch', 'diff'},
        lualine_x = {'diagnostics'},
    },
    inactive_sections = {
        lualine_x = {'diagnostics', 'location'},
    },
})

require('kanagawa').setup({
    dimInactive = true,
    overrides = {
        MatchParen = { bg = "#aa435c", fg = "#f4a261" },
        At80thCol = { bg = "#000040" },
    },
})
if vim.g.started_by_firenvim then
    vim.o.background = "light"
end
vim.cmd("colorscheme kanagawa")

vim.g.firenvim_config = {
    localSettings = {
        [".*"] = {
            takeover = "never",
        },
    },
}

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

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.keymap.set({'n', 'i'}, '<C-k>', vim.lsp.buf.code_action,
                       { buffer = args.buf })
    end,
})

require("fidget").setup()

local cmp = require('cmp')
local cmp_types = require("cmp.types")

cmp.setup({
    preselect = cmp_types.cmp.PreselectMode.None,
    snippet = {
        expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
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
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
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
            diagnostics = { globals = {'vim'} },
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
