#!/bin/sh

forceflag=
while getopts f name
do
    case $name in
        f)    forceflag='-f';;
        ?)    echo '-f to force'
              exit 1;;
    esac
done

linkcmd="ln -s $forceflag"


# alias
$linkcmd $PWD/alias ~/.alias

# LaTeX maker
$linkcmd $PWD/latexmkrc ~/.latexmkrc

# tmux
$linkcmd $PWD/tmux.conf ~/.tmux.conf

# vim
$linkcmd $PWD/vimrc ~/.vimrc

# zsh
$linkcmd $PWD/zshrc ~/.zshrc

# Powerlevel10k zsh theme
# One check if it was installed with
#   pacman -S zsh-theme-powerlevel10k
# otherwise, clone/update it
p10ktheme=/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
if [ ! -f "$p10ktheme" ]; then
    p10kdir=$PWD/.p10ktheme
    if [ -d "$p10kdir" ]; then
        echo 'Update Powerlevel10k clone'
        git -C "$p10kdir" pull
    else
        echo 'Clone Powerlevel10k repo'
        p10krepo=https://github.com/romkatv/powerlevel10k.git
        git clone --depth=1 $p10krepo "$p10kdir"
    fi
    p10ktheme=$p10kdir/powerlevel10k.zsh-theme
fi
$linkcmd $p10ktheme ~/.p10ktheme
# personal configuration
$linkcmd $PWD/p10k.zsh ~/.p10k.zsh

# my zsh functions
mkdir -p ~/.zfunc
$linkcmd $PWD/zfunc/sshmount ~/.zfunc
$linkcmd $PWD/zfunc/sshumount ~/.zfunc
