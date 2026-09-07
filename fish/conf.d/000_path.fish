# --- Path Setup ---
# Homebrew
if test -d /opt/homebrew
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

# Cargo
if test -d $HOME/.cargo
    set -x CARGO_HOME $HOME/.cargo
    fish_add_path $CARGO_HOME/bin
end

# PNPM
if test -d $HOME/.local/share/pnpm
    set -x PNPM_HOME $HOME/.local/share/pnpm
    fish_add_path $PNPM_HOME/bin
end

# SQLite (Homebrew)
if type -q brew; and test -d (brew --prefix)/opt/sqlite3
    set -x SQLITE_HOME (brew --prefix)/opt/sqlite3
    fish_add_path $SQLITE_HOME/bin
end
