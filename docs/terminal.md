# 终端设置与排错

[Mac 安装排错](#mac-安装排错) · [Windows 终端](#windows-终端) · [安装 Windows 工具](#安装-windows-工具) · [旧版 Git 配置迁移](#旧版-git-配置迁移)

## 在 Mac 上改配置

要改终端提示符，可以直接打开它的配置文件。

```zsh
dot
open -e mac/starship/.config/starship.toml
```

保存后按回车就能看到新样式。输入 `dots` 查看仓库改动，`git diff -- mac/starship/.config/starship.toml` 查看这个文件改了什么。`dotpush "调整终端样式"` 会提交并推送整个仓库的改动。如果只想提交这个已跟踪的文件，在仓库里运行 `git commit --only -m "调整终端样式" -- mac/starship/.config/starship.toml`，再运行 `git push`。

- **加一个工具的配置。** 例如 `dotadd nvim ~/.config/nvim`，它会把现有配置移入仓库并建立链接。确认工具能读到配置后，把包名加进 `bootstrap.sh` 末尾的 `stow -t ~` 命令，新机安装时也会链接它。[Mac 初始化脚本](../bootstrap.sh)
- **更新装机清单。** 等这台电脑的软件装齐后运行 `dotbrew`。它根据本机软件更新并推送 Brewfile，保留 Ghost Complete 和对应的软件源，跳过 Karabiner 和 VS Code 扩展。[Brewfile](../Brewfile)
- **查环境变量和代理。** Zsh 插件写在 `.zshrc`，登录时加载的 Homebrew 和 Java 路径写在 `.zprofile`。代理端口用 `PROXY_PORT`，可用 `proxy-state` 查看。改完新开终端。[Zsh 配置](../mac/zsh/.zshrc) · [登录配置](../mac/zsh/.zprofile) · [代理配置](../mac/zsh/.proxyrc)

## Mac 安装排错

| 遇到什么 | 怎么处理 |
| --- | --- |
| `dot` 找不到 | 先用 `cd ~/dotfiles`。初始化完成后新开终端，再用 `dotcheck` 检查链接。 |
| Brewfile 有软件没装上 | 用 `brew bundle check --no-upgrade --verbose --file="$HOME/dotfiles/Brewfile"` 看缺项，再用 `brew bundle --file="$HOME/dotfiles/Brewfile"` 补装。 |
| Stow 提示文件冲突 | 运行 `stow -n -v -d ~/dotfiles/mac -t ~ zsh starship snapzy` 预览冲突。先对比并备份目标文件，再重新链接对应的包。初始化前已有的普通 Zsh 配置可在同目录的 `.bak-日期-时间` 文件里找回。 |
| 项目需要 Java 21 | 用 `/usr/libexec/java_home -V` 查已有 JDK。装好 21 后新开登录终端，`.zprofile` 会设置 `JAVA_HOME`。 |
| Git 报 `git-lfs: command not found` | 运行 `brew install git-lfs`，用 `git lfs version` 确认。 |
| 补全没生效，或者图标是方框 | 运行 `ghost-complete install` 后新开终端。图标缺失时，在终端里选择支持图标的字体。 |

## Windows 终端

PowerShell 的启动文件和 Starship 主题由初始化脚本链接到仓库。新开平时使用的 PowerShell，用下面两行查看链接和命令。

```powershell
Get-Item -LiteralPath $PROFILE, "$HOME\.config\starship.toml" | Select-Object Name, LinkType, Target
Get-Command starship, gs | Select-Object Name, CommandType
```

第一行应显示两个 `SymbolicLink`。如果另一个 PowerShell 窗口找不到别名，先比较两边的 `$PROFILE`。创建链接时权限不足，可以开启 Windows 开发者模式，或在同一版本的管理员 PowerShell 里重试。已有的普通文件默认会备份为 `.bak-日期-时间`。用 `-Force` 重建会移除同名文件。[初始化脚本](../windows/bootstrap.ps1) · [PowerShell 启动文件说明](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)

| 常用操作 | 命令或位置 |
| --- | --- |
| 修改 Git 和项目别名 | `gs` 看状态，`ga README.md` 暂存单个文件，`gaa` 暂存全部。`Get-Command gc -All` 可查同名命令。[别名](../windows/aliases.ps1) |
| 设置代理 | `proxy-state` 查看，`proxy-on` / `proxy-off` 控制当前终端，`proxy-gh-on` 开启 GitHub 代理，`proxy-git-off` 清除 Git 代理。端口在 `$script:ProxyPort` 设置。[代理配置](../windows/proxy.ps1) |
| 切换 npm 下载源 | `npm-cn` 切国内镜像，`npm-official` 切回官方源。[npm 配置](../windows/npm.ps1) |
| 取回另一台电脑的改动 | 运行 `git -C "$HOME\dotfiles" pull --ff-only`，改了启动脚本就新开一个 PowerShell 标签页。 |

## 安装 Windows 工具

只装需要的软件，可以直接从清单挑包名。如果想批量安装，在仓库根目录选用对应的一段。[winget 软件清单](../windows/winget-packages.txt) · [Scoop 软件清单](../windows/scoop-packages.txt) · [安装 Scoop](https://scoop.sh/)

```powershell
Get-Content .\windows\winget-packages.txt | ForEach-Object {
    $id = ($_ -split '#', 2)[0].Trim()
    if ($id) { winget install --id $id --exact }
}
```

```powershell
Get-Content .\windows\scoop-packages.txt | ForEach-Object {
    $package = ($_ -split '#', 2)[0].Trim()
    if ($package) { scoop install $package }
}
```

装好 Nerd Font 后，在 Windows Terminal 的「设置 → 当前配置文件 → 外观」选择它。装好 zoxide 后可用 `z` 跳目录。要用 `Ctrl+T` 查文件、`Ctrl+R` 查历史，先装 fzf，再运行 `Install-Module PSFzf -Scope CurrentUser`。如果项目里的 `d`、`b`、`t` 报找不到 `nr`，装好 Node.js 后运行 `npm install --global '@antfu/ni'`。[PowerShell 工具配置](../windows/tools.ps1)

## 旧版 Git 配置迁移

Git 的姓名、邮箱、代理和全局忽略规则保存在各台电脑上。在项目目录运行 `git config --show-origin --get user.email` 能看到当前身份来自哪个文件。要换身份时，使用 `git config --global user.name` 和 `git config --global user.email`，后面分别加上新姓名和邮箱。

早期版本用 Stow 把 `~/.gitconfig` 和 `~/.gitignore_global` 链接到 `~/dotfiles/mac/git`。还在用这些旧链接的 Mac，建议在拉取新版或删除仓库前运行下面这段，把配置转成独立文件。它只处理确实指向旧仓库位置的链接。

```sh
(
  set -e
  for name in .gitconfig .gitignore_global; do
    file="$HOME/$name"
    if [ -L "$file" ] && [ "$file" -ef "$HOME/dotfiles/mac/git/$name" ]; then
      copy=$(mktemp "$HOME/$name.XXXXXXXX")
      cat "$file" > "$copy"
      mv -f "$copy" "$file"
    fi
  done
)
```
