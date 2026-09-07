# python
#
#   aliases    py (python3 only when no `py` command exists)
#              pyfind,
#              pygrep(pyrg when `ripgrep` exists),
#              pyserver
#   functions  pyclean, pyuserpaths, vrun, mkv, auto_vrun (opt-in)
#   variables  PYTHON_VENV_NAME, PYTHON_VENV_NAMES, PYTHON_AUTO_VRUN
if not contains "python" $cogs
    return 0
end

function __python_set_alias
    # Setup alias and abbr
    if not type -q py
        abbr -a py python3
    end

    # Share local directory as a HTTP server
    abbr -a pyserver 'python3 -m http.server'

    # Grep among .py files
    if type -q rg
        abbr -a pyrg 'rg -g "*.py"'
    else
        abbr -a pygrep 'grep -nr --include="*.py"'
    end

    # Find python file
    if type -q fd
        abbr -a pyfind 'fd -u -g "*.py"'
    else
        abbr -a pyfind 'find . -name "*.py"'
    end
end

__python_set_alias

functions -e __python_set_alias

# Remove python compiled byte-code and mypy/pytest cache in either the
# current directory or in a list of specified directories (incl. subdirs).
function pyclean -d "Remove python cache in current directory or given directories"
    set -l dirs .
    if set -q argv[1]
        set dirs $argv
    end

    if type -q fd
        # -u = --hidden --no-ignore: match `find`, which ignores neither
        # hidden nor .gitignore'd entries (the cache dirs are usually ignored).
        fd -u -t f -g '*.py[co]' $dirs -X rm -f
        fd -u -t d -g '__pycache__' $dirs -X rm -rf
        fd -u -t d -g '.mypy_cache' $dirs -X rm -rf
        fd -u -t d -g '.pytest_cache' $dirs -X rm -rf
    else
        find $dirs -type f -name "*.py[co]" -delete
        find $dirs -type d -name "__pycache__" -delete
        find $dirs -depth -type d -name ".mypy_cache" -exec rm -r "{}" +
        find $dirs -depth -type d -name ".pytest_cache" -exec rm -r "{}" +
    end
end

# Add the user-installed site-packages paths to PYTHONPATH, only if the
# directory exists; preserves the current PYTHONPATH value.
function pyuserpaths -d "Add the user-installed site-packages paths to PYTHONPATH"
    # Check for a non-standard install directory.
    set -l user_base $HOME/.local
    set -q PYTHONUSERBASE
    and set user_base $PYTHONUSERBASE

    for python in python2 python3
        command -q $python; or continue

        # Get the minor release version ("x.y", patch truncated),
        # e.g. "Python 3.12.4" → "3.12".
        set -l py_ver ($python -V 2>&1 | string replace -r '^Python ([0-9]+\.[0-9]+).*$' '$1')
        if not set -q py_ver[1]
            continue
        end

        set -l site_pkgs "$user_base/lib/python$py_ver/site-packages"
        # Only add the path if it exists and is not already in $PYTHONPATH.
        if not test -d "$site_pkgs"
            continue
        end
        if set -q PYTHONPATH
            if contains -- "$site_pkgs" (string split : -- "$PYTHONPATH")
                continue
            end
            set -gx PYTHONPATH "$site_pkgs:$PYTHONPATH"
        else
            set -gx PYTHONPATH "$site_pkgs"
        end
    end
end


## venv settings
set -q PYTHON_VENV_NAME
or set -g PYTHON_VENV_NAME venv

# Array of possible virtual environment names to look for, in order.
if not set -q PYTHON_VENV_NAMES
    set -g PYTHON_VENV_NAMES $PYTHON_VENV_NAME venv .venv
    # Drop duplicates, keep first occurrence (zsh typeset -U).
    set -l unique
    for name in $PYTHON_VENV_NAMES
        if not contains -- $name $unique
            set -a unique $name
        end
    end
    set -g PYTHON_VENV_NAMES $unique
end

# Activate the python virtual environment specified; if none is specified,
# use the first existing one listed in $PYTHON_VENV_NAMES.
function vrun -a venvname
    if not set -q venvname
        for name in $PYTHON_VENV_NAMES
            if test -d "$name"
                vrun "$name"
                return $status
            end
        end
        echo >&2 "Error: no virtual environment found in current directory"
        return 1
    end

    set -l name $venvname
    set -l venvpath (path resolve -- "$name")

    if not test -d "$venvpath"
        echo >&2 "Error: no such venv in current directory: $name"
        return 1
    end

    if not test -f "$venvpath/bin/activate.fish"
        echo >&2 "Error: '$name' is not a proper virtual environment"
        return 1
    end

    source "$venvpath/bin/activate.fish"; or return $status
    echo "Activated virtual environment $name"
end

# Create a new virtual environment using the specified name; if none is
# specified, use $PYTHON_VENV_NAME.
function mkv -a venvname
    set -l name $PYTHON_VENV_NAME
    if set -q venvname
        set name $venvname
    end

    python3 -m venv "$name"; or return $status
    echo >&2 "Created venv in '$name'"
    vrun "$name"
end

if test "$PYTHON_AUTO_VRUN" = true
    # Automatically activate a venv when changing directory.
    function __auto_vrun --on-variable PWD
        # Deactivate if we moved out of the active venv's directory tree
        # (but not when merely descending into one of its subdirectories).
        set -l active_parent
        if set -q VIRTUAL_ENV
            set active_parent (path dirname -- "$VIRTUAL_ENV")
            if functions -q deactivate
                and not string match -q -- "$active_parent/*" "$PWD"
                deactivate >/dev/null 2>&1
            else if test "$PWD" = "$active_parent"
                # At the root of the active venv: nothing to do.
                return 0
            end
        end

        # Activate the first venv found in the new directory, in
        # $PYTHON_VENV_NAMES order.
        for name in $PYTHON_VENV_NAMES
            if test -f "$PWD/$name/bin/activate.fish"
                # Make sure we are not inside another venv already.
                functions -q deactivate; and deactivate >/dev/null 2>&1
                source "$PWD/$name/bin/activate.fish"
                break
            end
        end
    end

    # Activate when starting inside a venv directory, as the plugin does.
    __auto_vrun
end
