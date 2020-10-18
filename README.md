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

## Vim stuff

Plugins are managed with https://github.com/junegunn/vim-plug

Run `:PlugUpdate` to install/update plugins, `:PlugUpgrade` to update vim-plug
itself.
