#!/bin/sh

# has to be executed from the same directory it lives in

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


# utility function to clone/pull a zsh theme/plugin
# or use the installed version
checkinstall () {
    installpath=$1  # installation path
    if [ -r "${installpath}" ]; then
        # if readable, we use that one
        echo "${installpath}"
        return 0
    fi
    gitrepo=$2  # git repository if need to install it
    gitname=${gitrepo##*/}
    gitdir=".zsh_gits/${gitname%.git}"  # local git repo
    # file itself, assume it is at root of git repo and as same name as when
    # installed via package.  Might need to make this an optional argument
    # later.
    filetosource="${PWD}/${gitdir}/${installpath##*/}"
    if [ -d "${gitdir}" ]; then
        git -C "${gitdir}" pull >&2
    else
        git clone --depth=1 "${gitrepo}" "${gitdir}" >&2
    fi
    echo "${filetosource}"
}

# alacritty
$linkcmd $PWD/alacritty.yml ~/.alacritty.yml

# alias
$linkcmd $PWD/alias ~/.alias

# LaTeX maker
$linkcmd $PWD/latexmkrc ~/.latexmkrc

# tmux
$linkcmd $PWD/tmux.conf ~/.tmux.conf

# vim
$linkcmd $PWD/vimrc ~/.vimrc
mkdir -p ~/.vim/ftplugin
$linkcmd $PWD/tex.vim  ~/.vim/ftplugin
curl --fail --location --create-dirs \
    -o ~/.vim/colors/wombat256.vim \
    https://raw.githubusercontent.com/vim-scripts/wombat256.vim/26fa8528ff1ac33a5b5039133968a3ee1856890f/colors/wombat256.vim \
    -o ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# bash
$linkcmd $PWD/bashrc ~/.bashrc

# zsh
$linkcmd $PWD/zshrc ~/.zshrc

# Powerlevel10k zsh theme
p10ktheme=$(checkinstall \
    '/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' \
    'https://github.com/romkatv/powerlevel10k.git')
$linkcmd $p10ktheme ~/.p10ktheme
# personal configuration
$linkcmd $PWD/p10k.zsh ~/.p10k.zsh

# zsh syntax highlighting
zshsynthl=$(checkinstall \
    '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' \
    'https://github.com/zsh-users/zsh-syntax-highlighting.git')
$linkcmd $zshsynthl ~/.zshsynthl

# my zsh functions
mkdir -p ~/.zfunc
$linkcmd $PWD/zfunc/sshmount ~/.zfunc
$linkcmd $PWD/zfunc/sshumount ~/.zfunc
