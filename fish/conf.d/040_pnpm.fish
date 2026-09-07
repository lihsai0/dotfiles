# pnpm — pnpm completion (from custom OMZ pnpm plugin)
#
# NOTE: Despite the migration table's mention of aliases, the custom OMZ
# pnpm plugin (zsh/omz-plugins/pnpm) defines NO aliases — it only wires up
# completion: pnpm.plugin.zsh generates the tabtab-based pnpm_completion.zsh
# via `pnpm completion zsh` and sources it. So this file is completion-only.
#
# pnpm's fish support goes through tabtab: `pnpm completion fish` emits the
# tabtab fish script (function `_pnpm_completion`, registering
# `complete … -c pnpm`), which is cached here once.
# Generator verified: full output to a file exits 0, starts with
# "###-begin-pnpm-completion-###" / "function _pnpm_completion" and registers
# "complete -f -d 'pnpm' -c pnpm -a '(_pnpm_completion)'".
# `2>/dev/null` swallows tabtab generator stderr noise.

if not contains "pnpm" $cogs
    return 0
end

if not type -q pnpm
    echo "[WARNING] pnpm not found. Please install it." >&2
    return 1
end

if not test -f $__fish_config_dir/completions/pnpm.fish
    pnpm completion fish > $__fish_config_dir/completions/pnpm.fish 2>/dev/null
end
