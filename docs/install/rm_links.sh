#!/usr/bin/env bash
# 移除 ln_files.sh 建立的软链（仅删链接本身，不动真实文件与仓库内容）
#
# 用法:
#   ./rm_links.sh                 移除全部
#   ./rm_links.sh zsh git         只移除指定模块
#   ./rm_links.sh --dry-run       预览将移除的链接
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

for m in $MODULES; do
    grep -qw "$m" <<< "$(valid_modules)" || {
        echo "未知模块: ${m}（可用: $(valid_modules)）" >&2
        exit 1
    }
done

map_foreach unlink $MODULES
