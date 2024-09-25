# inspired by chris sev @chris__sev https://gist.github.com/chris-sev/45a92f4356eaf4d68519d396ef42dd99

#!/bin/bash
set -euo pipefail

# Display message 'Setting up your Mac...'
echo "Setting up your Mac..."
sudo -v

# Homebrew - Installation
echo "Installing Homebrew"

if test ! $(which brew); then
  export HOMEBREW_CORE_GIT_REMOTE=https://mirrors.ustc.edu.cn/homebrew-core.git
  /bin/bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/ineo6/homebrew-install/install.sh)"
fi

# Install Homebrew Packages
cd ~
echo "Installing Homebrew packages"

homebrew_packages=(
    "1password"
    "baidunetdisk"
    "feishu"
    "ffmpeg"
    "go"
    "google-chrome"
    "gradle"
    "gpg"
    "hugo"
    "jq"
    "orbstack"
    "switchhosts"
    "ssh-copy-id"
    "tree"
    "typora"
    "maven"
    "nvs"
    "wget"
    "wechat"
)

for homebrew_package in "${homebrew_packages[@]}"; do
  brew install "$homebrew_package"
done

# Install Casks
echo "Installing Homebrew cask packages"

homebrew_cask_packages=(
  "arc"
  "intellij-idea"
  "setapp"
  "visual-studio-code"
  "warp"
  "zulu@8"
  "zulu@21"
)

for homebrew_cask_package in "${homebrew_cask_packages[@]}"; do
  brew install --cask "$homebrew_cask_package"
done

brew cleanup

# apps in setapp (check your setapps favorites list)
# bartender
# cleanshot
# cleanmymac
# dato
# numi
# session
# superwhisper
# swish
# yoink
# tableplus
# xsnapper


touch "$HOME/.zshrc"

echo "/usr/libexec/java_home -v 21 --exec java -version 2>/dev/null" >> "$HOME/.zshrc"

# aliases	
cp .aliases ~/.aliases
echo ". ~/.aliases" >> "$HOME/.zshrc"

# setting
scutil --set ComputerName "chensoul-mac"
systemsetup -settimezone "Asia/Shanghai" > /dev/null

# configure git
git config --global user.name "chensoul"
git config --global user.email "ichensoul@gmail.com"

# Generate SSH key
echo "Generating SSH keys"
ssh-keygen -t rsa

echo "Copied SSH key to clipboard - You can now add it to Github"
pbcopy < ~/.ssh/id_rsa.pub

# Complete
echo "Installation Complete"
