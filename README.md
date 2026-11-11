# 我的电脑配置（dotfiles）

这里保存我的终端、截图工具设置和常用软件清单。Mac 上，GNU Stow 把家目录里的配置链接到这个仓库。例如，终端读取的 `~/.config/starship.toml` 和下面表格里的 Starship 文件是同一份。**改文件就能在本机生效，提交并推送后才能在另一台电脑取回。**

在 Windows 上使用，直接看 [Windows 配置与换机](#换-windows)。在 Mac 上日常改配置，查下面这张表。

## 想改什么，打开哪个文件？

| 我想改… | 打开 | 怎么确认 |
| --- | --- | --- |
| 终端的目录、Git 分支、版本、时钟和耗时 | [starship.toml](mac/starship/.config/starship.toml) | `format` 管左侧，`right_format` 管右侧。按回车看时间，运行 `sleep 3` 看耗时。显示门槛由 `min_time` 控制，单位是毫秒。 |
| 命令缩写，例如 `gs`、`ll`、`d` | [.aliases](mac/zsh/.aliases) | 新开终端，输入 `alias gs` 看它实际执行什么。 |
| 终端启动时加载的插件、工具和环境变量 | [.zshrc](mac/zsh/.zshrc) · [.zprofile](mac/zsh/.zprofile) | 新开终端。交互插件在前者，登录时的 Homebrew、Java 路径在后者。 |
| 这台电脑的 Git 提交身份 | 在本机用 `git config --global` 管理，见[多台电脑的 Git 身份](#多台电脑的-git-身份) | 在项目目录运行 `git config --show-origin --get user.email` 看实际使用的邮箱及来源。 |
| 终端、npm 和 Git 的代理端口 | [.proxyrc](mac/zsh/.proxyrc) | 新开终端，运行 `proxy-state`。Mac 的开关使用 `PROXY_PORT`。 |
| 截图快捷键 | [Snapzy](mac/snapzy/.config/snapzy/config.toml) | 在对应 App 里试一次按键。也可以在 App 里改，再用 `dots` 看哪些设置被写回。 |
| 下次换机要装的软件和字体 | [Brewfile](Brewfile) | `brew bundle check --no-upgrade --verbose --file="$HOME/dotfiles/Brewfile"` 查看缺项。 |

## 在这台 Mac 上改配置

以改终端样式为例，在终端运行这几行。点上表的文件也可以直接找到它。

```zsh
dot                              # 进入 ~/dotfiles
open -e mac/starship/.config/starship.toml
dots                             # 保存后，查看整个仓库的改动
git diff -- mac/starship/.config/starship.toml
```

要同步时，`dotpush "调整终端样式"` 会提交并推送**整个仓库的改动**。如果上次推送失败，可以再运行一次，它会继续推送已有提交。如果这次只想同步某一个文件，用 Git 单独提交它，例如 `git commit --only -m "调整终端样式" -- mac/starship/.config/starship.toml`，然后 `git push`（此例用于已跟踪的文件）。

| 其他常用操作 | 命令 |
| --- | --- |
| 到另一台已配置的 Mac 取回更新 | `dotpull`，然后新开终端 |
| 快速查看常用配置的链接状态 | `dotcheck`。想确认 Starship 的具体目标，可运行 `readlink ~/.config/starship.toml` |
| 安装软件后更新清单并推送 | `dotbrew` 按本机已安装的软件更新清单，补齐 Ghost Complete 和它的 Homebrew 源，跳过 Karabiner 和 VS Code 扩展。仅提交 Brewfile，再推送当前分支。导出失败会保留旧清单。新机先装齐需要的软件，再用它更新快照 |
| 把新工具的现有配置加入仓库 | 例如 `dotadd nvim ~/.config/nvim`。它会把配置移进包并创建链接，重复运行会识别已纳管的路径。若链接失败，会移回原处。如果此时原路径被其他文件占用，会保留两份并提示位置。最后把新包名加进 [bootstrap.sh](bootstrap.sh) 末尾的 `stow -t ~` 命令，新机器才会链接它 |

这些命令定义在 [.dotfiles-helpers](mac/zsh/.dotfiles-helpers)。如果 `dot` 提示找不到命令，先用 `cd ~/dotfiles` 进入仓库。

## 换一台 Mac

1. 在终端运行 `git --version`。如果 macOS 提示安装命令行开发者工具，完成后再继续。下面的脚本会检查 Homebrew，缺少时下载安装并加载它。
2. 把仓库放到 **`~/dotfiles`**，维护命令按这个位置查找。已克隆过就直接进入目录。

   ```zsh
   git clone https://github.com/betaqi/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   bash bootstrap.sh
   ```

3. 脚本按 Brewfile 安装软件，配置 Oh My Zsh 和插件，再链接 Zsh、Starship 和 Snapzy。每台电脑自行管理 Git 全局配置。
4. **新开终端验收**。运行 `dotcheck` 查看链接，运行 `sleep 3`，下一行右侧应出现类似 `耗时 3s │ 19:20`。再运行下面的命令查漏装的软件。

   ```zsh
   brew bundle check --no-upgrade --verbose --file="$HOME/dotfiles/Brewfile"
   ```

### 恢复时遇到问题

- **安装脚本报错。** 软件安装不全时，脚本会继续链接已有配置，最后返回失败并给出补装命令。链接冲突会直接中止。用下面的命令预演链接，查看具体冲突路径。若已有自己的配置，先对比并备份冲突文件，再对需要的包重新链接，例如 `stow -d ~/dotfiles/mac -t ~ starship`。

  ```zsh
  stow -n -v -d ~/dotfiles/mac -t ~ zsh starship snapzy
  ```

- **项目需要 Java 21。** 登录时会在找到 JDK 21 后设置 `JAVA_HOME`。用 `/usr/libexec/java_home -V` 查看已安装版本。
- **Git 提示 `git-lfs: command not found`。** 在这台 Mac 单独运行 `brew install git-lfs`，再用 `git lfs version` 确认。
- **终端补全或图标没生效。** Ghost Complete 首次使用时运行 `ghost-complete install` 并新开终端。终端图标显示成方框时，在终端设置里选用 JetBrains Mono Nerd Font。

## 多台电脑的 Git 身份

Mac 和 Windows 的 Git 全局设置都留在本机，包括提交姓名、邮箱、代理、LFS 过滤器和全局忽略规则。新电脑照常运行安装脚本即可，已有的 Git 配置会继续生效。仓库自己的 `.gitignore` 仍随项目共享。

继续用熟悉的命令。在某个项目目录里运行 `git config --show-origin --get user.email` 可以查看实际使用的邮箱。只有想改身份时才需要执行下面的设置命令。

```sh
git config --global user.name "这台电脑的提交名"
git config --global user.email "这台电脑的提交邮箱"
```

**用过旧版 Stow 的 Mac。** 旧版可能把 `~/.gitconfig` 和 `~/.gitignore_global` 链接到了 `~/dotfiles/mac/git`。这次调整过的 Mac 通过旧链接读取本机忽略目录里的副本，普通 `git config --global` 也会写到本地。如果准备删除这份仓库，或者要在另一台仍使用旧版链接的 Mac 上拉取新版，先把这两个旧链接转为独立文件。已经是普通文件的配置会自动跳过。

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

同步新版会移除原先跟踪的配置文件。历史提交里已有的邮箱仍然可见，新提交也会带上当时使用的提交身份。

Mac 的 Zsh 配置另行处理。完整安装会先备份已有的普通 `~/.zshrc` 和 `~/.zprofile`，之后加载仓库版本。原来单独设置的工具路径等内容，可从同目录带 `.bak-日期-时间` 的备份中取回。

## 换 Windows

这套配置用在 PowerShell 里。每次打开 PowerShell，它会读取启动文件 `$PROFILE`，加载提示符、命令缩写、代理和搜索工具。Mac 和 Windows 共用 Starship 的样式，其他终端设置分别维护。

### 新电脑上第一次配置

**1. 安装 Git 和 Starship。** 打开你平时用的 PowerShell，运行下面两条命令。已有的软件可以跳过。安装后新开一个 PowerShell 标签页，让它读到新的命令路径。

```powershell
winget install --id Git.Git --exact
winget install --id Starship.Starship --exact
```

**2. 下载仓库并链接配置。** 如果电脑上已经有 `$HOME\dotfiles`，从第二行开始。Windows PowerShell 5.1 和 PowerShell 7 使用各自的启动文件。如果两者都用，在各自的窗口里分别运行一次链接脚本。

```powershell
git clone https://github.com/betaqi/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles"
.\windows\bootstrap.ps1
```

[初始化脚本](windows/bootstrap.ps1) 会建立两个链接。已有的同名普通文件会先备份为 `.bak-日期-时间`。如果提示无权创建符号链接，可以开启 Windows 开发者模式，或在同一版本的管理员 PowerShell 里重试。重建前先核对目标，`-Force` 会直接移除同名文件。

| PowerShell 或程序读取的位置 | 链接到仓库中的文件 |
| --- | --- |
| `$PROFILE` | [PowerShell 启动入口](windows/Microsoft.PowerShell_profile.ps1) |
| `$HOME\.config\starship.toml` | [两端共用的提示符样式](mac/starship/.config/starship.toml) |

**3. 新开同一种 PowerShell 验证。**

```powershell
Get-Item -LiteralPath $PROFILE, "$HOME\.config\starship.toml" | Select-Object Name, LinkType, Target
Get-Command starship, gs | Select-Object Name, CommandType
git -C "$HOME\dotfiles" status --short --branch
```

前两条应显示两个指向仓库的 `SymbolicLink`，以及 `starship` 程序和 `gs` 函数。如果换个窗口后缩写消失，在那个窗口输入 `$PROFILE`，确认链接的是当前使用的启动文件。[PowerShell 启动文件说明](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles)

### 平时想改什么？

| 我想改… | 打开 | 常用操作 |
| --- | --- | --- |
| 提示符里的目录、Git 分支和版本 | [starship.toml](mac/starship/.config/starship.toml) | Windows 通过 [starship.ps1](windows/starship.ps1) 启动 Starship。改样式后按回车查看。 |
| Git 或项目命令缩写 | [aliases.ps1](windows/aliases.ps1) | `gs` 看状态，`ga README.md` 暂存一个文件，`gaa` 暂存全部。项目里的 `d`、`b`、`t` 分别调用 `nr dev`、`nr build`、`nr test`。 |
| 终端或 Git 的代理 | [proxy.ps1](windows/proxy.ps1) | 先确认本机代理软件的端口与 `$script:ProxyPort` 一致，仓库默认是 `10808`。`proxy-on` / `proxy-off` 控制当前终端，`proxy-gh-on` 写入 Git 的 GitHub 代理，`proxy-git-off` 清理脚本设置的 Git 代理。 |
| npm 下载源或代理 | [npm.ps1](windows/npm.ps1) | `npm-cn` 切国内镜像，`npm-official` 切回官方源。`proxy-state` 可查看终端、npm 和 Git 的设置。 |
| 跳目录、搜文件和命令历史 | [tools.ps1](windows/tools.ps1) | zoxide 提供 `z`。装好 fzf 和 PSFzf 后，`Ctrl+T` 查文件，`Ctrl+R` 查历史命令。 |

改完 `.ps1` 后，新开一个 PowerShell 标签页。要取回另一台电脑已推送的设置，运行 `git -C "$HOME\dotfiles" pull --ff-only`。若缩写执行的内容出乎预期，例如 `gc`，用 `Get-Command gc -All` 查看是否有同名的 PowerShell 内置别名，提交时可以直接输入 `git commit`。

### 按需补装工具

初始化脚本只负责创建链接。下面两份清单记录可选软件，按自己需要安装。

| 我需要的功能 | 怎么装 |
| --- | --- |
| 提示符图标、Node.js 或 Python | 在 [winget 清单](windows/winget-packages.txt) 找包 ID。图标显示成方框时，运行 `winget install --id DEVCOM.JetBrainsMonoNerdFont --exact`，再到 Windows Terminal 的「设置 → 当前 PowerShell 配置文件 → 外观」选择 JetBrainsMono Nerd Font。 |
| `z` 跳目录、模糊查找 | 已装 Scoop 时运行 `scoop install zoxide fzf`。需要上述快捷键，再运行 `Install-Module PSFzf -Scope CurrentUser` 并新开终端。[Scoop 工具清单](windows/scoop-packages.txt) · [Scoop 安装入口](https://scoop.sh/) |
| 项目的 `d`、`b`、`t` 报找不到 `nr` | 安装清单中的 Node.js LTS，再运行 `npm install --global '@antfu/ni'`。用 `Get-Command nr` 检查，随后在含有相应 npm scripts 的项目里使用。 |

要批量安装时，在仓库根目录按需选用下面任一段。命令会先去掉每行的 `#` 说明，只把包名交给安装器。

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
