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

vim.keymap.set('n', '<Space>', '<Nop>', { silent = true, noremap = true })
vim.g.mapleader = ' '

require("lazy").setup("plugins", {
    change_detection = { enabled = false },
})

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.mouse = nil
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
vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        local floating = vim.api.nvim_win_get_config(0).relative ~= ""
        vim.diagnostic.config({
            virtual_text = floating,
            virtual_lines = not floating,
        })
    end,
})
