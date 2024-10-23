# inspired by chris sev @chris__sev https://gist.github.com/chris-sev/45a92f4356eaf4d68519d396ef42dd99

#!/bin/bash
set -euo pipefail

# Display message 'Setting up your Mac...'
echo "Setting up your Mac..."
sudo -v

# Homebrew - Installation
if [[ $(command -v brew) == "" ]]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Updating Homebrew"
    brew update
fi

# Homebrew - Installing Softwares
echo "Installing Softwares"
brew bundle

# copy files
files=".gitconfig .aliases .bashrc functions.sh"
# create symlinks (will overwrite old dotfiles)
for file in ${files}; do
    echo "Creating symlink to $file in home directory."
    #ln -sf ${dotfiledir}/${file} ${homedir}/${file}
done

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
