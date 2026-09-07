# docker-compose
#
# The full alias set of the OMZ docker-compose plugin (the plugin defines
# nothing besides these aliases). Base command is the standalone
# `docker-compose` executable when present, otherwise the `docker compose`
# CLI plugin (Compose v2), exactly like the plugin.
#
# Aliases: dco dcb dcc dce dcps dcrestart dcrm dcr dcstop dcup dcupb dcupd
#          dcupdb dcdn dcl dclf dclF dcpull dcstart dck
if not contains "docker-compose" $cogs
    return 0
end

set -l dccmd docker-compose
if not command -q docker-compose
    set dccmd docker compose
end

abbr -a dco "$dccmd"
abbr -a dcb "$dccmd build"
abbr -a dcc "$dccmd config"
abbr -a dce "$dccmd exec"
abbr -a dcps "$dccmd ps"
abbr -a dcrestart "$dccmd restart"
abbr -a dcrm "$dccmd rm"
abbr -a dcr "$dccmd run"
abbr -a dcstop "$dccmd stop"
abbr -a dcup "$dccmd up"
abbr -a dcupb "$dccmd up --build"
abbr -a dcupd "$dccmd up -d"
abbr -a dcupdb "$dccmd up -d --build"
abbr -a dcdn "$dccmd down"
abbr -a dcl "$dccmd logs"
abbr -a dclf "$dccmd logs -f"
abbr -a dclF "$dccmd logs -f --tail 0"
abbr -a dcpull "$dccmd pull"
abbr -a dcstart "$dccmd start"
abbr -a dck "$dccmd kill"
