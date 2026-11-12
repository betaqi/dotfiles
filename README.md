# 我的 dotfiles

我在 Mac 上用 Zsh，在 Windows 上用 PowerShell。这里放着两台电脑共用的 Starship 主题、各自的终端配置，以及我给 Codex 和 Claude Code 装的 skills。

[旧 Mac 的日常维护](#旧-mac-的日常维护) · [换一台 Mac](#换一台-mac) · [换 Windows](#换-windows)

## 旧 Mac 的日常维护

- **装了、改了或卸载了 skill**，先运行 `backup-skills`，再用 `dots` 看这次的变化。备份取自安装目录，删掉下载的 wechatide ZIP 也没关系。确认后提交并推送，其他电脑才能取到。[只提交并推送 skills](docs/skills.md#在-mac-上保存一次更新)
- **改了别名、提示符或截图快捷键**，直接用 `dots` 看改动，这些配置已经链接到仓库。如果列出的内容都要同步，运行 `dotpush "调整终端配置"`。它会提交并推送**整个仓库的改动**。
- **用 Homebrew 装了或卸载了软件**，想把软件清单也更新，就运行 `dotbrew`。它会更新、提交并推送 `Brewfile`。
- **另一台电脑推送了更新**，在这台 Mac 上运行 `dotpull`。终端配置拉取后新开终端即可生效。如果变动的是 skills，先核对本机改动，再把更新的文件复制回安装目录。[Mac 安装目录](docs/skills.md#在新-mac-恢复) · [Windows 接收更新](docs/skills.md#同步到-windows)

## 配置改哪里

在 Mac 终端输入 `dot` 就能进入仓库。比如要改提示符，直接编辑下面的 Starship 配置，终端读的就是这份文件。

| 想做什么 | 去哪里 |
| --- | --- |
| 改提示符、Git 分支或命令耗时的显示 | [Starship 主题](mac/starship/.config/starship.toml) |
| 加命令别名，比如 `gs` | [Mac 的 Zsh 别名](mac/zsh/.aliases) · [Windows 的 PowerShell 别名](windows/aliases.ps1) |
| 改终端启动配置或代理 | [Zsh 启动配置](mac/zsh/.zshrc) · [Mac 代理](mac/zsh/.proxyrc) · [PowerShell 启动配置](windows/Microsoft.PowerShell_profile.ps1) · [Windows 代理](windows/proxy.ps1) |
| 改截图快捷键 | [Snapzy 配置](mac/snapzy/.config/snapzy/config.toml) |
| 改下次装机的软件清单 | [Mac 的 Brewfile](Brewfile) · [Windows 的 winget 清单](windows/winget-packages.txt) · [Scoop 清单](windows/scoop-packages.txt) |

要把另一个工具的配置加进仓库，可以用 `dotadd`。[以 Neovim 为例](docs/terminal.md#在-mac-上改配置)

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
