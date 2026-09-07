#!/usr/bin/env bash
# 将仓库配置软链到系统位置
#
# 用法:
#   ./ln_files.sh                 链接全部模块
#   ./ln_files.sh zsh git ghostty 只链接指定模块（模块见 links.sh）
#   ./ln_files.sh --dry-run       预览将执行的链接
set -euo pipefail

DRY_RUN=0
MODULES=''

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        -h|--help)    sed -n '2,7p' "$0"; exit 0 ;;
        *)            MODULES="$MODULES $arg" ;;
    esac
done

# shellcheck source=links.sh
source "$(dirname "$0")/links.sh"

# 校验模块名
for m in $MODULES; do
    grep -qw "$m" <<< "$(valid_modules)" || {
        echo "未知模块: ${m}（可用: $(valid_modules)）" >&2
        exit 1
    }
done

echo "仓库: $REPO"
map_foreach link $MODULES

# git 身份配置提示（仅在本次范围包含 git 模块时提示）
if { [ -z "$MODULES" ] || grep -qw git <<< "$MODULES"; } && [ ! -e "$HOME/.config/git/config.local" ]; then
    echo
    echo "提示: git 身份信息尚未配置，执行以下步骤完成:"
    echo "  cp $REPO/git/config_local_tpl $HOME/.config/git/config.local"
    echo "  然后编辑 config.local 填写 name / email / signingkey"
fi
