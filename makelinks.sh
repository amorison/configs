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

# vim
ln -s $forceflag $PWD/vimrc ~/.vimrc

# zsh
ln -s $forceflag $PWD/zcompdump ~/.zcompdump
ln -s $forceflag $PWD/zprofile ~/.zprofile
ln -s $forceflag $PWD/zshenv ~/.zshenv
ln -s $forceflag $PWD/zshrc ~/.zshrc
