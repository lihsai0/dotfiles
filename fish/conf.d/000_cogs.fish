# Enabled cogs — one name per conf.d/{NNN}_{name}.fish file.
# Every conf.d snippet starts with a guard that returns early when its
# name is not listed here, so this file is the master switch.
set -g cogs \
    buf \
    docker \
    docker-compose \
    exercism \
    eza \
    fzf \
    gh \
    git \
    git-lfs \
    golang \
    gpg-agent \
    mise \
    pnpm \
    python \
    rust \
    starship \
    uv \
    zoxide

switch (uname)
    case Darwin
        set -a cogs macos
        set -a cogs mole
    case Linux
        if test -f /etc/arch-release
            set -a cogs archlinux
        end
end

# Configure the cogs options
# --- eza ---
if command -q eza
    set -g EZA_ICONS yes
    set -g EZA_TIME_STYLE "+%Y%m%d %H%M"\n" %m-%d %H:%M "
end
