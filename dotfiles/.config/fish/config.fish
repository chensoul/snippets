set pure_symbol_prompt "\$"
set pure_color_virtualenv "magenta"

# Basic
set -x SHELL fish
set -x TERM screen-256color
set -x EDITOR vim
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Go
set -x GOPATH $HOME/workspace/goProjects
set -x GO111MODULE on

# python
set -x PYTHON_HOME /opt/homebrew/opt/python@3.11
set -x PIP_REQUIRE_VIRTUALENV true
set -x PIP_DOWNLOAD_CACHE $HOME/.pip/cache
set -x PIPENV_IGNORE_VIRTUALENVS 1
set -x PIPENV_VERBOSITY -1

# java
set -x SDKMAN_DIR $HOME/.sdkman
set -x JAVA_HOME ~/.sdkman/candidates/java/8.0.362-zulu/zulu-8.jdk/Contents/Home

# $PATH
set -e fish_user_paths
set -gx fish_user_paths \
        $GOPATH/bin \
        $HOME/.cargo/bin \
        /opt/homebrew/bin \
        /usr/local/sbin \
        /usr/local/bin \
        /usr/sbin \
        /usr/bin \
        /sbin \
        /bin \
        $fish_user_paths

set -x XDG_CONFIG_HOME $HOME/.config


# Alias
alias g "git"
alias gst "git status"
alias gc "git commit -ev"
alias python python3
alias pip pip3
