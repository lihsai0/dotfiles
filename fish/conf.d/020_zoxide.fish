# zoxide
if not contains "zoxide" $cogs
    return 0
end

if not command -q zoxide
    echo '[WARNING] zoxide not found. Please install it.' >&2
end

# ZOXIDE_CMD_OVERRIDE keeps the old zsh behaviour configurable
set -l cmd z
if set -q ZOXIDE_CMD_OVERRIDE
    set cmd $ZOXIDE_CMD_OVERRIDE
end
zoxide init --cmd $cmd fish | source
