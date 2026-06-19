#!/usr/bin/env bash
# 新 Mac 初始化脚本:克隆本仓库后,在 ~/dotfiles 里跑 bash bootstrap.sh
set -e

echo "==> 1. 安装 Homebrew(如未安装)"
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "==> 2. 用 Brewfile 还原所有软件"
brew bundle --file="$(dirname "$0")/Brewfile"

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

echo "==> 5. 用 stow 链接配置"
brew install stow 2>/dev/null || true
cd "$(dirname "$0")/mac" && stow -t ~ zsh git starship karabiner

echo "✅ 完成!重启终端即可。"
