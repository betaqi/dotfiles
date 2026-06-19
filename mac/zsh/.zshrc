# >>> ghost-complete initialize >>>
# !! Contents within this block are managed by 'ghost-complete install' !!
if [[ -f '/Users/taqibe/.config/ghost-complete/shell/init.zsh' ]]; then
  builtin source '/Users/taqibe/.config/ghost-complete/shell/init.zsh'
else
  echo "ghost-complete: init script missing: "'/Users/taqibe/.config/ghost-complete/shell/init.zsh' >&2
  echo "ghost-complete: run 'ghost-complete install' to restore it" >&2
fi
# <<< ghost-complete initialize <<<
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
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
export PATH="/Users/taqibe/.codeium/windsurf/bin:$PATH"
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
source "$HOME/.sdkman/bin/sdkman-init.sh"

source ~/.proxyrc
source ~/.aliases

# Added by Windsurf
export PATH="/Users/taqibe/.codeium/windsurf/bin:$PATH"

# Added by Antigravity
export PATH="/Users/taqibe/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

source '/Users/taqibe/.config/ghost-complete/shell/ghost-complete.zsh'
# <<< ghost-complete shell integration <<<
