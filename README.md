# 我的 dotfiles

我在 Mac 上用 Zsh，在 Windows 上用 PowerShell。这里放着两台电脑共用的 Starship 主题、各自的终端配置，以及我给 Codex 和 Claude Code 装的 skills。

[旧 Mac 的日常维护](#旧-mac-的日常维护) · [Windows 日常维护](#windows-日常维护) · [换一台 Mac](#换一台-mac) · [换 Windows](#换-windows)

## 旧 Mac 的日常维护

| 什么时候用 | 运行什么 | 会做什么 |
| --- | --- | --- |
| 第一次想把某个工具的配置存进 dotfiles，比如 Neovim | `track-config nvim ~/.config/nvim` | 把配置移入仓库，在原位置建软链接。这一步只改本机，之后再用 `sync-dotfiles` 推送。[新 Mac 如何自动链接](docs/terminal.md#在-mac-上改配置) |
| 改了别名、提示符或截图快捷键，准备把仓库里的改动一起推送 | `sync-dotfiles "调整终端配置"` | 提交并推送**整个仓库的改动**。先用 `dots` 看一眼有哪些文件。 |
| 用 Homebrew 装了或卸载了软件，想更新装机清单 | `sync-brewfile` | 重新生成 `Brewfile`，有变化就只提交这个文件，然后推送。 |
| 安装、修改或卸载了 skill，想让其他电脑取到最新版本 | `sync-skills` | 先备份已安装的 skills，有变化就只提交 `skills/`，然后推送。 |

想先看看 skills 改了什么，可以运行 `backup-skills` 做本地备份，再用 `dots` 查看。[Skills 备份说明](docs/skills.md#在-mac-上保存一次更新)

另一台电脑推送了更新时，在这台 Mac 上运行 `dotpull`。终端配置拉取后新开终端即可生效。如果变动的是 skills，先核对本机改动，再把更新的文件复制回安装目录。[Mac 安装目录](docs/skills.md#在新-mac-恢复) · [Windows 接收更新](docs/skills.md#同步到-windows)

## Windows 日常维护

加载本仓库的 PowerShell 配置后，可以在任意目录运行这些命令。如果 Windows 已经配好、还在用旧版，先运行 `git -C "$HOME\dotfiles" pull --ff-only`，再新开一个 PowerShell 窗口。

| 什么时候用 | 运行什么 | 会做什么 |
| --- | --- | --- |
| 要进 dotfiles 仓库，或先看看改过哪些文件 | `dot` 或 `dots` | `dot` 切换目录，`dots` 在原地显示仓库状态。 |
| 要取回另一台电脑推送的配置 | `dotpull` | 快进拉取仓库更新。改了 PowerShell 配置后新开终端。 |
| 要把当前仓库的改动都推送出去 | `sync-dotfiles "更新 Windows 配置"` | 暂存全部改动，有变化就提交，最后推送当前分支。 |
| Mac 上刚运行过 `sync-skills`，Windows 要用新版 | `pull-skills` | 拉取仓库，再将两份 skills 复制到各自的安装目录，保留 Windows 独有的文件。[首次启用与清单选项](docs/skills.md#同步到-windows) |

输入 `gc` 提交，`gcm "说明"` 带说明提交，`gp` 推送。`gcam "说明"` 先暂存全部文件，暂存成功才会提交。

## 配置改哪里

在 Mac 终端输入 `dot` 就能进入仓库。比如要改提示符，直接编辑下面的 Starship 配置，终端读的就是这份文件。

| 想做什么 | 去哪里 |
| --- | --- |
| 改提示符、Git 分支或命令耗时的显示 | [Starship 主题](mac/starship/.config/starship.toml) |
| 加命令别名，比如 `gs` | [Mac 的 Zsh 别名](mac/zsh/.aliases) · [Windows 的 PowerShell 别名](windows/aliases.ps1) |
| 改终端启动配置或代理 | [Zsh 启动配置](mac/zsh/.zshrc) · [Mac 代理](mac/zsh/.proxyrc) · [PowerShell 启动配置](windows/Microsoft.PowerShell_profile.ps1) · [Windows 代理](windows/proxy.ps1) |
| 改截图快捷键 | [Snapzy 配置](mac/snapzy/.config/snapzy/config.toml) |
| 改下次装机的软件清单 | [Mac 的 Brewfile](Brewfile) · [Windows 的 winget 清单](windows/winget-packages.txt) · [Scoop 清单](windows/scoop-packages.txt) |

## 换一台 Mac

先在终端运行 `git --version`。如果 macOS 提示安装命令行开发者工具，装好后再克隆仓库。

```zsh
git clone https://github.com/betaqi/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh
```

脚本会安装 Brewfile 里的软件，配置 Zsh，并链接 Starship 和 Snapzy。完成后新开终端，运行 `dotcheck` 查看链接。接着可以[恢复旧 Mac 的 skills](docs/skills.md#在新-mac-恢复)。如果安装中断，见 [Mac 安装排错](docs/terminal.md#mac-安装排错)。

## 换 Windows

如果只想用 Mac 上的 skills，装好 Git 和 CC Switch 后，直接看[同步到 Windows](docs/skills.md#同步到-windows)。

要一起恢复终端主题和别名，先在 PowerShell 运行下面两行。已经装好的软件可以跳过。

```powershell
winget install --id Git.Git --exact
winget install --id Starship.Starship --exact
```

新开一个 PowerShell 窗口，下载仓库并加载配置。

```powershell
git clone https://github.com/betaqi/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
.\windows\bootstrap.ps1
```

已经克隆过仓库就从第二行开始。安装后重开同一种 PowerShell，提示符和别名就会加载。Windows PowerShell 5.1 和 PowerShell 7 各有自己的启动文件，两者都用就各运行一次脚本。[检查 PowerShell 配置](docs/terminal.md#windows-终端) · [批量安装 Windows 工具](docs/terminal.md#安装-windows-工具)

每台电脑单独设置 Git 姓名和邮箱。旧 Mac 如果还用着 Stow 链接的 Git 配置，升级前先看[旧版 Git 配置迁移](docs/terminal.md#旧版-git-配置迁移)。
