# archlinux
#
# Port of the Oh My Zsh archlinux plugin (pacman + AUR helper aliases and
# functions).
#
# NOTE
#   - This cog has no single required binary: pacman aliases/functions are
#     defined only when `pacman` is on PATH, and each AUR helper's aliases only
#     when that helper (aura / pacaur / trizen / yay) is installed. On non-Arch
#     systems the cog is therefore a clean no-op — no WARNING is printed.
#   - Unlike the plugin (which defines pacman aliases unconditionally), here
#     they are gated on `command -q pacman`.
#   - `pacdisowned` keeps GNU find's `-printf` (Arch ships GNU findutils) and
#     the zsh `trap … EXIT` cleanup.
#   - `pacweb` drops the OMZ theme colour variables (zsh-only) and uses `string`
#     instead of `grep -oP`; `upgrade` likewise uses `string` instead of the
#     PCRE `grep -Po '(?<=…)…'` lookbehind.

if not contains "archlinux" $cogs
    return 0
end

if test (uname) != "Linux" and test -f /etc/arch-release
    echo '[WARNING] Not in Arch Linux system. Should remove "archlinux" from cogs list'
    return 1
end

# --- pacman ---
abbr -a pacupg 'sudo pacman -Syu'
abbr -a pacin 'sudo pacman -S'
abbr -a paclean 'sudo pacman -Sc'
abbr -a pacins 'sudo pacman -U'
abbr -a paclr 'sudo pacman -Scc'
abbr -a pacre 'sudo pacman -R'
abbr -a pacrem 'sudo pacman -Rns'
abbr -a pacrep 'pacman -Si'
abbr -a pacreps 'pacman -Ss'
abbr -a pacloc 'pacman -Qi'
abbr -a paclocs 'pacman -Qs'
abbr -a pacinsd 'sudo pacman -S --asdeps'
abbr -a pacmir 'sudo pacman -Syy'
abbr -a paclsorphans 'pacman -Qdt'
abbr -a pacrmorphans 'sudo pacman -Rs (pacman -Qtdq)'
abbr -a pacfileupg 'sudo pacman -Fy'
abbr -a pacfiles 'pacman -F'
abbr -a pacls 'pacman -Ql'
abbr -a pacown 'pacman -Qo'
abbr -a pacupd 'sudo pacman -Sy'
abbr -a pacmanallkeys 'sudo pacman-key --refresh-keys'

function paclist -d "List explicitly installed packages with descriptions"
    pacman -Qqe | xargs -I{} -P0 --no-run-if-empty pacman -Qs --color=auto "^{}\$"
end

function pacdisowned -d "List files not owned by any package"
    set -l tmp_dir (mktemp --directory)
    set -l db $tmp_dir/db
    set -l fs $tmp_dir/fs

    trap "rm -rf $tmp_dir" EXIT

    pacman -Qlq | sort -u > "$db"

    find /etc /usr ! -name lost+found \
        \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

    comm -23 "$fs" "$db"

    rm -rf $tmp_dir
end

function pacmansignkeys -d "Receive and locally sign the given PGP keys"
    for key in $argv
        sudo pacman-key --recv-keys $key
        sudo pacman-key --lsign-key $key
        printf 'trust\n3\n' | sudo gpg --homedir /etc/pacman.d/gnupg \
            --no-permission-warning --command-fd 0 --edit-key $key
    end
end

if command -q xdg-open
    function pacweb -a pkg -d "Open the Arch Linux package website"
        if test (count $argv) -eq 0; or string match -q -r '^(--help|-h)$' -- "$pkg"
            echo "pacweb - open the website of an ArchLinux package" >&2
            echo >&2
            echo "Usage: pacweb <package>" >&2
            return 1
        end

        set -l infos (env LANG=C pacman -Si "$pkg")
        if test -z "$infos"
            return
        end
        set -l repo (printf '%s\n' $infos | string match -r '^Repository.*' | string replace -r '^Repository\s*:\s*' '')
        set -l arch (printf '%s\n' $infos | string match -r '^Architecture.*' | string replace -r '^Architecture\s*:\s*' '')
        xdg-open "https://archlinux.org/packages/$repo/$arch/$pkg/" >/dev/null 2>&1
    end
end

function arch_upgrade -d "Full system upgrade after checking the Arch keyring"
    sudo pacman -Sy
    echo ":: Checking Arch Linux PGP Keyring..."
    set -l installedver (env LANG= sudo pacman -Qi archlinux-keyring | string match -r '^Version.*' | string replace -r '^Version\s*:\s*' '')
    set -l currentver (env LANG= sudo pacman -Si archlinux-keyring | string match -r '^Version.*' | string replace -r '^Version\s*:\s*' '')
    if test "$installedver" != "$currentver"
        echo " Arch Linux PGP Keyring is out of date."
        echo " Updating before full system upgrade."
        sudo pacman -S --needed --noconfirm archlinux-keyring
    else
        echo " Arch Linux PGP Keyring is up to date."
        echo " Proceeding with full system upgrade."
    end
    if command -q yay
        yay -Su
    else if command -q trizen
        trizen -Su
    else if command -q pacaur
        pacaur -Su
    else if command -q aura
        sudo aura -Su
    else
        sudo pacman -Su
    end
end

# --- AUR helpers ---
if command -q aura
    abbr -a auin 'sudo aura -S'
    abbr -a aurin 'sudo aura -A'
    abbr -a auclean 'sudo aura -Sc'
    abbr -a auclr 'sudo aura -Scc'
    abbr -a auins 'sudo aura -U'
    abbr -a auinsd 'sudo aura -S --asdeps'
    abbr -a aurinsd 'sudo aura -A --asdeps'
    abbr -a auloc 'aura -Qi'
    abbr -a aulocs 'aura -Qs'
    abbr -a aulst 'aura -Qe'
    abbr -a aumir 'sudo aura -Syy'
    abbr -a aurph 'sudo aura -Oj'
    abbr -a aure 'sudo aura -R'
    abbr -a aurem 'sudo aura -Rns'
    abbr -a aurep 'aura -Si'
    abbr -a aurrep 'aura -Ai'
    abbr -a aureps 'aura -As --both'
    abbr -a auras 'aura -As --both'
    abbr -a auupd 'sudo aura -Sy'
    abbr -a auupg 'sudo sh -c "aura -Syu && aura -Au"'
    abbr -a ausu 'sudo sh -c "aura -Syu --no-confirm && aura -Au --no-confirm"'

    # extra bonus specially for aura
    abbr -a auown 'aura -Qqo'
    abbr -a auls 'aura -Qql'

    function auownloc -d "Show info for packages owning the given files" -w aura
        aura -Qi (aura -Qqo $argv)
    end

    function auownls -d "List files for packages owning the given files" -w aura
        aura -Qql (aura -Qqo $argv)
    end
end

if command -q pacaur
    abbr -a pacclean 'pacaur -Sc'
    abbr -a pacclr 'pacaur -Scc'
    abbr -a paupg 'pacaur -Syu'
    abbr -a pasu 'pacaur -Syu --noconfirm'
    abbr -a pain 'pacaur -S'
    abbr -a pains 'pacaur -U'
    abbr -a pare 'pacaur -R'
    abbr -a parem 'pacaur -Rns'
    abbr -a parep 'pacaur -Si'
    abbr -a pareps 'pacaur -Ss'
    abbr -a paloc 'pacaur -Qi'
    abbr -a palocs 'pacaur -Qs'
    abbr -a palst 'pacaur -Qe'
    abbr -a paorph 'pacaur -Qtd'
    abbr -a painsd 'pacaur -S --asdeps'
    abbr -a pamir 'pacaur -Syy'
    abbr -a paupd 'pacaur -Sy'
end

if command -q trizen
    abbr -a trconf 'trizen -C'
    abbr -a trupg 'trizen -Syua'
    abbr -a trsu 'trizen -Syua --noconfirm'
    abbr -a trin 'trizen -S'
    abbr -a trclean 'trizen -Sc'
    abbr -a trclr 'trizen -Scc'
    abbr -a trins 'trizen -U'
    abbr -a trre 'trizen -R'
    abbr -a trrem 'trizen -Rns'
    abbr -a trrep 'trizen -Si'
    abbr -a trreps 'trizen -Ss'
    abbr -a trloc 'trizen -Qi'
    abbr -a trlocs 'trizen -Qs'
    abbr -a trlst 'trizen -Qe'
    abbr -a trorph 'trizen -Qtd'
    abbr -a trinsd 'trizen -S --asdeps'
    abbr -a trmir 'trizen -Syy'
    abbr -a trupd 'trizen -Sy'
end

if command -q yay
    abbr -a yaconf 'yay -Pg'
    abbr -a yaclean 'yay -Sc'
    abbr -a yaclr 'yay -Scc'
    abbr -a yaupg 'yay -Syu'
    abbr -a yasu 'yay -Syu --noconfirm'
    abbr -a yain 'yay -S'
    abbr -a yains 'yay -U'
    abbr -a yare 'yay -R'
    abbr -a yarem 'yay -Rns'
    abbr -a yarep 'yay -Si'
    abbr -a yareps 'yay -Ss'
    abbr -a yaloc 'yay -Qi'
    abbr -a yalocs 'yay -Qs'
    abbr -a yalst 'yay -Qe'
    abbr -a yaorph 'yay -Qtd'
    abbr -a yainsd 'yay -S --asdeps'
    abbr -a yamir 'yay -Syy'
    abbr -a yaupd 'yay -Sy'
end
