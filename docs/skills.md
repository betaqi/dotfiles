# 备份和恢复 skills

我在 Mac 上安装、更新 skills，用 Git 把用顺手的版本带到其他电脑。新机从仓库恢复安装目录就能拿到脚本、模板和子技能，包括 wechatide 的 `compiler`、`debugger` 等工具。

## 在 Mac 上保存一次更新

更新完 skill 后，在 Mac 的任意目录运行：

```zsh
sync-skills
```

`sync-skills` 先做本地备份，有变化就只提交 `skills/`，最后推送当前分支。如果上一次推送因网络中断，恢复后再运行一次即可。

想先检查再推送，可以运行 `backup-skills` 和 `dots`，确认后再用 `sync-skills`。新开终端会自动加载这个函数，当前窗口也可以运行 `source ~/.dotfiles-helpers`。

<details>
<summary>第一次把备份功能提交到自己的仓库</summary>

第一次需要把脚本、别名、文档和换行规则一起提交。在仓库根目录运行下面的命令。这份换行规则会让 Windows 取到与 Mac 原件相同的文件内容。

```zsh
git add -- .gitattributes backup-skills.sh mac/zsh/.aliases mac/zsh/.dotfiles-helpers README.md docs/skills.md docs/terminal.md skills/
git diff --cached --stat
git commit --only -m "备份 skills 和跨平台恢复配置" -- .gitattributes backup-skills.sh mac/zsh/.aliases mac/zsh/.dotfiles-helpers README.md docs/skills.md docs/terminal.md skills/
git push
```

</details>

### 备份里有什么

| 仓库位置 | 保存的内容 |
| --- | --- |
| [skills/cc-switch/](../skills/cc-switch/) | CC Switch 安装目录里的完整 skill |
| [skills/agents/](../skills/agents/) | 通用目录 `~/.agents/skills/` 里的版本，与 CC Switch 的副本分开保存 |
| [sources.json](../skills/sources.json) 和 [agents-lock.json](../skills/agents-lock.json) | CC Switch 登记的上游仓库、分支，以及通用 skills 的安装清单 |
| [archives/](../skills/archives/) | 下载过并已备份的 `wechatide-skill-*.zip`，可以单独重装对应版本 |

**准备换 Mac 时**，如果想连 CC Switch 的上游关联和各应用的启用开关都带走，在旧机点「设置 → 数据 → 导出 SQL 备份」。把 SQL 单独加密保存，它可能包含供应商密钥。[CC Switch 数据管理说明](https://github.com/farion1231/cc-switch/blob/v4.0.6/docs/user-manual/zh/1-getting-started/1.5-settings.md#数据管理)

## 在新 Mac 恢复

先把旧机的备份推送到远端，然后在新机[克隆并初始化 dotfiles](../README.md#换一台-mac)。**新机先恢复，等要保存新的改动时再运行 `backup-skills`。**

1. 把两个目录和安装清单复制到各自的位置。全新安装可以直接复制。如果目标位置已有同名文件，执行后会被覆盖。

   ```zsh
   mkdir -p ~/.cc-switch/skills ~/.agents/skills
   ditto ~/dotfiles/skills/cc-switch ~/.cc-switch/skills
   ditto ~/dotfiles/skills/agents ~/.agents/skills
   cp ~/dotfiles/skills/agents-lock.json ~/.agents/.skill-lock.json
   ```

2. 打开 CC Switch，在「Skills → 存储与同步」里保留默认的「CC Switch 目录」。根据手头的备份选一种做法。

   - **有旧机 SQL**。在「设置 → 数据 → 选择 SQL 文件」导入，接着点「Skills → 存储与同步 → 立即重新同步」。导入会覆盖新机现有的 CC Switch 配置，并恢复旧机记录的启用状态。
   - **只有 dotfiles**。点「Skills → 添加 Skill → 导入本机已有」，选好要在 Codex 或 Claude Code 里启用的项。来源显示「本地」时，可查 `sources.json` 找回原仓库和分支。新机首次备份会重新生成这份清单，提交前用 `git -C ~/dotfiles diff HEAD -- skills/sources.json` 看一下改动。

3. 重开要用的应用。比如在 Codex 里启用了 wechatide，可以用下面的命令检查 `compiler` 子技能是否就位。

   ```zsh
   test -r ~/.codex/skills/wechatide-skill/skills/compiler/SKILL.md && echo "wechatide compiler 已恢复"
   ```

## 同步到 Windows

以下命令在原生 Windows 的 PowerShell 里运行。Mac 端先备份并推送。Windows 端装好 Git 和 CC Switch。第一次使用先克隆仓库。

```powershell
git clone https://github.com/betaqi/dotfiles.git "$HOME\dotfiles"
```

配置过本仓库的 PowerShell 后，新开窗口就能用下面的命令。如果只想同步 skills，可以先在当前窗口运行 `. "$HOME\dotfiles\windows\dotfiles.ps1"` 加载函数。

```powershell
pull-skills
```

- 它先用 Git 快进拉取仓库，再把 `skills/cc-switch` 和 `skills/agents` 分别复制到 `$HOME\.cc-switch\skills` 和 `$HOME\.agents\skills`。同名文件会更新，Windows 独有的文件会保留。
- 本次拉取中删除的路径会以 `D` 列出，方便对照清理旧文件。要卸载整个 skill，就在对应管理工具里操作。
- 首次缺少通用安装清单时会复制一份，已有的清单默认保留。如果 Windows 的通用 skills 全部跟随 Mac，使用 `pull-skills -IncludeLockfile` 一起更新清单。

打开 CC Switch，在「Skills → 存储与同步」选「CC Switch 目录」和「自动」。**新加的 skill** 用「添加 Skill → 导入本机已有」，再选在哪个应用启用。**已经启用的 skill** 更新后，点「立即重新同步」。[CC Switch 同步说明](https://github.com/farion1231/cc-switch/blob/v4.0.6/docs/user-manual/zh/3-extensions/3.3-skills.md#存储与同步)

例如在 Codex 中启用 wechatide 后，运行下面这行应返回 `True`。用 Claude Code 的话，把 `.codex` 换成 `.claude`。实际编译小程序还需要 Windows 版微信开发者工具。

```powershell
Test-Path "$HOME\.codex\skills\wechatide-skill\skills\compiler\SKILL.md"
```
