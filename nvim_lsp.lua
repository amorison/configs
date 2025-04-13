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
