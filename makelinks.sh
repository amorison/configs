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

# vim
$linkcmd $PWD/vimrc ~/.vimrc

# x11
$linkcmd $PWD/xinitrc ~/.xinitrc

# zsh
$linkcmd $PWD/zcompdump ~/.zcompdump
$linkcmd $PWD/zprofile ~/.zprofile
$linkcmd $PWD/zshenv ~/.zshenv
$linkcmd $PWD/zshrc ~/.zshrc
