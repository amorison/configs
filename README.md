# configs

Various config files.

The script `sync.py` (Python 3.8+) installs and creates soft links to config
files in the appropriate locations.

Use the `-f` option `./sync.py -f` to remove existing files before linking.

## Stuff to install manually

### Neovim

With your package manager or [from the release
page](https://github.com/neovim/neovim/releases/tag/stable)

The following LSP servers are used:

- Rust analyzer, available through `rustup`
- `python-language-server[all]` along with `pyls-mypy`, available on PyPI
- `clangd`, usually distributed as part of clang
- `fortls`, available on PyPI
- `cmake-language-server`, available on PyPI
- https://github.com/latex-lsp/texlab
- https://github.com/sumneko/lua-language-server

### Starship

With your package manager or the installation script:

```shell
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -b ~/.local/bin
```

### Terminal font

Configure your terminal to use the recommended font here:
https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

## Other remarks

### Neovim

Run `:PackerSync` to install/update plugins. Packer is installed and synced
automatically when starting `nvim` for the first time on a fresh install with
this config.

### Vim

Plugins are managed with https://github.com/junegunn/vim-plug

Run `:PlugUpdate` to install/update plugins, `:PlugUpgrade` to update vim-plug
itself.

### pacman hooks

They are useful on an arch system:

```shell
# mkdir -p /etc/pacman.d/hooks
# cp pacman/hooks/*.hook /etc/pacman.d/hooks
```

`pacman-contrib`, providing `paccache`, is needed.
