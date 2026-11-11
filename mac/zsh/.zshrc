if [[ -f "$HOME/.config/ghost-complete/shell/init.zsh" ]]; then
  builtin source "$HOME/.config/ghost-complete/shell/init.zsh"
else
  echo "ghost-complete: init script missing: ""$HOME/.config/ghost-complete/shell/init.zsh" >&2
  echo "ghost-complete: run 'ghost-complete install' to restore it" >&2
fi

export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel10k/powerlevel10k"
eval "$(starship init zsh)"
plugins=(
    git
    fast-syntax-highlighting
    zsh-autosuggestions
    history-substring-search
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"

source ~/.proxyrc
source ~/.aliases
source ~/.dotfiles-helpers

export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

[ -f "$HOME/.config/ghost-complete/shell/ghost-complete.zsh" ] && source "$HOME/.config/ghost-complete/shell/ghost-complete.zsh"
