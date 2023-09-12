# dotfiles

## 安装 dotfiles

```bash
git clone https://github.com/chensoul/snippets.git && cd snippets/dotfiles && source bootstrap.sh
```

## Maocs 配置

```bash
./.macos
```

## 安装软件

```bash
sh install.sh
```

## 额外设置

~/.extra

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="chensoul"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="chensoul.eth@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```