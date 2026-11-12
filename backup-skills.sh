#!/bin/bash
set -euo pipefail

repo_dir=$(cd "$(dirname "$0")" && pwd -P)
backup_dir="$repo_dir/skills"
cc_dir="$HOME/.cc-switch"
agents_dir="$HOME/.agents"

# 先读齐本机数据，再更新仓库中的快照。
snapshot=$(mktemp -d)
trap 'rm -rf "$snapshot"' EXIT
mkdir "$snapshot/cc-switch" "$snapshot/agents"
rsync -a --exclude=.git --exclude=.DS_Store "$cc_dir/skills/" "$snapshot/cc-switch/"
rsync -a --exclude=.git --exclude=.DS_Store "$agents_dir/skills/" "$snapshot/agents/"
cp "$agents_dir/.skill-lock.json" "$snapshot/agents-lock.json"
sqlite3 -readonly -json "$cc_dir/cc-switch.db" \
  'SELECT directory, repo_owner, repo_name, repo_branch FROM skills ORDER BY directory' \
  > "$snapshot/sources.json"
if [[ ! -s "$snapshot/sources.json" ]]; then
  echo '[]' > "$snapshot/sources.json"
fi

# CC Switch 仍登记为已安装的 skill 缺文件时，保留上一份快照供恢复。
python3 - "$snapshot" <<'PY'
import json
import sys
from pathlib import Path

snapshot = Path(sys.argv[1])
for skill in json.loads((snapshot / "sources.json").read_text()):
    directory = skill["directory"]
    if not (snapshot / "cc-switch" / directory / "SKILL.md").is_file():
        sys.exit(f"CC Switch 已登记 {directory}，安装目录缺少 SKILL.md。已保留原备份。")
PY

# 下载目录清理后仍保留已归档的版本。归档和安装目录分别同步。
shopt -s nullglob
archives=("$HOME"/Downloads/wechatide-skill-*.zip)
mkdir -p "$backup_dir/archives"
if (( ${#archives[@]} )); then
  rsync -ac "${archives[@]}" "$backup_dir/archives/"
fi

rsync -ac --delete "$snapshot/cc-switch" "$snapshot/agents" \
  "$snapshot/agents-lock.json" "$snapshot/sources.json" "$backup_dir/"
echo "Skills 本地备份已更新至 $backup_dir"
