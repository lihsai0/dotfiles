## Usage

```sh
git clone https://github.com/lihsai0/dotfiles.git
cd dotfiles

# Read homebrew/install_tools.sh manually and install tools you need
cat homebrew/install_tools.sh

# install Oh My ZSH
./zsh/install_omz.sh

# link configs
./docs/install/ln_files.sh
```

## Migration Tips

Find broken links.

```sh
fd -IH --type symlink ".*" ~ -E Library -E Applications -x sh -c '
    target=$(readlink "$1")
    if [ -e "$1" ]; then
        echo "$1 -> $target"
    else
        echo "$1 -> $target (broken)"
    fi
' _ {} | rg "dotfiles"
```

Or, delete all links then re-link them:

```sh
./docs/install/rm_links.sh

```
