# eza
#
# CONFIGURATION
#
#   Variable              Values          Default          Effect
#   --------------------------------------------------------------------------------
#   eza_dirs_first        yes|no          no(unset)        --group-directories-first
#   eza_git_status        yes|no          no(unset)        --git
#   eza_header            yes|no          no(unset)        -h  column headers
#   eza_show_group        yes|no|smart    yes(unset)       -g  show group ownership
#   eza_icons             yes|no          no(unset)        --icons=auto
#   eza_color_scale       all|age|size    none(unset)      --color-scale=…
#   eza_color_scale_mode  gradient|fixed  gradient(unset)  --color-scale-mode=…
#   eza_size_prefix       binary|none|si  si(unset)        size prefix style
#   eza_time_style        any eza value   (unset)          --time-style=…
#   eza_hyperlink         yes|no|         no(unset)        --hyperlink
#   --------------------------------------------------------------------------------
#
# ALIASES
#
#   ls    → eza
#   la    → eza -la
#   ll    → eza -l
#   lD    → eza -lD
#   lDD   → eza -laD
#   ldot  → eza -ld .*
#   lsd   → eza -d
#   lsdl  → eza -dl
#   lS    → eza -l -ssize
#   lT    → eza -l -snewest

if not contains "eza" $cogs
    return 0
end

if not command -q eza
    echo "[WARNING] eza not found. Please install it." >&2
    return 1
end

# --- configuration ---

function __eza_yes -a val
    contains -- (string lower -- "$val") yes true 1 on
end

set -g __eza_short_opts
set -g __eza_long_opts

function __eza_init
    if __eza_yes "$EZA_SHOW_GROUP"
        set -a __eza_short_opts g
    else if test (string lower -- "$EZA_SHOW_GROUP") = smart
        set -a __eza_long_opts --smart-group
    end

    __eza_yes "$EZA_HEADER"
    and set -a __eza_short_opts h

    switch (string lower -- "$EZA_SIZE_PREFIX")
        case binary
            set -a __eza_short_opts b
        case none
            set -a __eza_short_opts B
    end

    __eza_yes "$EZA_DIRS_FIRST"
    and set -a __eza_long_opts --group-directories-first

    __eza_yes "$EZA_GIT_STATUS"
    and set -a __eza_long_opts --git

    __eza_yes "$EZA_ICONS"
    and set -a __eza_long_opts --icons=auto

    test -n "$EZA_COLOR_SCALE"
    and set -a __eza_long_opts "--color-scale=$EZA_COLOR_SCALE"

    contains -- "$EZA_COLOR_SCALE_MODE" gradient fixed
    and set -a __eza_long_opts "--color-scale-mode=$EZA_COLOR_SCALE_MODE"

    test -n "$EZA_TIME_STYLE"
    and set -a __eza_long_opts "--time-style=$EZA_TIME_STYLE"

    if __eza_yes "$EZA_HYPERLINK"
        if eza --hyperlink=auto --version >/dev/null 2>&1
            set -a __eza_long_opts --hyperlink=auto
        else
            set -a __eza_long_opts --hyperlink
        end
    end
end

__eza_init

functions -e __eza_yes __eza_init

# Setup User
function ls -w eza
    set -l parts
    set -l short_opts (string join "" -- $__eza_short_opts)
    if test -n "$short_opts"
        set -a parts "-$short_opts"
    end
    if set -q __eza_long_opts[1]
        set -a parts $__eza_long_opts
    end
    command eza $parts $argv
end

function tree -w eza
    ls -lah --tree $argv
end

abbr -a l 'ls -lah'
abbr -a ll 'ls -l'
abbr -a la 'ls -la'
abbr -a lD 'ls -lD'
abbr -a lDD 'ls -lDa'
abbr -a lsd 'ls -d'
abbr -a lsdl 'ls -dl'
abbr -a lS 'ls -lah -ssize'
abbr -a lT 'ls -lah -snewest'
abbr -a ldot 'ls -ld .*'
