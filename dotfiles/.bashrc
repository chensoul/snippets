# .bashrc

umask 022 

alias wget='wget --content-disposition'
alias hs='history'

alias htmllines='wc -l `find . -iname "*.html"` | sort -n'
alias phplines='wc -l `find . -iname "*.php"` | sort -n'
alias jslines='wc -l `find . -iname "*.js"` | sort -n'
alias sasslines='wc -l `find . -iname "*.scss"` | sort -n'

alias jsa='jekyll server --watch'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gpm="git push origin master"
alias gpg="git push origin gitcafe-pages"
alias gpl="git pull"

alias k9='kill -9'
alias tm='ps -ef | grep'
alias pp="ps axuf | pager"

alias ducks='du -cks *|sort -rn|head -11'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 10'
alias upgrade='apt-get update && apt-get upgrade && apt-get clean'
alias netlsn='lsof -i -P | grep LISTEN' # Show active network listeners

lwc() { ls "$@" | wc -l; }
lt() { ls -ltrsa "$@" | tail; }
psgrep() { ps axuf | grep -v grep | grep "$@" -i --color=auto; }
fname() { find . -iname "*$@*"; }
remove_lines_from() { grep -F -x -v -f $2 $1; }      #removes lines from $1 if they appear in $2
mcd() { mkdir $1 && cd $1; } 
ltree() { tree -C $* | less -R; }
authme() { ssh "$1" 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'< ~/.ssh/id_rsa.pub; }
sssh (){ ssh -t "$1" 'tmux attach || tmux new || screen -DR'; }

extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)
export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8
export M2_HOME=/usr/local/Cellar/maven30/3.0.5/libexec
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
export PATH=$JAVA_HOME/bin:$PATH

export GRADLE_HOME=/usr/local/Cellar/gradle/2.0
export PATH=$PATH:$GRADLE_HOME/bin

export DOCKER_HOST=tcp://192.168.59.103:2375
