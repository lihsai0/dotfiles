#!/usr/bin/env bash
# 安装 Oh My Zsh 与外部插件（幂等，可重复执行）
set -euo pipefail

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ====================
# Install Oh My Zsh
# --unattended: 不切换默认 shell、不覆盖已有 zshrc
# ====================
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # Alternatively, the installer is also mirrored outside GitHub.
    # You will need this, if you are behind a firewall blocking GitHub.
    # sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
else
    echo "Oh My Zsh 已存在，跳过安装"
fi

# ====================
# Install omz external plugins
# ====================
clone_plugin() {
    local name=$1 url=$2
    if [ -d "$ZSH_CUSTOM_DIR/plugins/$name" ]; then
        echo "插件 $name 已存在，跳过"
    else
        git clone --depth=1 "$url" "$ZSH_CUSTOM_DIR/plugins/$name"
    fi
}

clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
clone_plugin zsh-completions https://github.com/zsh-users/zsh-completions.git

echo
echo "完成。后续步骤（在仓库根目录执行）:"
echo "  ./docs/install/ln_files.sh zsh   # 链接 zshrc 与自定义插件"
