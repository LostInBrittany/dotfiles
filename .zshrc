setopt NO_AUTO_LIST BASH_AUTO_LIST NO_MENU_COMPLETE NO_AUTO_MENU
setopt INTERACTIVE_COMMENTS
unsetopt BEEP

autoload -U colors && colors
#export PS1="%{$fg[blue]%}%n@%m:%~ $ %{$reset_color%}"
export PS1="%F{088}%n@%m:%F{blue}%~ %F{088}$ %f"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

export GPG_TTY=$(tty)


export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# bun completions
[ -s "/Users/horacio/.bun/_bun" ] && source "/Users/horacio/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pyenv
eval "$(pyenv init -)"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"


alias python=python3

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/horacio/.lmstudio/bin"
# End of LM Studio CLI section


# Added by BVM (BoxLang Version Manager) installer
export PATH="/Users/horacio/.bvm/bin:$PATH"

# BVM environment setup
export BVM_HOME="/Users/horacio/.bvm"

# BVM provides BoxLang binaries through wrappers when no version is active
# Current version takes precedence when available
if [ -L "$BVM_HOME/current" ]; then
    export PATH="$BVM_HOME/current/bin:$PATH"
fi

# Added by Antigravity
export PATH="/Users/horacio/.antigravity/antigravity/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/horacio/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
