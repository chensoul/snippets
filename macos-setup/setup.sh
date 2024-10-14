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

# Homebrew - Installing Softwares
echo "Installing Softwares"
brew bundle

# copy files
cp .aliases ~/
cp .bashrc ~/
cp .gitconfig ~/

# setting
scutil --set ComputerName "chensoul-mac"
systemsetup -settimezone "Asia/Shanghai" > /dev/null

# ssh
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo "Generating SSH keys"
  ssh-keygen -t rsa

  echo "Copied SSH key to clipboard - You can now add it to Github"
  pbcopy < ~/.ssh/id_rsa.pub
fi

# Complete
echo "Installation Complete"
