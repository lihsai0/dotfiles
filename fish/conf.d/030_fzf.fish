# fzf
if not contains "fzf" $cogs
    return 0
end

if not command -q fzf
    echo "[WARNING] fzf not found. Please install it." >&2
    return 1
end

# Key bindings + completion (fzf >= 0.48.0). `bind` requires an interactive
# shell, so only run it there.
if status is-interactive
    fzf --fish | source
end

# Default file-listing command (mirrors the plugin's fd > rg > ag preference).
if not set -q FZF_DEFAULT_COMMAND
    if command -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
    else if command -q rg
        set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git/*"'
    else if command -q ag
        set -gx FZF_DEFAULT_COMMAND 'ag -l --hidden -g "" --ignore .git'
    end
end
