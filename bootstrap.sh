#!/usr/bin/env bash
# 新 Mac 初始化脚本:克隆本仓库后,在 ~/dotfiles 里跑 bash bootstrap.sh
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> 1. 安装 Homebrew(如未安装)"
command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "==> 2. 信任 Brewfile 用到的第三方 tap"
# 第三方 tap 默认不受信任,会导致里面的软件(如 ghost-complete)被静默忽略
grep -E '^tap ' "$DIR/Brewfile" | sed -E 's/^tap "([^"]+)".*/\1/' | while read -r t; do
  brew trust "$t" 2>/dev/null && echo "    trusted: $t" || true
done

echo "==> 3. 用 Brewfile 安装全部软件(保证不漏)"
brew bundle --file="$DIR/Brewfile" || echo "    ⚠️ 部分软件未装成功,可稍后手动补装,继续..."

echo "==> 4. 安装 oh-my-zsh(如未安装)"
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> 5. 克隆外部 zsh 插件"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_plugin() {
  local name="$1" url="$2"
  [ -d "$ZSH_CUSTOM/plugins/$name" ] || git clone --depth=1 "$url" "$ZSH_CUSTOM/plugins/$name"
}
clone_plugin fast-syntax-highlighting    https://github.com/zdharma-continuum/fast-syntax-highlighting
clone_plugin zsh-autosuggestions         https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search

echo "==> 6. 确保默认 shell 是 zsh"
ZSH_PATH="$(command -v zsh)"
if [ "$(dscl . -read /Users/$(whoami) UserShell 2>/dev/null | awk '{print $2}')" != "$ZSH_PATH" ]; then
  echo "    切换默认 shell 为 zsh(可能需要输入密码)..."
  grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$ZSH_PATH"
else
  echo "    已是 zsh,跳过"
fi

echo "==> 7. 清理冲突的默认文件,再用 stow 链接配置"
brew install stow 2>/dev/null || true
TS="$(date +%Y%m%d-%H%M%S)"
backup_if_real_file() {
  local f="$HOME/$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    echo "    备份挡路文件 $1 -> $1.bak-$TS"
    mv "$f" "$f.bak-$TS"
  fi
}
backup_if_real_file .zshrc
backup_if_real_file .zprofile
backup_if_real_file .aliases
if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
  echo "    备份挡路文件 .config/starship.toml"
  mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak-$TS"
fi

cd "$DIR/mac"
stow -t ~ zsh starship karabiner snapzy
read -r -p "    是否链接 git 配置(.gitconfig)? 新机器/共用机器建议跳过 [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  stow -t ~ git && echo "    已链接 git 配置"
else
  echo "    已跳过 git;日后需要时手动: cd ~/dotfiles/mac && stow -t ~ git"
fi

echo "✅ 完成!重启终端即可。"