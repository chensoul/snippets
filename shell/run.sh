
rm -rf /home/june/.ivy2/cache /home/june/.m2/repository
mkdir -p /home/june/.ivy2 /home/june/.m2
ln -s /chan/opt/repository/cache/  /home/june/.ivy2/cache
ln -s /chan/opt/repository/m2/  /home/june/.m2/repository

ln -s /chan/download  /hone/june/download
ln -s /chan/tmp  /hone/june/tmp
ln -s /chan/work  /hone/june/work
ln -s /chan/opt  /hone/june/opt
ln -s /chan/workspace  /hone/june/workspace
ln -s /chan/program  /hone/june/program

echo '
XDG_DESKTOP_DIR="$HOME/desktop"
XDG_DOWNLOAD_DIR="$HOME/download"
XDG_TEMPLATES_DIR="$HOME/tmp"
XDG_PUBLICSHARE_DIR="$HOME/public"
XDG_DOCUMENTS_DIR="$HOME/work"
XDG_MUSIC_DIR="$HOME/opt"
XDG_PICTURES_DIR="$HOME/workspace"
XDG_VIDEOS_DIR="$HOME/program"
' > /home/june/.config/user-dirs.dirs
