# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt hist_find_no_dups
setopt hist_ignore_dups

bindkey -e

fpath+=~/.zfunc
zstyle :compinstall filename "~/.zshrc"

# completion of hostname uses only ssh config hosts
if [ -r ~/.ssh/config ]; then
    h=(${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
    zstyle ':completion:*:hosts' hosts $h
    unset h
fi

autoload -Uz compinit && compinit

function safesource () if [ -f "$1" ]; then source $1; fi

safesource /usr/share/doc/pkgfile/command-not-found.zsh

autoload -Uz sshmount sshumount

eval $(dircolors)  # set LS_COLORS

export PYENV_ROOT="${HOME}/.pyenv"

typeset -a add_to_path
add_to_path=(~/.local/bin
             "${PYENV_ROOT}/bin"
             ~/.cargo/bin)
typeset -U path
for dirname in ${add_to_path}; do
    if [ -d "${dirname}" ]; then
        path=(${dirname} ${path})
    fi
done
unset add_to_path
export PATH
export EDITOR=nvim
source ~/.alias

safesource /usr/share/zsh/site-functions/_pyenv

unfunction safesource

if which pyenv > /dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

source ~/.zshsynthl

source ~/.p10ktheme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
