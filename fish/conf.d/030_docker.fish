# docker — Docker CLI aliases + completion (from Oh My Zsh docker plugin)
#
# ALIASES
#   All 40 aliases from docker.plugin.zsh are ported 1:1 below; names kept
#   exact, including the `drm!` alias. All are plain single-command aliases
#   except `dsta`, whose `$(docker ps -q)` body becomes a function using
#   fish `(…)` command substitution (output split per line, as in zsh).
#
# COMPLETION
#   The zsh plugin regenerates `_docker` at startup (using `docker completion
#   zsh` on docker >= 23.0.0). Here the native fish completions are generated
#   once into $__fish_config_dir/completions/docker.fish. In production that
#   file already exists as a symlink into OrbStack's resources, so this is a
#   no-op. `2>/dev/null` swallows errors from docker builds/contexts that lack
#   the `completion` subcommand (< 23.0.0).
#   Generator verified on this machine (OrbStack CLI): `docker completion fish`
#   exits 0 and starts with "# fish completion for docker".

if not contains "docker" $cogs
    return 0
end

if not type -q docker
    echo "[WARNING] docker not found. Please install it." >&2
    return 1
end

abbr -a dbl 'docker build'
abbr -a dcin 'docker container inspect'
abbr -a dcls 'docker container ls'
abbr -a dclsa 'docker container ls -a'
abbr -a dcprune 'docker container prune'
abbr -a dib 'docker image build'
abbr -a dii 'docker image inspect'
abbr -a dils 'docker image ls'
abbr -a dipu 'docker image push'
abbr -a dipru 'docker image prune -a'
abbr -a dirm 'docker image rm'
abbr -a dit 'docker image tag'
abbr -a dlo 'docker container logs'
abbr -a dnc 'docker network create'
abbr -a dncn 'docker network connect'
abbr -a dndcn 'docker network disconnect'
abbr -a dni 'docker network inspect'
abbr -a dnls 'docker network ls'
abbr -a dnprune 'docker network prune'
abbr -a dnrm 'docker network rm'
abbr -a dpo 'docker container port'
abbr -a dps 'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a dpu 'docker pull'
abbr -a dr 'docker container run'
abbr -a drit 'docker container run -it'
abbr -a drm 'docker container rm'
abbr -a 'drm!' 'docker container rm -f'
abbr -a dsprune 'docker system prune'
abbr -a dst 'docker container start'
abbr -a drs 'docker container restart'
abbr -a dstp 'docker container stop'
abbr -a dsts 'docker stats'
abbr -a dtop 'docker top'
abbr -a dvi 'docker volume inspect'
abbr -a dvls 'docker volume ls'
abbr -a dvprune 'docker volume prune'
abbr -a dxc 'docker container exec'
abbr -a dxcit 'docker container exec -it'
abbr -a dsta 'docker stop (docker ps -q)'

if not test -f $__fish_config_dir/completions/docker.fish
    docker completion fish > $__fish_config_dir/completions/docker.fish 2>/dev/null
end
