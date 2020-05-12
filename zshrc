# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "~/.zshrc"

autoload -U compinit
compinit
# End of lines added by compinstall

source /usr/share/doc/pkgfile/command-not-found.zsh

source ~/.alias

eval $(dircolors ~/.dircolors)
. /etc/profile.d/vte.sh

autoload -U colors && colors

sshmount () {
    dirname=~/$1
    if [ -d "${dirname}" ]
    then
        echo "${dirname} already exists, abort."
    else
        mkdir "${dirname}"
        sshfs -C $1:. "${dirname}"
    fi
}

sshumount () {
    dirname=~/$1
    fusermount -u "${dirname}"
    rmdir $dirname
}

export EDITOR=vim

typeset -U path
path=(~/bin ~/.local/bin $path)

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
