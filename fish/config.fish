# Commands to run in interactive sessions can go here
if status is-interactive
    # Useful Commands
    function history -w history -d 'history with timestamps by default'
        builtin history --show-time='%Y-%m-%d %H:%M:%S ' $argv
    end

    alias fish_reload='exec fish'
    alias vim='nvim --clean'
    abbr -a zrf 'zellij run --floating'

    # Zellij Setup when Alacritty or Ghostty
    if contains -- $TERM alacritty xterm-ghostty
        # fix Zellij run unexpected in zed
        and isatty stdin
        and isatty stdout
        and test "$ZED_TERM" != true
        set ZELLIJ_AUTO_ATTACH false
        set ZELLIJ_AUTO_EXIT true
        set ZELLIJ_DATA_DIR $HOME/.config/zellij

        # eval (zellij setup --generate-auto-start fish | string collect)
        if not set -q ZELLIJ
            if test "$ZELLIJ_AUTO_ATTACH" = true
                zellij --data-dir $ZELLIJ_DATA_DIR attach -c
            else
                zellij --data-dir $ZELLIJ_DATA_DIR
            end

            if test "$ZELLIJ_AUTO_EXIT" = true
                kill $fish_pid
            end
        end
    end

end
