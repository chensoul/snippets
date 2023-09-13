#!/usr/bin/env bash

echo "Hello $(whoami)! Let's get you set up."

echo "installing homebrew"
# install homebrew https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git -C "$(brew --repo)" remote set-url origin https://mirrors.cloud.tencent.com/homebrew/brew.git

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile

source ~/.bash_profile

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install a modern version of Bash.
brew install bash
brew install bash-completion

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install font tools.
# brew tap bramstein/webfonttools
# brew install sfnt2woff
# brew install sfnt2woff-zopfli
# brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
# brew install aircrack-ng
# brew install bfg
# brew install binutils
# brew install binwalk
# brew install cifer
# brew install dex2jar
# brew install dns2tcp
# brew install fcrackzip
# brew install foremost
# brew install hashpump
# brew install hydra
# brew install john
# brew install knock
# brew install netpbm
# brew install nmap
# brew install pngcheck
# brew install socat
# brew install sqlmap
# brew install tcpflow
# brew install tcpreplay
# brew install tcptrace
# brew install ucspi-tcp # `tcpserver` etc.
# brew install xpdf
# brew install xz

# Install other useful binaries.
brew install ack
brew install git
brew install git-lfs
brew install gs
brew install grep
brew install ffmpeg
brew install imagemagick
brew install lua
brew install lynx
brew install openssh
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install screen
brew install tree
brew install vbindiff
brew install vim
brew install wget
brew install zopfli

# Install dev tools
brew install go 
brew install hugo 
brew install orbstack
brew install python3
brew install visual-studio-code 

echo "installing apps with --cask"
brew install --cask google-chrome 
brew install --cask 1password
brew install --cask iterm2 
brew install --cask typora 
brew install --cask postman 
brew install --cask sogouinput
brew install --cask switchhosts 
brew install --cask tinypng4mac 
brew install --cask tableplus 
brew install --cask feishu 
brew install --cask wechat


# Remove outdated versions from the cellar.
brew cleanup


echo "install nvs"
export NVS_HOME="$HOME/.nvs"
git clone https://github.com/jasongin/nvs --depth=1 "$NVS_HOME"
. "$NVS_HOME/nvs.sh" install
nvs remote node https://npm.taobao.org/mirrors/node/


echo "install sdkman"
curl -s "https://get.sdkman.io" | bash

echo "install java、maven"
sdk install java 8.0.382-zulu
sdk install maven
