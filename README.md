# dotfiles

我的 Mac 配置,用 GNU Stow 管理。

## 结构
- `mac/` — Stow packages(zsh / git / starship / karabiner)
- `Brewfile` — Homebrew 软件清单
- `bootstrap.sh` — 新机器一键初始化

## 新机器还原
```bash
git clone <仓库地址> ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

## 日常
- 改配置:直接编辑 `~/.zshrc` 等(软链接,实际改的是仓库文件)
- 新增软件后更新清单:`brew bundle dump --file=Brewfile --force`
- 加新 package:`mkdir mac/<name>` → mv 文件进去 → `stow -t ~ <name>`
