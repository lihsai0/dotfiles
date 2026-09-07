#!/bin/sh
# ============================================================
# 工具定制化安装脚本
#
# 用法:
#   ./install_tools.sh                交互勾选工具（推荐，可保存为 profile）
#   ./install_tools.sh -p work        按 profile 安装（profiles/work.list）
#   ./install_tools.sh -l             列出全部工具
#   ./install_tools.sh -n <选择>      dry-run，只打印将执行的命令
#
# 组说明（仅用于 -l 列表与勾选界面的展示分类，不作为安装参数）:
#   base  CLI 日常基础：git 工具链、网络、gpg、shell 增强、CLI 编辑器、mise
#   dev   开发环境：编程语言、调试、硬件开发、媒体/备份处理
#   apps  GUI 应用：终端、启动器、编辑器、字体、虚拟化、媒体
#
# profile: profiles/*.list，一行一个工具名（# 开头为注释），
#          用于在多台机器上精确复现同一套工具子集。
# ============================================================
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROFILES_DIR="$SCRIPT_DIR/profiles"
DRY_RUN=0

# 工具清单: name|group|type|描述
# type: brew = formula, cask = GUI 应用
TOOLS='
git|base|brew|版本控制
git-lfs|base|brew|Git 大文件存储
git-delta|base|brew|diff 美化查看
gh|base|brew|GitHub 官方 CLI
gitui|base|brew|TUI git 客户端
wget|base|brew|下载工具
aria2|base|brew|多线程下载
gnupg|base|brew|GPG 加密签名
pinentry-mac|base|brew|GPG 密码弹窗
zsh|base|brew|shell 本体
zellij|base|brew|终端复用器
starship|base|brew|跨 shell 提示符
zoxide|base|brew|智能目录跳转
bat|base|brew|cat 增强版
btop|base|brew|系统资源监控
eza|base|brew|ls 增强版
fd|base|brew|find 增强版
ripgrep|base|brew|grep 增强版
fzf|base|brew|模糊查找器
skim|base|brew|模糊查找器（Rust 实现，fzf 备选）
sd|base|brew|查找替换工具
dust|base|brew|磁盘占用分析
mole|base|brew|内网穿透隧道
yazi|base|brew|终端文件管理器
neovim|base|brew|Vim 系编辑器
helix|base|brew|模态代码编辑器
jq|base|brew|JSON 处理
jo|base|brew|JSON 生成
yq|base|brew|YAML/TOML 处理
asimov|dev|brew|Time Machine 智能排除
ffmpeg|dev|brew|音视频处理
rustup|dev|brew|Rust 工具链管理
lua|dev|brew|Lua 语言
fennel|dev|brew|Fennel 语言
minimal-racket|dev|brew|Racket 语言
sqlite|dev|brew|SQLite 数据库
mise|base|brew|多语言版本管理
gdb|dev|brew|C/C++ 调试器
exercism|dev|brew|编程练习 CLI
minicom|dev|brew|串口终端
arduino-cli|dev|brew|Arduino 开发
alacritty|apps|cask|GPU 加速终端
ghostty|apps|cask|GPU 加速终端
alfred|apps|cask|效率启动器
hammerspoon|apps|cask|桌面自动化脚本
appcleaner|apps|cask|应用卸载清理
zed|apps|cask|AI 协作编辑器
gram|apps|cask|AI 语法润色
mactex|apps|cask|LaTeX 套件
font-lxgw-wenkai|apps|cask|霞鹜文楷字体
font-maple-mono-nf|apps|cask|Maple Mono 等宽字体
orbstack|apps|cask|轻量 Docker 虚拟机
utm|apps|cask|全功能虚拟机
iina|apps|cask|媒体播放器
mac-mouse-fix|apps|cask|鼠标手势增强
betterdisplay|apps|cask|显示器管理
shottr|apps|cask|截图标注
keycastr|apps|cask|按键实时显示
sf-symbols|apps|cask|SF 符号图标库
surge|apps|cask|网络代理调试
wireshark-app|apps|cask|抓包分析
imhex|apps|cask|十六进制编辑器
'

# 从条目 "name|group|type|desc" 中提取字段
entry_name()  { printf '%s' "$1" | cut -d'|' -f1; }
entry_group() { printf '%s' "$1" | cut -d'|' -f2; }
entry_type()  { printf '%s' "$1" | cut -d'|' -f3; }
entry_desc()  { printf '%s' "$1" | cut -d'|' -f4; }

all_entries() {
    printf '%s\n' "$TOOLS" | grep -v '^[[:space:]]*$'
}

group_entries() {
    all_entries | grep "|$1|"
}

valid_groups() {
    all_entries | cut -d'|' -f2 | sort -u | tr '\n' ' '
}

list_tools() {
    printf '可用组: %s\n\n' "$(valid_groups)"
    for g in $(valid_groups); do
        printf '[%s]\n' "$g"
        group_entries "$g" | while IFS= read -r e; do
            printf '  %-24s %s\n' "$(entry_name "$e")" "$(entry_desc "$e")"
        done
        printf '\n'
    done
}

# 交互勾选：优先 fzf 多选，无 fzf 时降级为编号输入
pick_interactive() {
    if command -v fzf >/dev/null 2>&1; then
        sel=$(all_entries | while IFS= read -r e; do
            # 行首空格: 勾选后对勾与名称之间有间隔，未选行同样对齐
            printf ' %-22s [%s] %s\n' "$(entry_name "$e")" "$(entry_group "$e")" "$(entry_desc "$e")"
        done | fzf -m --height=80% --reverse \
            --marker='✓' --color='marker:green,pointer:green,header:cyan' \
            --header='Tab 勾选，Enter 确认') || {
            printf '已取消\n' >&2; exit 0
        }
        [ -n "$sel" ] || { printf '未选择任何工具\n' >&2; exit 0; }
        # 显示行格式为 " name [group] desc"，默认 IFS 分割取首词反查条目
        printf '%s\n' "$sel" | while read -r n _; do
            all_entries | grep -m1 "^$n|" || true
        done
    else
        # 本函数运行在命令替换中，UI 输出必须走 stderr，否则被吞进变量
        printf '未检测到 fzf，使用编号选择（支持: 1 3 5-8 / all）\n\n' >&2
        i=0
        all_entries | while IFS= read -r e; do
            i=$((i + 1))
            printf '%3d) %-22s [%s] %s\n' "$i" "$(entry_name "$e")" "$(entry_group "$e")" "$(entry_desc "$e")" >&2
        done
        printf '\n选择: ' >&2
        read -r answer
        [ -n "$answer" ] || { printf '未选择任何工具\n' >&2; exit 0; }
        [ "$answer" = "all" ] && { all_entries; return; }
        # 展开编号选择（含 a-b 范围），输出对应条目
        total=$(all_entries | wc -l | tr -d ' ')
        for tok in $(printf '%s' "$answer" | tr ',' ' '); do
            case "$tok" in
                *-*) start=${tok%-*}; end=${tok#*-} ;;
                *)   start=$tok; end=$tok ;;
            esac
            while [ "$start" -le "$end" ] 2>/dev/null; do
                [ "$start" -ge 1 ] && [ "$start" -le "$total" ] && \
                    all_entries | sed -n "${start}p"
                start=$((start + 1))
            done
        done
    fi
}

# 按 profile 文件取条目，清单外的名字直接报错
profile_entries() {
    pf="$PROFILES_DIR/$1.list"
    [ -f "$pf" ] || { printf 'profile 不存在: %s\n可用: %s\n' "$1" "$(ls "$PROFILES_DIR" 2>/dev/null | sed 's/\.list$//' | tr '\n' ' ')" >&2; exit 1; }
    names=$(grep -v '^[[:space:]]*#' "$pf" | grep -v '^[[:space:]]*$')
    [ -n "$names" ] || { printf 'profile 为空: %s\n' "$1" >&2; exit 1; }
    for name in $names; do
        entry=$(all_entries | grep -m1 "^$name|" || true)
        if [ -z "$entry" ]; then
            printf 'profile 中的 "%s" 不在工具清单内，请检查拼写\n' "$name" >&2
            exit 1
        fi
        printf '%s\n' "$entry"
    done
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '[dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

# 交互选择后提供保存为 profile 的机会（组/profile 模式不触发）
save_profile() {
    [ "$DRY_RUN" -eq 1 ] && return 0
    printf '\n保存为 profile? 输入名称（留空跳过）: ' >&2
    read -r name
    [ -n "$name" ] || return 0
    # 名称仅允许小写字母数字与连字符，防路径注入
    case "$name" in
        *[!a-z0-9-]*) printf '名称仅允许小写字母数字与连字符，未保存\n' >&2; return 0 ;;
    esac
    pf="$PROFILES_DIR/$name.list"
    if [ -f "$pf" ]; then
        printf 'profile "%s" 已存在，覆盖? [y/N] ' "$name" >&2
        read -r ok
        [ "$ok" = "y" ] || [ "$ok" = "Y" ] || return 0
    fi
    mkdir -p "$PROFILES_DIR"
    {
        printf '# 由交互选择生成: %s\n' "$(date '+%Y-%m-%d')"
        printf '%s\n' "$SELECTED" | while IFS= read -r e; do
            entry_name "$e"
        done
    } > "$pf"
    printf '已保存: %s\n下次使用: ./install_tools.sh -p %s\n' "$pf" "$name" >&2
}

install_entries() {
    brews=''; casks=''
    # 条目描述含空格，必须按行遍历而非按词分词
    while IFS= read -r e; do
        [ -n "$e" ] || continue
        case "$(entry_type "$e")" in
            brew) brews="$brews $(entry_name "$e")" ;;
            cask) casks="$casks $(entry_name "$e")" ;;
        esac
    done <<EOF
$SELECTED
EOF
    if [ -n "$brews" ]; then
        run brew install $brews
    fi
    if [ -n "$casks" ]; then
        run brew install --cask $casks
    fi
}

# Rust 工具链初始化（选中 rustup 时触发，有 y/N 确认）
# 注意: mise 本体经 brew 安装；语言/工具链栈由 post_mise_steps 可选初始化
post_dev_steps() {
    printf '\n将执行以下初始化步骤:\n'
    printf '  rustup install stable\n'
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '[dry-run] 跳过执行\n'
        return
    fi
    printf '继续? [y/N] '
    read -r ok
    [ "$ok" = "y" ] || [ "$ok" = "Y" ] || return 0
    # 命令存在性防御: 选中但 brew 安装未生效时跳过而非报错
    if command -v rustup >/dev/null 2>&1; then
        rustup install stable
    fi
}

# mise 语言/工具链初始化（选中 mise 时触发，有 y/N 确认）
# 这组工具对应 zshrc 的 buf/golang/pnpm/python/uv 插件守卫
post_mise_steps() {
    printf '\n将执行以下 mise 初始化步骤:\n'
    printf '  mise install go buf protoc protoc-gen-go protoc-gen-go-grpc\n'
    printf '  mise install node pnpm\n'
    printf "  MISE_PYTHON_COMPILE=0 MISE_PYTHON_PRECOMPILED_FLAVOR='freethreaded+pgo+lto-full' mise install 'python[patch_sysconfig=false]@3'\n"
    printf '  mise install uv\n'
    printf '  mise sync python --uv\n'
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '[dry-run] 跳过执行\n'
        return
    fi
    printf '继续? [y/N] '
    read -r ok
    [ "$ok" = "y" ] || [ "$ok" = "Y" ] || return 0
    # 命令存在性防御: 选中但 brew 安装未生效时跳过而非报错
    command -v mise >/dev/null 2>&1 || {
        printf '未检测到 mise，跳过\n' >&2
        return 0
    }
    mise install go buf protoc protoc-gen-go protoc-gen-go-grpc
    mise install node pnpm
    MISE_PYTHON_COMPILE=0 MISE_PYTHON_PRECOMPILED_FLAVOR='freethreaded+pgo+lto-full' \
        mise install 'python[patch_sysconfig=false]@3'
    mise install uv
    mise sync python --uv
}

# ============================================================
# 参数解析
# ============================================================
MODE=interactive
PROFILE=''
ARGS=''

for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) DRY_RUN=1 ;;
        -l|--list)    MODE=list ;;
        -s|--select)  MODE=interactive ;;
        -p|--profile) MODE=profile ;;
        -h|--help)    sed -n '2,18p' "$0"; exit 0 ;;
        *)            ARGS="$ARGS $arg" ;;
    esac
done

[ "$MODE" = "list" ] && { list_tools; exit 0; }

SELECTED=''

# 无 Homebrew 时提示安装后退出（避免盲目执行远程脚本）
command -v brew >/dev/null 2>&1 || {
    printf '未检测到 Homebrew，先执行:\n'
    printf '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\n'
    printf '然后重新运行本脚本。\n'
    exit 1
}

case "$MODE" in
    profile)
        [ -n "$ARGS" ] || { printf '用法: %s -p <profile名>\n' "$0" >&2; exit 1; }
        SELECTED=$(profile_entries "${ARGS# }")
        ;;
    *)
        # 组不作为安装参数；非 profile 模式不接受位置参数
        [ -z "$ARGS" ] || {
            printf '未知参数: %s\n用法见: %s -h\n' "${ARGS# }" "$0" >&2
            exit 1
        }
        ;;
esac

FROM_INTERACTIVE=0
if [ -z "${SELECTED:-}" ]; then
    SELECTED=$(pick_interactive)
    FROM_INTERACTIVE=1
fi

SELECTED=$(printf '%s\n' "$SELECTED" | sed '/^$/d' | sort -u)
[ -n "$SELECTED" ] || { printf '未选择任何工具\n' >&2; exit 1; }

printf '将安装:\n'
while IFS= read -r e; do
    [ -n "$e" ] || continue
    printf '  %-22s [%s] %s\n' "$(entry_name "$e")" "$(entry_type "$e")" "$(entry_desc "$e")"
done <<EOF
$SELECTED
EOF
printf '\n'

# 交互选择可保存为 profile（dry-run 只读，不保存）
if [ "$FROM_INTERACTIVE" -eq 1 ]; then
    save_profile
fi

install_entries

# 选中 rustup 时追加工具链初始化（有 y/N 确认）
if printf '%s\n' "$SELECTED" | grep -q '^rustup|'; then
    post_dev_steps
fi

# 选中 mise 时追加语言/工具链初始化（有 y/N 确认）
if printf '%s\n' "$SELECTED" | grep -q '^mise|'; then
    post_mise_steps
fi

printf '\n完成。\n'
