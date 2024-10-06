# configs

Various config files.

The script `sync.py` (Python 3.8+) installs and creates soft links to config
files in the appropriate locations.

Use the `-f` option `./sync.py -f` to remove existing files before linking.

## Stuff to install manually

### Python

Install [uv to manage Python environments](https://docs.astral.sh/uv/getting-started/installation/).

### Neovim

Install neovim with your package manager _before_ running `sync.py`.  If `nvim`
is not in your `$PATH`, the script installs it.

The following LSP servers are used and need to be installed:

- Rust analyzer, available through `rustup`
- `clangd`, usually distributed as part of clang
- https://github.com/latex-lsp/texlab
- https://github.com/LuaLS/lua-language-server
- some servers are installed by `sync.py` via `uv`

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

Run `:Lazy` to manage plugins, `:checkhealth` to get some general diagnostics.

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

### backups

See `rustic/README.md` to set up backups with rustic. This will likely require
editing and therefore is not handled by `./sync.py`.
