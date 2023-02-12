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

require("lazy").setup("plugins")

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

vim.keymap.set('n', '<Leader><Space>', ':nohlsearch<CR>', { silent = true, noremap = true })

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

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
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
