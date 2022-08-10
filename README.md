# configs
various config files

Actual config files are in the repository. The script `makelinks.sh` creates
soft links to them in the appropriate locations.

Use the `-f` option `./makelinks.sh -f` to remove existing files before
linking.

## Zsh stuff

Configure your terminal to use the recommended font here:
https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

Powerlevel10k is cloned/pulled by `./makelinks.sh`.

## Bash stuff

This is minimal to have a decent prompt when stuck with bash. The configuration
uses the [Starship prompt](https://starship.rs/) that you can install with

```shell
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -b ~/.local/bin
```

## Vim stuff

Plugins are managed with https://github.com/junegunn/vim-plug

Run `:PlugUpdate` to install/update plugins, `:PlugUpgrade` to update vim-plug
itself.

For `pylsp` to see system wide packages, edit

```shell
~/.local/share/vim-lsp-settings/servers/pylsp-all/venv/pyvenv.cfg
```

and make sure the following option is `true`:

```text
include-system-site-packages = true
```

## pacman hooks

They are useful on an arch system:

```shell
# mkdir -p /etc/pacman.d/hooks
# cp pacman/hooks/*.hook /etc/pacman.d/hooks
```

`pacman-contrib`, providing `paccache` is needed.
