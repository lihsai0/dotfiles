## Usage

```sh
git clone https://github.com/lihsai0/dotfiles.git
cd dotfiles
```

以下命令从仓库根目录开始，每步按所示 cd 进入对应目录执行。

### 1. Install tools

工具清单在 `homebrew/install_tools.sh`，每个工具附一句话说明，支持按需选择:

```sh
cd homebrew
./install_tools.sh -l              # 查看全部工具与分组
./install_tools.sh                 # 交互勾选（有 fzf 用多选界面，否则按编号）
./install_tools.sh -p example      # 按 profile 复现固定子集（profiles/*.list）
./install_tools.sh -n -p example   # dry-run 预览
```

工具装了什么，zsh 对应插件自动启用（zshrc 按命令存在性检测），两边无需手工同步。
交互勾选完成后可将所选工具保存为 profile（输入名称即存入 `homebrew/profiles/`），
下次 `-p <名称>` 精确复现；分组仅用于列表展示，不作为安装参数。

### 2. Install Oh My Zsh

```sh
cd zsh
./install_omz.sh
```

幂等，可重复执行；使用 `--unattended` 安装，不会覆盖已有 zshrc。

### 3. Link configs

```sh
cd docs
./ln_files.sh             # 链接全部模块
./ln_files.sh zsh git     # 只链接指定模块
./ln_files.sh --dry-run   # 预览
```

目标位置已存在真实文件/目录时跳过不覆盖，脚本可重复执行。
模块与路径的映射表见 `docs/install/links.sh`。

### 4. Git identity

```sh
cd <仓库根>      # 回到仓库根
cp git/config_local_tpl ~/.config/git/config.local
# 编辑 config.local 填写 name / email；signingkey 可选，没有就不填
```

`git/config` 为通用配置（链接后立即生效），身份信息不入库。

### Optional

个人别名、机器特定配置放入 `~/.oh-my-zsh/custom/local.zsh`（不入库），
由 zshrc 自动加载，例: `plugins+=(docker golang)`。

## How It Works

核心机制一句话：**工具靠 PATH 生效，配置靠软链"冒充"各工具的默认查找路径生效，
两者由 zshrc 的命令守卫串成闭环**。

### 1. 引导链: shell 启动时发生什么

```
终端 (Ghostty/Alacritty) 启动
  → zsh 读 ~/.zshrc                    ← 软链 → 仓库 zsh/zshrc
    → Oh My Zsh 加载基础插件
    → $+commands 守卫逐条检测 PATH 中实际存在的命令，追加对应插件
    → 插件内部的 hook 接管各工具:
        starship → 提示符
        zoxide   → cd 增强
        mise     → 语言版本切换 (activate)
        zsh-autosuggestions / syntax-highlighting → 补全与高亮
    → TERM 检测命中 Ghostty/Alacritty 时自动启动 zellij
```

zshrc 是唯一入口——它既加载 shell 插件，也 export 了 `STARSHIP_CONFIG` 等路径变量。

### 2. 配置生效: 软链冒充默认查找路径

各工具只认自己的固定路径，`ln_files.sh` 把仓库文件链过去，工具启动时"以为"在读本地配置:

| 仓库文件 | 链接到 | 工具如何找到它 |
|---|---|---|
| `zsh/zshrc` | `~/.zshrc` | zsh 启动固定读取 |
| `git/config` | `~/.config/git/config` | git 内置的 XDG 查找路径；再 `[include]` 链 `config.local`（身份）；`includeIf` 多身份为预留占位，未启用 |
| `starship/`、`zellij/`、`btop/`、`helix/`、`alacritty/`、`zed/` | `~/.config/<tool>` | 各自的 XDG 默认路径 |
| `ghostty/` | `~/.config/ghostty` | 目录级链接；目录内 `config` 软链到 `config.ghostty`（ghostty 只认 `config` 文件名，相对链接保证跨机器有效） |
| `zsh/omz-plugins/*` | `$ZSH_CUSTOM/plugins/*` | OMZ 从 custom 目录发现插件 |
| `zsh/functions/yazi.zsh` | `$ZSH_CUSTOM/yazi.zsh` | OMZ 自动 source custom 下所有 `.zsh` |

## Migration Tips

Find broken links.

```sh
fd -IH --type symlink ".*" ~ -E Library -E Applications -x sh -c '
    target=$(readlink "$1")
    if [ -e "$1" ]; then
        echo "$1 -> $target"
    else
        echo "$1 -> $target (broken)"
    fi
' _ {} | rg "dotfiles"
```

Or, remove all links then re-link them:

```sh
./docs/install/rm_links.sh
./docs/install/ln_files.sh
```
