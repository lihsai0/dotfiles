#!/bin/sh

# !!!!!!!!!! WORKING IN PROGRESS !!!!!!!!!!

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Alternatively, the installer is also mirrored outside GitHub.
# You will need this, if you are behind a firewall blocking GitHub.
# sh -c "$(curl -fsSL https://install.ohmyz.sh/)"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages
brew install git git-lfs git-delta gh gitui # git stuff
brew install wget aria2 # network stuff
brew install gunpg pinentry-mac # gun stuff
brew install zoxide bat btop eza fd ripgrep sd zellij dust # utils
brew install neovim helix # editors
brew install rustup mise sqlite # develop languages
brew install minicom arduino-cli # hardware develop
brew install jq yq asimov ffmpeg awscli

brew install --cask iterm2 alacritty # terminal
brew install --cask alfred hammerspoon # launcher
brew install --cask appcleaner # cleaner
brew install --cask zed mactex # editors
brew install --cask font-lxgw-wenkai font-maple-mono-nf # fonts
brew install --cask orbstack utm # virtualization
brew install --cask iina # media
brew install --cask mac-mouse-fix betterdisplay shottr keycastr # tools
brew install --cask surge wireshark-app imhex
