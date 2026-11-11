if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if java21_home=$(/usr/libexec/java_home -F -v 21 2>/dev/null); then
  export JAVA_HOME="$java21_home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
unset java21_home

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
