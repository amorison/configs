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

# bspwm and sxhkd
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd
chmod u+x bspwmrc
$linkcmd $PWD/bspwmrc ~/.config/bspwm/bspwmrc
$linkcmd $PWD/sxhkdrc ~/.config/sxhkd/sxhkdrc

# LaTeX maker
$linkcmd $PWD/latexmkrc ~/.latexmkrc

# termite
mkdir -p ~/.config/termite
$linkcmd $PWD/termite ~/.config/termite/config

# vim
$linkcmd $PWD/vimrc ~/.vimrc

# x11
$linkcmd $PWD/xinitrc ~/.xinitrc

# zsh
$linkcmd $PWD/zcompdump ~/.zcompdump
$linkcmd $PWD/zprofile ~/.zprofile
$linkcmd $PWD/zshenv ~/.zshenv
$linkcmd $PWD/zshrc ~/.zshrc
