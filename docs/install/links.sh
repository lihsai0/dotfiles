#!/usr/bin/env bash
# 链接映射表与安全链接函数，供 ln_files.sh / rm_links.sh 共用
# 不直接执行本文件（直接执行时 REPO 定位不成立）

# 被直接执行而非 source 时终止
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo "请通过 ln_files.sh / rm_links.sh 调用，本文件不直接执行" >&2
    exit 1
fi

# 自定位仓库根目录（与执行位置、当前用户名解耦）
REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 映射表，格式: "模块|仓库相对路径|目标绝对路径[|exist]"
#   模块: 用于 ln_files.sh 按名选择安装范围
#   exist: 可选标记，目标父目录已存在时才链接（否则自动创建父目录）
LINK_MAP=(
  "zsh|zsh/zshrc|$HOME/.zshrc"
  "zsh|zsh/omz-plugins/pnpm|$ZSH_CUSTOM_DIR/plugins/pnpm"
  "zsh|zsh/omz-plugins/skim|$ZSH_CUSTOM_DIR/plugins/skim"
  "zsh|zsh/functions/yazi.zsh|$ZSH_CUSTOM_DIR/yazi.zsh"
  "git|git|$HOME/.config/git"
  "starship|starship|$HOME/.config/starship"
  "alacritty|alacritty|$HOME/.config/alacritty"
  "ghostty|ghostty|$HOME/.config/ghostty"
  "zellij|zellij|$HOME/.config/zellij"
  "btop|btop|$HOME/.config/btop"
  "helix|helix|$HOME/.config/helix"
  "zed|zed|$HOME/.config/zed"
  # 个人多身份 git 配置，仅在 ~/Workspaces 存在时链接
  "git|git/config_workspaces|$HOME/Workspaces/.gitconfig|exist"
  # 按需启用，取消注释即可
  # "nvim|nvim|$HOME/.config/nvim"
  # "hammerspoon|hammerspoon|$HOME/.hammerspoon"
)

# 安全链接: 已是软链则替换（幂等），目标为真实文件/目录则跳过不覆盖
link_one() {
    local src=$1 dst=$2
    if [ "$DRY_RUN" -eq 1 ]; then
        echo "[dry-run] ln -s $src $dst"
        return 0
    fi
    if [ -L "$dst" ]; then
        ln -sfn "$src" "$dst"
        echo "更新  $dst -> $src"
    elif [ -e "$dst" ]; then
        echo "跳过  ${dst}（已存在真实文件/目录，不覆盖）"
    else
        mkdir -p "$(dirname "$dst")"
        ln -s "$src" "$dst"
        echo "创建  $dst -> $src"
    fi
}

# 仅移除软链本身，不动真实文件
unlink_one() {
    local dst=$1
    if [ "$DRY_RUN" -eq 1 ]; then
        [ -L "$dst" ] && echo "[dry-run] rm $dst"
        return 0
    fi
    if [ -L "$dst" ]; then
        rm "$dst"
        echo "移除  $dst"
    fi
}

# 解析映射条目 "module|src|dst[|flag]" 到 MAP_* 全局变量
# 不用 IFS+read：bash 3.2 在管道内循环中该组合会失效
parse_entry() {
    local rest=$1
    MAP_MODULE=${rest%%|*}; rest=${rest#*|}
    MAP_SRC=${rest%%|*};    rest=${rest#*|}
    MAP_DST=${rest%%|*}
    if [[ $rest == *'|'* ]]; then
        MAP_FLAG=${rest#*|}
    else
        MAP_FLAG=''
    fi
}

# 遍历映射表执行动作（link / unlink），可传模块名过滤
map_foreach() {
    local action=$1; shift
    local filters="$*"
    for entry in "${LINK_MAP[@]}"; do
        parse_entry "$entry"
        # 未指定模块时处理全部，否则只处理指定模块
        if [ -n "$filters" ] && ! grep -qw "$MAP_MODULE" <<< "$filters"; then
            continue
        fi
        # exist 标记: 父目录不存在则跳过
        if [ "$MAP_FLAG" = "exist" ] && [ ! -d "$(dirname "$MAP_DST")" ]; then
            echo "跳过  ${MAP_DST}（父目录不存在）"
            continue
        fi
        if [ "$action" = "link" ]; then
            if [ ! -e "$REPO/$MAP_SRC" ]; then
                echo "警告  仓库中不存在 ${MAP_SRC}，检查映射表"
                continue
            fi
            link_one "$REPO/$MAP_SRC" "$MAP_DST"
        else
            unlink_one "$MAP_DST"
        fi
    done
}

# 映射表中的全部合法模块名
valid_modules() {
    local entry
    for entry in "${LINK_MAP[@]}"; do
        echo "${entry%%|*}"
    done | sort -u | tr '\n' ' '
}
