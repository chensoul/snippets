#!/usr/bin/env bash

echo "Hello $(whoami)! Let's get you set up."

echo "installing homebrew"
# install homebrew https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/chensoul/.zshrc

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

echo "brew installing font"
brew tap homebrew/cask-fonts
brew install font-fantasque-sans-mono-nerd-font
# 安装「霞鹜文楷」字体
brew install font-lxgw-wenkai

echo "brew installing useful binaries"
# hub: a github-specific version of git
# ripgrep: rg is faster than alternatives
# ffmpeg: eventually I'll need this for something
# tree: really handy for listing out directories in text
# bat: A cat(1) clone with syntax highlighting and Git integration.
# delta: A fantastic diff tool
brew install git hub ripgrep ffmpeg tree tmux bat wget vim hugo maven go python3

echo "brew installing apps with --cask"
brew install --cask google-chrome brave-browser \
1password telegram spotify iterm2 typora obsidian postman switchhosts \
tinypng4mac picgo raycast netnewswire xmind intellij-idea webstorm

# Remove outdated versions from the cellar.
brew cleanup
