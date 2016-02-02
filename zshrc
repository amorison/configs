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
    rm -ri $dirname
}

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr 'M' 
zstyle ':vcs_info:*' unstagedstr 'M' 
zstyle ':vcs_info:*' stashedstr '$'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats '%F{5} %F{2}%b%F{3}|%F{1}%a%F{5} %f '
zstyle ':vcs_info:*' formats '%F{3} %b  %F{2}%c%F{1}%u %F{6}%m%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stash
zstyle ':vcs_info:*' enable git 
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        [[ $(git ls-files --other --directory --exclude-standard | sed q | wc -l | tr -d ' ') == 1 ]] ; then
    hook_com[unstaged]+='%F{1}??%f'
fi
}
+vi-git-stash() {
  if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
    hook_com[misc]="%F{4}$"
  fi
}

precmd () { vcs_info }
#PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_} %f%# '

PROMPT='  %{$fg_bold[green]%}%~   ${vcs_info_msg_0_} %f
%{$fg_bold[red]%}%n%{$reset_color%}@%{$fg_bold[yellow]%}%M %{$reset_color%}%# '
