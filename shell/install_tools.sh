#!/bin/sh

# !!!!!!!!!! WORKING IN PROGRESS !!!!!!!!!!
# Copy and Paste to Run Manually

# ====================
# Install Oh My Zsh
# ====================
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Alternatively, the installer is also mirrored outside GitHub.
# You will need this, if you are behind a firewall blocking GitHub.
# sh -c "$(curl -fsSL https://install.ohmyz.sh/)"

# Install omz plugin
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ====================
# Install Homebrew
# ====================
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages
brew install git git-lfs git-delta gh gitui # git stuff
brew install wget aria2 # network stuff
brew install gunpg pinentry-mac # gun stuff
brew install zsh zellij starship zoxide bat btop eza fd ripgrep sd dust # utils
brew install neovim helix # editors
brew install gdb rustup mise sqlite lua fennel minimal-racket # develop languages
brew install minicom arduino-cli # hardware develop
brew install jq jo yq asimov ffmpeg awscli # tools

brew install --cask iterm2 alacritty # terminal
brew install --cask alfred hammerspoon # launcher
brew install --cask appcleaner # cleaner
brew install --cask zed mactex # editors
brew install --cask font-lxgw-wenkai font-maple-mono-nf # fonts
brew install --cask orbstack utm # virtualization
brew install --cask iina # media
brew install --cask mac-mouse-fix betterdisplay shottr keycastr # tools
brew install --cask surge wireshark-app imhex

# ====================
# Install Rust
# ====================
rustup install stable

# ====================
# Install mise packages
# ====================
# Install Go Stack
mise install go buf protoc protoc-gen-go protoc-gen-go-grpc

# Install Node.js Stack
mise install node pnpm

# Install Python Stack
MISE_PYTHON_COMPILE=0
MISE_PYTHON_PRECOMPILED_FLAVOR="freethreaded+pgo+lto-full"
mise install 'python[patch_sysconfig=false]@3'
mise install uv
mise sync python --uv

# Install ESP32
