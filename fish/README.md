# Fish Configurations

Almost all conf is migated from Oh My Zsh. The differences are listed below in [Differences From Oh My Zsh](#differences-from-oh-my-zsh).

## Set Global Variables

Only run this once time. These variables will be stored in `fish_variables` file.

```fish
set -Ux EDITOR hx
set -Ux LANG en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8
```

## Directory Structure

```
fish/
├── config.fish   # your personal fish config
├── conf.d/       # the configuration snippets (details see below)
└── completions/  # the generated completions (gitignored, unless manually sourced)
```

| Prefix | Category | Contents |
|---|---|---|
| 000 | Base configurations | `PATH`, enable other snippets |
| 010 | Shell | starship, macos, archlinux, dotenv, mise |
| 020 | Basic tools enhancement | eza(ls), zoxide(cd) |
| 030 | Extra tools | git、git-lfs、fzf、docker、docker-compose、gpg-agent |
| 040 | Programming languages | rust, golang, python, uv, pnpm, buf |
| 050 | Other tools | gh、exercism |

## Usage

```sh
ln -sf $(realpath ./fish) ~/.config/fish
```

### How to disable a script?

Just remove the script name from `cogs` list of `conf.d/000_enabled_cogs.fish`.

## Differences From Oh My Zsh

### eza

TODO: option variables from `conf.d/020_eza.fish`.

### macos

Removed terminal split tab support. You should manage terminal tabs by zellij/tmux or your terminal emulator.

TODOs:

- [ ] Music / iTunes control function
- [ ] Spotify control function

### fzf

Removed old version fallback.

### rust

`rustup completions fish` doesn't support `cargo` for now, but luckly Fish could auto generate completions for it.

### gpg-agent

The `gnupg_SSH_AUTH_SOCK_by` PID guard is dropped - gpg-agent ships no fish integration script that would set that marker.

<details>
<summary>Don't worry about that, you don't need it.</summary>

`gnupg_SSH_AUTH_SOCK_by` is be used as a PID guard for the SSH agent. SSH agent will working fine without it but just reassigned.
</details>
