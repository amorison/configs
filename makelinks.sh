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

# vim
$linkcmd $PWD/vimrc ~/.vimrc

# zsh
$linkcmd $PWD/zcompdump ~/.zcompdump
$linkcmd $PWD/zprofile ~/.zprofile
$linkcmd $PWD/zshenv ~/.zshenv
$linkcmd $PWD/zshrc ~/.zshrc
