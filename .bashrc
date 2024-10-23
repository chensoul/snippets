# Paths updates
export PATH=$PATH:~/.local/bin

# Show git branch if exists
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


source ~/.aliases


/usr/libexec/java_home -v 21 --exec java -version 2>/dev/null