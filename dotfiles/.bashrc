# .bashrc

umask 022 

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias la='ls -A'
alias dusmax="sudo du -ah --max-depth 1 --exclude='proc' | sort -rh | awk '(\$1 > 0){print \$1\" \"\$2}' | grep -v [0-9]K"
alias wget='wget --no-check-certificate'

alias hsg='history |grep '
alias tailf='tail -f'

alias ducks='du -cks *|sort -rn|head -11'
alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 10'


# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


# Log the history commands with time stamps
export HISTFILESIZE="10000000"
export HISTSIZE="10000"
export PROMPT_COMMAND="history -a"
export HISTTIMEFORMAT="%Y-%m-%d_%H:%M:%S "
export HISTIGNORE="history*:pwd:ls:ll:la:clear"
export HISTCONTROL="ignoredups"


export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8
export M2_HOME=/usr/local/Cellar/maven30/3.0.5/libexec
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
export PATH=/usr/local/sbin:$JAVA_HOME/bin:$M2_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar

export GRADLE_HOME=/usr/local/Cellar/gradle/2.0
export PATH=$PATH:$GRADLE_HOME/bin

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
