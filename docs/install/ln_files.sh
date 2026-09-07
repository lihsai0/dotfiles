#!/usr/bin/env bash

read -p "Use ZSH(z, default) or Fish(f)? " -n 1 -r
echo
case ${REPLY:-z} in
  [Ff])
    ln -sf {"$(pwd)","$HOME/.config"}/fish
    ;;
  [Zz])
    ln -sf $(pwd)/dotfiles/zsh/zshrc $HOME/.zshrc
    ln -sf {"$(pwd)/zsh/omz-plugins","${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"}/pnpm
    ln -sf {"$(pwd)zsh/functions","${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"}/yazi.zsh
    ;;
esac

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
