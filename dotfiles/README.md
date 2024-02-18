# dotfiles

## 克隆仓库

```bash
git clone https://github.com/chensoul/snippets.git && cd snippets/dotfiles
```

## 应用

```bash
sh setup/brew.sh
sh setup/app.sh
sh setup/stuff.sh
sh setup/osx.sh
```

## 安装 dotfiles

```bash
source bootstrap.sh
```

## 额外设置

添加 ~/.extra，设置 gihub 用户和邮箱：

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="chensoul"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="ichensoul@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```
