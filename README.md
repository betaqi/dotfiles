# dotfiles

我的 Mac 配置,用 GNU Stow 管理。

## 结构
- `mac/` — Stow packages(zsh / git / starship / karabiner)
- `windows/` — PowerShell profile / aliases / proxy / npm / starship
- `Brewfile` — Homebrew 软件清单
- `bootstrap.sh` — 新机器一键初始化
- `windows/bootstrap.ps1` — Windows PowerShell 配置链接脚本

## Mac 新机器还原
```bash
git clone <仓库地址> ~/dotfiles
cd ~/dotfiles && bash bootstrap.sh
```

## Windows 还原
```powershell
git clone <仓库地址> ~/dotfiles
cd ~/dotfiles && .\windows\bootstrap.ps1
```

`windows/bootstrap.ps1` 会把当前 `$PROFILE` 和 `~\.config\starship.toml` 软链接到仓库。
如果创建软链接失败,先开启 Windows Developer Mode,或用管理员权限重新打开 PowerShell 后再执行。
已有本地文件会自动备份为 `.bak-年月日-时分秒`;需要强制重建链接时使用:

```powershell
.\windows\bootstrap.ps1 -Force
```
## 维护命令(.dotfiles-helpers)

`mac/zsh/.dotfiles-helpers` 提供了一组快捷函数,由 `.zshrc` 自动加载。

| 命令 | 作用 | 何时用 |
|------|------|--------|
| `dot` | 跳转到 `~/dotfiles` 仓库目录 | 想进仓库时 |
| `dots` | 查看仓库改动状态(`git status -s`) | 想看改了哪些配置 |
| `dotpush "说明"` | 一键 `add + commit + push` | 改完任何配置后 |
| `dotbrew` | 重新导出 Brewfile 并提交推送 | 装了新软件后 |
| `dotpull` | 拉取最新配置(`git pull`) | 在另一台机器同步时 |
| `dotadd <包名> <路径>` | 把一个新配置纳入 stow 管理 | 想管理新的配置文件时 |
| `dotcheck` | 检查各配置是软链接还是普通文件 | 排查链接是否生效时 |

### 常用示例

```bash
# 改完 .zshrc 或别名后,提交推送
dotpush "调整 git 别名"

# 装了新软件,更新软件清单
brew install lazygit
dotbrew

# 把 nvim 配置纳入管理
dotadd nvim ~/.config/nvim

# 另一台机器拉取最新配置
dotpull && source ~/.zshrc

# 检查链接状态
dotcheck
```

> **注意**:用 `dotadd` 新增独立 package 后,记得手动把包名加进 `bootstrap.sh` 第 7 步的 `stow` 行,否则新机器不会自动链接它。
## 日常
- 改配置:直接编辑 `~/.zshrc` 等(软链接,实际改的是仓库文件)
- 新增软件后更新清单:`brew bundle dump --file=Brewfile --force`
- 加新 package:`mkdir mac/<name>` → mv 文件进去 → `stow -t ~ <name>`
- Windows 改 PowerShell 配置:编辑 `windows/*.ps1`
- Windows 重新加载配置:`reload`