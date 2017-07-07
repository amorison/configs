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

# zsh
$linkcmd $PWD/zshrc ~/.zshrc
