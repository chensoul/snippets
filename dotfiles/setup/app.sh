# Installs GUI apps
# https://formulae.brew.sh/cask/


# Install XCode command line tools, and accept its license
xcode-select --install
xcodebuild -license

# Check that Homebrew is installed
command -v brew >/dev/null 2>&1 || { error "Homebrew not installed: https://brew.sh/"; exit 1; }

echo "installing apps with --cask"
brew tap homebrew/cask-versions
brew install --cask visual-studio-code
brew install --cask intellij-idea

# soft app
brew install baidunetdisk 
brew install 1password
brew install google-chrome 
brew install typora 
brew install sogouinput
brew install switchhosts 
brew install tinypng4mac 
brew install tableplus 
brew install feishu 
brew install wechat
brew install warp

# cli command
brew install bash
brew install bash-completion
brew install ffmpeg
brew install jq
brew install ssh-copy-id
brew install tree
brew install vim
brew install wget
brew install gpg

# dev tools
brew tap spring-io/tap && brew install spring-boot
brew install zulu8 zulu17 zulu21
brew install maven
brew install gradle
brew install orbstack
brew install node
brew install nvs
brew install go 
brew install hugo 
brew install python3

brew cleanup