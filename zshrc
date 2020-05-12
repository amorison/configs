# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e

fpath+=~/.zfunc
zstyle :compinstall filename "~/.zshrc"
autoload -U compinit
compinit
source /usr/share/doc/pkgfile/command-not-found.zsh

autoload -Uz sshmount sshumount

eval $(dircolors)  # set LS_COLORS
autoload -U colors && colors

typeset -U path
path=(~/bin ~/.local/bin $path)
export EDITOR=vim
source ~/.alias


source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
