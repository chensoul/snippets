# Installs GUI apps
# https://formulae.brew.sh/cask/

# Common stuff
RED="$(tput setaf 1)"
UNDERLINE="$(tput sgr 0 1)"
NOCOLOR="$(tput sgr0)"
function error() { echo -e "$UNDERLINE$RED$1$NOCOLOR\n"; }

# Check that Homebrew is installed
command -v brew >/dev/null 2>&1 || { error "Homebrew not installed: https://brew.sh/"; exit 1; }

echo "installing apps with --cask"

brew tap homebrew/cask-versions

brew install --cask 1password
brew install --cask google-chrome 
brew install --cask iterm2 
brew install --cask typora 
brew install --cask postman 
brew install --cask sogouinput
brew install --cask switchhosts 
brew install --cask tinypng4mac 
brew install --cask tableplus 
brew install --cask feishu 
brew install --cask wechat
brew install warp