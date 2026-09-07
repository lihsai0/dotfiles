# gpg-agent
#
# NOTE: the `gnupg_SSH_AUTH_SOCK_by` PID guard is dropped - gpg-agent ships
# no fish integration script that would set that marker.
if not contains "gpg-agent" $cogs
    return 0
end

if not command -q gpgconf
    echo "[WARNING] gpgconf not found. Please install GnuPG." >&2
    return 1
end

set -gx GPG_TTY (tty)

function _gpg-agent_update_tty --on-event fish_preexec
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
end

# If enable-ssh-support is set, fix SSH agent integration.
if test (gpgconf --list-options gpg-agent 2>/dev/null | string match 'enable-ssh-support:*' | string split -f 10 :) = 1
    set -e SSH_AGENT_PID
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end
