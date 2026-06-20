#!/usr/bin/env bash
# 新 Mac 初始化脚本:克隆本仓库后,在 ~/dotfiles 里跑 bash bootstrap.sh
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> 1. 安装 Homebrew(如未安装)"
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "==> 2. 选择并安装软件"
command -v gum >/dev/null || brew install gum
LIST="$( { echo "ALL ✅ 全部安装(等于 brew bundle)";
           grep -E '^(brew|cask) ' "$DIR/Brewfile" \
             | sed -E 's/^(brew|cask) "([^"]+)".*/\1 \2/'; } )"
SELECTED="$(echo "$LIST" | gum choose --no-limit --height 25 \
  --header "空格选择 / 回车确认 / Ctrl-C 跳过安装")"
if [ -z "$SELECTED" ]; then
  echo "    未选择,跳过软件安装"
elif echo "$SELECTED" | grep -q "^ALL "; then
  echo "    安装全部(brew bundle)"
  brew bundle --file="$DIR/Brewfile" || echo "    ⚠️ 部分软件未装成功,可稍后手动补装"
else
  echo "$SELECTED" | while read -r type name; do
    [ "$type" = "ALL" ] && continue
    if [ "$type" = "cask" ]; then
      echo "    cask: $name"; brew install --cask "$name" || echo "      ⚠️ $name 跳过"
    else
      echo "    brew: $name"; brew install "$name" || echo "      ⚠️ $name 跳过"
    fi
  done
fi

echo "==> 3. 安装 oh-my-zsh(如未安装)"
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> 4. 克隆外部 zsh 插件"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local name="$1" url="$2"
  if [ ! -d "$ZSH_CUSTOM/plugins/$name" ]; then
    git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
  fi
}
clone_plugin fast-syntax-highlighting    https://github.com/zdharma-continuum/fast-syntax-highlighting
clone_plugin zsh-autosuggestions         https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search

echo "==> 5. 确保默认 shell 是 zsh"
ZSH_PATH="$(command -v zsh)"
if [ "$(dscl . -read /Users/$(whoami) UserShell 2>/dev/null | awk '{print $2}')" != "$ZSH_PATH" ]; then
  echo "    当前默认 shell 不是 zsh,切换中(可能需要输入密码)..."
  grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_PATH"
else
  echo "    已是 zsh,跳过"
fi

echo "==> 6. 清理冲突的默认文件,再用 stow 链接配置"
brew install stow 2>/dev/null || true
# oh-my-zsh / 系统会生成默认 .zshrc /.zprofile 等,挡住 stow。先把"非软链接"的同名文件备份移走
TS="$(date +%Y%m%d-%H%M%S)"
backup_if_real_file() {
  local f="$HOME/$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then   # 存在 且 不是软链接
    echo "    备份挡路文件 $1 -> $1.bak-$TS"
    mv "$f" "$f.bak-$TS"
  fi
}
backup_if_real_file .zshrc
backup_if_real_file .zprofile
backup_if_real_file .aliases
[ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ] && {
  echo "    备份挡路文件 .config/starship.toml"
  mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak-$TS"
}

cd "$DIR/mac"
stow -t ~ zsh starship karabiner
read -r -p "    是否链接 git 配置(.gitconfig)? 新机器/共用机器建议跳过 [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  stow -t ~ git && echo "    已链接 git 配置"
else
  echo "    已跳过 git;日后需要时手动: cd ~/dotfiles/mac && stow -t ~ git"
fi

echo "✅ 完成!重启终端即可。"
