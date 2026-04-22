## Usage

```shell
ln -sf ${PROJECT}/shell/omz-plugins/pnpm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pnpm

omz reload
```

## FAQ

Q: How to update the update script?

A: Just run this:
```shell
rm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pnpm/pnpm_completion.zsh
omz reload
```
