# Lines configured by zsh-newuser-install
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=32767
SAVEHIST=32767

unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/rojikaru/.zshrc'

autoload -Uz compinit up-line-or-beginning-search down-line-or-beginning-search
compinit
# End of lines added by compinstall

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Source everything
source $XDG_CONFIG_HOME/zsh/rc
