#!/usr/bin/env bash

# !!!!!!!!!! WORKING IN PROGRESS !!!!!!!!!!
# Copy and Paste to Run Manually

# ====================
# Install Homebrew
# ====================
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages
brew install git git-lfs git-delta gh gitui # git stuff
brew install wget aria2 # network stuff
brew install gunpg pinentry-mac # gun stuff
brew install zsh zellij starship zoxide bat btop eza fd ripgrep sd dust mole yazi # utils
brew install neovim helix # editors
brew install fennel fennel-ls luarocks # programming languages that mise not support
brew install sqlite mise gdb exercism # programming tools
brew install minicom arduino-cli # hardware develop
brew install jq jo yq asimov ffmpeg # tools

brew install --cask alacritty ghostty # terminal
brew install --cask alfred hammerspoon # launcher
brew install --cask appcleaner # cleaner
brew install --cask zed gram mactex # editors
brew install --cask font-lxgw-wenkai font-maple-mono-nf # fonts
brew install --cask orbstack utm # virtualization
brew install --cask iina # media
brew install --cask mac-mouse-fix betterdisplay shottr keycastr sf-symbols # tools
brew install --cask wireshark-app imhex
