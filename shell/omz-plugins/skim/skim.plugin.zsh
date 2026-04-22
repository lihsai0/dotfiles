SKIM_BASE="" # empty to auto determine
DISABLE_SKIM_AUTO_COMPLETION="true"
DISABLE_SKIM_KEY_BINDINGS="true"

function skim_setup() {
  local skim_base skim_shell skim_dirs

  test -d "${SKIM_BASE}" && skim_base="${SKIM_BASE}"

  if [[ -z "${skim_base}" ]]; then
    skim_dirs=(
      "${HOME}/.sk"
      "${HOME}/.nix-profile/share/sk"
      "${XDG_DATA_HOME:-$HOME/.local/share}/sk"
      "${MSYSTEM_PREFIX}/share/sk"
      "/usr/local/opt/sk"
      "/opt/homebrew/opt/sk"
      "/usr/share/sk"
      "/usr/local/share/examples/sk"
    )
    for dir in ${skim_dirs}; do
      if [[ -d "${dir}" ]]; then
        skim_base="${dir}"
        break
      fi
    done

    if [[ -z "${skim_base}" ]]; then
      if (( $+commands[brew] )) && dir="$(brew --prefix sk 2>/dev/null)"; then
        if [[ -d "${dir}" ]]; then
          skim_base="${dir}"
        fi
      fi
    fi

    if [[ ! -d "${skim_base}" ]]; then
      return 1
    fi

    # Setup skim binary path
    if (( ! $+commands[sk] )) && [[ "$PATH" != *$skim_base/bin* ]]; then
      export PATH="$PATH:$skim_base/bin"
    fi

    # Auto-completion
    if [[ -o interactive && "$DISABLE_SKIM_AUTO_COMPLETION" != "true" ]]; then
      eval "$(sk --shell zsh)"
    fi

    # Key bindings
    skim_shell="${skim_base}/share/zsh/site-functions"
    if [[ "$DISABLE_SKIM_KEY_BINDINGS" != "true" ]]; then
      source "${skim_shell}/key-bindings.zsh"
    fi

  fi
}

function skim_setup_error() {
  cat >&2 <<'EOF'
[oh-my-zsh] skim setup: Cannot find skim installation directory.
Please add `export SKIM_BASE=/path/to/skim/install/dir` to your .zshrc
EOF
}

skim_setup || skim_setup_error
unset -f -m 'skim_setup*'
unset SKIM_BASE DISABLE_SKIM_AUTO_COMPLETION DISABLE_SKIM_KEY_BINDINGS
