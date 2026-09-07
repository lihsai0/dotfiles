# macos
#
# FUNCTIONS
#
#   ofd              open dirs (or $PWD) in Finder
#   showfiles        reveal hidden files in Finder
#   hidefiles        hide hidden files in Finder
#   tab              open $PWD in a new tab of the frontmost terminal
#   vsplit_tab       split the frontmost terminal tab vertically, run a command
#   split_tab        split the frontmost terminal tab horizontally, run a command
#   pfd              print the Finder front window's directory
#   pfs              print POSIX paths of the Finder selection, one per line
#   cdf              cd into the Finder front window's directory
#   pushdf           pushd into the Finder front window's directory
#   pxd              print the directory of Xcode's active workspace document
#   cdx              cd into the Xcode active workspace directory
#   quick-look       Quick Look the given files
#   man-preview      render man pages as PDF in Preview
#   vncviewer        open a vnc:// URL in the default handler
#   rmdsstore        remove .DS_Store files recursively (default: current dir)
#   freespace        erase purgeable disk space with zeros on a disk

if not contains "macos" $cogs
    return 0
end

if test (uname) != Darwin
    echo '[WARNING] Not in macOS system. Should remove "macos" from cogs list'
    return 1
end

# __macos_get_frontmost_app
# Name of the frontmost macOS application (System Events).
function __macos_get_frontmost_app
    osascript -e '
        tell application "System Events"
            name of first item of (every process whose frontmost is true)
        end tell
    ' 2>/dev/null
end

function ofd -d 'Open the given directories (or $PWD) in Finder'
    if test (count $argv) -eq 0
        open $PWD
    else
        open $argv
    end
end

function showfiles -d 'Show hidden files in Finder'
    defaults write com.apple.finder AppleShowAllFiles -bool true
    and killall Finder
end

function hidefiles -d 'Hide hidden files in Finder'
    defaults write com.apple.finder AppleShowAllFiles -bool false
    and killall Finder
end

function pfd -d 'Print the Finder front window\'s directory'
    osascript -e '
        tell application "Finder"
            return POSIX path of (insertion location as alias)
        end tell
    ' 2>/dev/null
end

function pfs -d 'Print POSIX paths of the current Finder selection, one per line'
    osascript -e '
        set output to ""
        tell application "Finder" to set the_selection to selection
        set item_count to count the_selection
        repeat with item_index from 1 to count the_selection
            if item_index is less than item_count then set the_delimiter to linefeed
            if item_index is item_count then set the_delimiter to ""
            set output to output & (POSIX path of (item item_index of the_selection as alias)) & the_delimiter
        end repeat
    ' 2>/dev/null
end

function cdf -d 'cd to the current Finder directory'
    set -l d (pfd)
    test -n "$d"; and cd "$d"
end

function pushdf -d 'Pushd to the current Finder directory'
    set -l d (pfd)
    test -n "$d"; and pushd "$d"
end

function pxd -d 'Print the directory containing Xcode\'s active workspace document'
    dirname (
        osascript -e '
            if application "Xcode" is running then
                tell application "Xcode"
                    return path of active workspace document
                end tell
            end if
        ' 2>/dev/null
    )
end

function cdx -d 'cd to the current Xcode project directory'
    set -l d (pxd)
    test -n "$d"; and cd "$d"
end

function quick-look -d 'Quick Look the given files'
    test (count $argv) -gt 0; or return 0
    qlmanage -p $argv >/dev/null 2>&1 &
end

function man-preview -d 'Render man pages as PDF in Preview'
    if test (count $argv) -eq 0
        echo "Usage: man-preview command1 [command2 ...]" >&2
        return 1
    end
    for page in (command man -w $argv)
        command mandoc -Tpdf $page | open -f -a Preview
    end
end

function vncviewer -d 'Open a VNC URL in the default handler'
    test (count $argv) -ge 1; or return 1
    open "vnc://$argv[1]"
end

function rmdsstore -d 'Remove .DS_Store files recursively (default: current directory)'
    set -l dirs $argv
    test (count $dirs) -gt 0; or set dirs .
    find $dirs -type f -name .DS_Store -delete
end

function freespace -d 'Erase purgeable disk space with zeros on the given disk'
    if test (count $argv) -lt 1
        echo "Usage: freespace <disk>"
        echo "Example: freespace /dev/disk1s1"
        echo
        echo "Possible disks:"
        df -h | awk 'NR == 1 || /^\/dev\/disk/'
        return 1
    end
    echo "Cleaning purgeable files from disk: $argv[1] ...."
    diskutil secureErase freespace 0 $argv[1]
end
