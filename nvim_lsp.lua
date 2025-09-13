local servers = {
    basedpyright = {
        basedpyright = {
            diagnosticMode = "openFilesOnly",
            disableOrganizeImports = true,
        },
    },
    clangd = {},
    eslint = {},
    fortls = {
        cmd = {
            "fortls", "--notify_init", "--hover_signature",
            "--hover_language=fortran", "--use_signature_help",
            "--lowercase_intrinsics",
        },
    },
    jdtls = {},
    jsonls = {},
    lua_ls = {
        settings = {
            Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false, },
                format = { defaultConfig = { align_array_table = "false" } },
            },
        },
    },
    ruff = {
        init_options = {
            settings = {
                lint = {
                    extendSelect = { "I" },
                },
            },
        },
    },
    rust_analyzer = {},
    texlab = {},
    tinymist = {
        root_markers = { "typst.toml", ".git" },
    },
    ts_ls = {},
}

vim.lsp.inlay_hint.enable(true)

for name, conf in pairs(servers) do
    vim.lsp.config(name, conf)
    vim.lsp.enable(name)
end
