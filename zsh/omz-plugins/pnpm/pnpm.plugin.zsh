current_file=${(%):-%N}
function pnpm_setup() {
  local pnpm_plugin_dir=${current_file:A:h}
  local pnpm_completion_file="$pnpm_plugin_dir/pnpm_completion.zsh"

  if (( ! $+commands[pnpm] )); then
    return 1
  fi

  if [[ ! -f "$pnpm_completion_file" ]]; then
    pnpm completion zsh > "$pnpm_completion_file"
  fi

  if [[ ! -f "$pnpm_completion_file" ]]; then
    return 2
  fi

  source "$pnpm_completion_file"
}

function pnpm_setup_error() {
  cat >&2 <<'EOF'
[oh-my-zsh] pnpm setup: Cannot find pnpm.
EOF
}

pnpm_setup || pnpm_setup_error
unset current_file
unset -f -m 'pnpm_setup*'
