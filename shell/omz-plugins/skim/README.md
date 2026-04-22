## Usage

```shell
ln -sf ${PROJECT}/shell/omz-plugins/skim ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/skim

omz reload
```

## Options

All these settings should go in your zshrc file, before Oh My Zsh is sourced.

### `SKIM_BASE`

```
SKIM_BASE
```

### `DISABLE_SKIM_AUTO_COMPLETION`

Set whether to load skim autocompletion, default is:

```
DISABLE_SKIM_AUTO_COMPLETION="true"
```

### `DISABLE_SKIM_KEY_BINDINGS`

Set whether to load skim key bindings like <kbd>Ctrl-R</kbd>, <kbd>Ctrl-T</kbd>, default is:

```
DISABLE_SKIM_KEY_BINDINGS="true"
```

## Thanks

- [fzf plugin in Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf)
