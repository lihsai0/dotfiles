# uv — uv / uvx aliases + completion (from Oh My Zsh uv plugin)
#
# ALIASES
#   All 21 aliases from uv.plugin.zsh are ported 1:1 below; names kept exact.
#   NOTE: The zsh `alias uv="noglob uv"` has no fish equivalent — fish has no
#   `noglob`, so `uv` is intentionally left unaliased (glob expansion is
#   simply not performed against command arguments the same way; no alias).
#
# COMPLETION
#   The zsh plugin regenerates `_uv`/`_uvx` at startup via
#   `uv generate-shell-completion zsh` / `uvx --generate-shell-completion zsh`.
#   Here the fish outputs are generated once and cached as
#   $__fish_config_dir/completions/uv.fish and …/uvx.fish.
#   Generators verified on stdout: `uv generate-shell-completion fish` emits
#   ~3900 `complete -c uv …` lines (targets `uv` → uv.fish);
#   `uvx --generate-shell-completion fish` emits `complete -c uvx …` lines
#   (targets `uvx` → uvx.fish). `2>/dev/null` swallows generator stderr noise.

if not contains "uv" $cogs
    return 0
end

if not command -q uv
    echo "[WARNING] uv not found. Please install it." >&2
    return 1
end

abbr -a uva 'uv add'
abbr -a uvexp 'uv export --format requirements-txt --no-hashes --output-file requirements.txt --quiet'
abbr -a uvi 'uv init'
abbr -a uvinw 'uv init --no-workspace'
abbr -a uvl 'uv lock'
abbr -a uvlr 'uv lock --refresh'
abbr -a uvlu 'uv lock --upgrade'
abbr -a uvp 'uv pip'
abbr -a uvpi 'uv python install'
abbr -a uvpl 'uv python list'
abbr -a uvpu 'uv python uninstall'
abbr -a uvpy 'uv python'
abbr -a uvpp 'uv python pin'
abbr -a uvr 'uv run'
abbr -a uvrm 'uv remove'
abbr -a uvs 'uv sync'
abbr -a uvsr 'uv sync --refresh'
abbr -a uvsu 'uv sync --upgrade'
abbr -a uvtr 'uv tree'
abbr -a uvup 'uv self update'
abbr -a uvv 'uv venv'

if command -q uv; and not test -f $__fish_config_dir/completions/uv.fish
    uv generate-shell-completion fish > $__fish_config_dir/completions/uv.fish 2>/dev/null
end
if command -q uvx; and not test -f $__fish_config_dir/completions/uvx.fish
    uvx --generate-shell-completion fish > $__fish_config_dir/completions/uvx.fish 2>/dev/null
end
