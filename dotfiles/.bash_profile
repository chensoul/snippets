export PATH="$PATH:/usr/local/bin/:/usr/local/:/usr/local/sbin"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{exports,aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;


[ -s "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

[ -s "~/.orbstack" ] && source ~/.orbstack/shell/init.bash 2>/dev/null || :

export GRADLE_HOME="/opt/homebrew/Cellar/gradle/8.7/libexec"
[ -s "$GRADLE_HOME" ]  && export PATH="$GRADLE_HOME/bin:$PATH"

export JAVA_HOME=`/usr/libexec/java_home -v 17`
export PATH="$JAVA_HOME/bin:$PATH"

export NVS_HOME="$HOME/.nvs"
[ -s "/opt/homebrew/Caskroom/nvs/1.7.1/nvs-1.7.1/nvs.sh" ] && . "/opt/homebrew/Caskroom/nvs/1.7.1/nvs-1.7.1/nvs.sh"


