export HISTCONTROL=ignoredups
export HISTCONTROL=ignoreboth

export LANG=C
export EDITOR=vim

source ~/.alias

source_if_present() { [[ -f "$1" ]] && source $1; }
source_if_present /etc/bash_completion
source_if_present /usr/share/lmod/lmod/init/bash

export PATH=~/bin:~/.local/bin:$PATH

if [[ $- == *i* ]]; then
    bind 'set show-all-if-ambiguous on'
    bind 'set completion-prefix-display-length 2'
    bind '\C-j:menu-complete'
    bind '\C-k:menu-complete-backward'
    source_if_present ~/.config/stagpy/bash/stagpy.sh
    eval "$(starship init bash)"
fi
