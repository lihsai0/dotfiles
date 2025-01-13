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
brew install git git-lfs gh gitui # git stuff
brew install wget # network stuff
brew install gunpg pinentry-mac # gun stuff
brew install bat eza fd ripgrep zellij # utils
brew install neovim # editors
brew install rustup mise # develop languages

brew install --cask iterm2 alacritty # terminal
brew install --cask alfred # launcher
brew install --cask appcleaner # cleaner
brew install --cask zed # editors
brew install --cask font-fira-code-nerd-font # fonts
brew install --cask orbstack utm # virtualization
brew install --cask iina # media
brew install --cask betterdisplay # tools
