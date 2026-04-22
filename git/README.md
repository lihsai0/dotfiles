Dependencies

- [git-lfs](https://github.com/git-lfs/git-lfs)
- [delta](https://github.com/dandavison/delta)


```
cp config_tpl config
# change config_tpl placeholders to real values.
vim config

ln -sf $(realpath .) ~/.config/git
ln -sf $(realpath config_workspaces) ~/Workspaces/.gitconfig
```
