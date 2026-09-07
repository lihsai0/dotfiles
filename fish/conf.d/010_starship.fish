# starship
if not contains "starship" $cogs
    return 0
end

if not command -q starship
    echo "[WARNING] starship not found. Please install it." >&2
    return 1
end

set -x STARSHIP_CONFIG ~/.config/starship/config.toml
command starship init fish | source
