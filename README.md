# dotfiles

跨 Windows / macOS / Linux 的个人配置仓库。

设计目标：**同一份配置只存一份**，平台差异在文件内部用 `has()` 判断，
不再为每个系统维护一份副本。安装脚本幂等，可反复执行。

如果要用 AI agent 维护本仓库，请让它先读 [AGENTS.md](AGENTS.md)。

## 目录结构

```
dotfiles/
├── AGENTS.md            # 给 AI agent 的维护指南（唯一操作说明）
├── install.sh           # macOS / Linux 安装脚本
├── common/              # 三系统共用
│   ├── .vimrc           #   唯一的 vim 配置（零插件，YCM 可选）
│   ├── .gitconfig       #   占位身份，安装脚本不会覆盖你本机的真实配置
│   ├── .tmux.conf
│   ├── .editorconfig
│   ├── .gemrc
│   ├── .gitignore_global
│   ├── .spacemacs
│   └── vim/.ycm_extra_conf.py
└── windows/             # Windows 独有（mac/ linux/ 按需添加）
    ├── install.ps1
    ├── .condarc .npmrc .minttyrc .wezterm.lua _vsvimrc
    ├── .claude/ .codex/ .config/
    └── AppData/Roaming/{pip,Zed}/
```

## 安装

macOS / Linux（先 `--dry-run` 预演）：

```bash
./install.sh --dry-run
./install.sh            # 默认符号链接；加 --copy 则复制
```

Windows（PowerShell）：

```powershell
.\windows\install.ps1 -DryRun
.\windows\install.ps1             # 默认符号链接；加 -Copy 则复制
```

脚本幂等：已就位会跳过，冲突文件备份为 `*.bak`。
符号链接在 Windows 需开启"开发者模式"或以管理员运行，否则自动降级为复制。

**注意**：`common/.gitconfig` 里是占位身份，安装脚本**不会覆盖**
你本机已有的 `~/.gitconfig`；新机器首次安装后请手动填入真实姓名邮箱。

## Vim 配置说明

`common/.vimrc` 是唯一的 vim 配置，适用于 Vim 8+ / Neovim，三系统通用：

- **零插件**。文件浏览用内置 netrw（`<Space>e`），补全用内置 omnifunc。
- **Leader 为空格**。常用：`<Space>w` 保存、`<Space>feR` 重载配置、
  `<Space>e` 文件树、`<Space>d/n/p` 切 buffer。
- **平台差异**内联判断：gVim 沿用 Windows 按键、macOS 开启 `macmeta`、
  终端自动切换光标形状。
- **可选 YCM**：默认关闭。不常用了但保留能力——在 `~/.vimrc.local` 写
  `let g:dotfiles_enable_ycm = 1` 开启，需自行编译 YCM 并把
  `.ycm_extra_conf.py` 放到 `~/.vim/`。
- 个人本地覆盖写 `~/.vimrc.local`（不进版本库）。

## 编码规范

所有文本文件为 **UTF-8（无 BOM）+ LF**，由 [.gitattributes](.gitattributes) 强制。
例外：`windows/install.ps1` 必须是 **UTF-8 with BOM + CRLF**
（PowerShell 5.1 会把无 BOM 的 UTF-8 当 ANSI 读，中文注释会导致语法错位）。

## 从旧版迁移说明

过去仓库里有 9 份近乎重复的 vim 配置（`_vimrc`、`vimrc-mac`、
`vim-mini.vimrc`、`vim-ycm.vimrc` 等）和独立的 YCM/补全配置，已全部合并删除，
统一到 `common/.vimrc`。若你本地仍指向旧文件，重新跑一次安装脚本即可。
