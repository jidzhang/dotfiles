# ============================================================================
# dotfiles 安装脚本（macOS / Linux）
# 用法:
#   ./install.sh            # 默认用符号链接
#   ./install.sh --copy     # 复制而不是链接（Windows 挂载盘/权限受限时用）
#   ./install.sh --dry-run  # 只打印将执行的动作
# 幂等：可反复执行；已存在且指向本仓库的链接会跳过，冲突文件会备份为 *.bak
# ============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="link"
DRY=0

for arg in "$@"; do
  case "$arg" in
    --copy)    MODE="copy" ;;
    --dry-run) DRY=1 ;;
    *) echo "未知参数: $arg"; exit 2 ;;
  esac
done

say()  { printf '  %s\n' "$*"; }
run()  { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }

# 单文件安装：$1 源文件  $2 目标路径  [$3 = skip-if-exists 时，已存在文件跳过]
install_file() {
  local src="$1" dst="$2" mode="${3:-}"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "已就位  $dst"
    return
  fi
  # 非符号链接但内容一致（例如 MSYS 下 ln -s 退化成复制）也视为已就位
  if [ -f "$dst" ] && [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then
    say "已就位  $dst"
    return
  fi
  # 含个人身份的文件：目标已存在则绝不覆盖（仓库里只有占位符）
  if [ "$mode" = "skip-if-exists" ] && { [ -e "$dst" ] || [ -L "$dst" ]; }; then
    say "已跳过  $dst（已存在，未覆盖）"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    run "mv -f \"$dst\" \"$dst.bak\""
    say "已备份  $dst -> $dst.bak"
  fi
  run "mkdir -p \"$(dirname "$dst")\""
  if [ "$MODE" = "copy" ]; then
    run "cp -f \"$src\" \"$dst\""
  else
    run "ln -sfn \"$src\" \"$dst\""
  fi
  say "已安装  $dst"
}

echo "== 通用配置 =="
for f in .vimrc .tmux.conf .editorconfig .gemrc .gitignore_global .spacemacs; do
  [ -f "$REPO/common/$f" ] && install_file "$REPO/common/$f" "$HOME/$f"
done
# .gitconfig 仓库里是占位符：目标不存在才装，已存在绝不覆盖真实身份
[ -f "$REPO/common/.gitconfig" ] && \
  install_file "$REPO/common/.gitconfig" "$HOME/.gitconfig" skip-if-exists

echo "== Vim 补充文件 =="
[ -f "$REPO/common/vim/.ycm_extra_conf.py" ] && \
  install_file "$REPO/common/vim/.ycm_extra_conf.py" "$HOME/.vim/.ycm_extra_conf.py"

# 平台专属目录：mac/ 优先于 linux/（两者都不存在则跳过）
if [ -d "$REPO/mac" ] && [ "$(uname -s)" = "Darwin" ]; then
  echo "== macOS 专属 =="
  for f in "$REPO"/mac/.[!.]* "$REPO"/mac/*; do
    [ -f "$f" ] && install_file "$f" "$HOME/$(basename "$f")"
  done
fi
if [ -d "$REPO/linux" ] && [ "$(uname -s)" = "Linux" ]; then
  echo "== Linux 专属 =="
  for f in "$REPO"/linux/.[!.]* "$REPO"/linux/*; do
    [ -f "$f" ] && install_file "$f" "$HOME/$(basename "$f")"
  done
fi

if [ "$DRY" = 1 ]; then
  echo "== dry-run 结束，未做任何改动 =="
else
  echo "== 完成 =="
fi
