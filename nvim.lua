local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

vim.keymap.set('n', '<Space>', '<Nop>', { silent = true, noremap = true })
vim.g.mapleader = ' '

require("lazy").setup("plugins", {
    change_detection = { enabled = false },
    rocks = { enabled = false },
})

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.mouse = ""
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.list = true
vim.opt.listchars = { tab = "•·❯", trail = "•" }

vim.keymap.set('n', '<Leader><Space>', ':nohlsearch<CR>', { silent = true, noremap = true })

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, { silent = true })
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action, { buffer = args.buf })
        vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, { buffer = args.buf })
    end,
})
vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.lsp.inlay_hint.enable(true)

vim.lsp.enable("clangd")
vim.lsp.enable("jsonls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("texlab")

vim.lsp.enable("basedpyright")
vim.lsp.config("basedpyright", {
    basedpyright = {
        diagnosticMode = "openFilesOnly",
        disableOrganizeImports = true,
    },
})

vim.lsp.enable("fortls")
vim.lsp.config("fortls", {
    cmd = {
        "fortls", "--notify_init", "--hover_signature",
        "--hover_language=fortran", "--use_signature_help",
        "--lowercase_intrinsics",
    },
})

vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false, },
            format = { defaultConfig = { align_array_table = "false" } },
        },
    },
})

vim.lsp.enable("ruff")
vim.lsp.config("ruff", {
    init_options = {
        settings = {
            lint = {
                extendSelect = { "I" },
            },
        },
    },
})

vim.lsp.enable("tinymist")
vim.lsp.config("tinymist", {
    root_markers = { "typst.toml", ".git" },
})
