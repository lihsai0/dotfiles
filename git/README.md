Dependencies

- [git-lfs](https://github.com/git-lfs/git-lfs)
- [delta](https://github.com/dandavison/delta)

Files

- `config` 通用配置（入库），链接到 `~/.config/git/config` 后立即生效
- `config_local_tpl` 身份信息模板；`cp config_local_tpl config.local` 后填写 name / email / signingkey
- `config.local` 个人身份（不入库，见 .gitignore），由 `config` 的 `[include]` 加载
- `config_workspaces` 个人多身份配置，`~/Workspaces` 存在时由安装脚本链接为 `~/Workspaces/.gitconfig`

链接由 `docs/install/ln_files.sh` 的 `git` 模块统一完成，无需手动 ln。
