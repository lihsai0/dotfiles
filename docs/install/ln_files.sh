#!/usr/bin/env bash

ln -sf $(pwd)/dotfiles/zsh/zshrc /Users/lihs/.zshrc
ln -sf {"$(pwd)/zsh/omz-plugins","${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"}/pnpm
ln -sf {"$(pwd)zsh/functions","${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"}/yazi.zsh

ln -sf $(pwd)/git/config_workspaces $HOME/Workspaces/.gitconfig
ln -sf {"$(pwd)","$HOME/.config"}/git
ln -sf {"$(pwd)","$HOME/.config"}/starship
ln -sf {"$(pwd)","$HOME/.config"}/alacritty
ln -sf {"$(pwd)","$HOME/.config"}/ghostty
ln -sf {"$(pwd)","$HOME/.config"}/zellij
ln -sf {"$(pwd)","$HOME/.config"}/btop
ln -sf {"$(pwd)","$HOME/.config"}/helix
ln -sf {"$(pwd)","$HOME/.config"}/zed
# ln -sf {"$(pwd)","$HOME/.config"}/nvim
# ln -sf {"$(pwd)","$HOME"}/.hammerspoon
