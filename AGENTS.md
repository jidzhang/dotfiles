# AGENTS.md —— 给 AI agent 的 dotfiles 维护指南

本文件是本仓库的**唯一操作说明**。任何 agent（Claude Code / Codex / ZCode 等）
在改动本仓库前必须先读本文件，并遵守其中的约定。目标：让三系统 dotfiles 的
维护成本尽可能低，一次改动只改一个地方。

---

## 1. 仓库宗旨（必须遵守）

1. **单一来源**：同一份配置只存一份。平台差异用 `has()` / 常量判断写在同一个
   文件里，**不新增** `vimrc-mac` / `_vimrc` 这种按系统复制的副本。
2. **零/轻依赖**：vim 配置不使用插件管理器，不依赖 YCM/neocomplete/NERDTree。
   需要的能力优先用 Vim 内置（netrw、omnifunc、`:Explore`）。
3. **可幂等安装**：安装脚本可反复执行，冲突文件自动备份为 `*.bak`。
4. **无秘密**：仓库里不得出现真实邮箱、token、主机名、内网地址。用占位符。

> 若用户要求"某个平台特殊化"，允许在 `mac/` 或 `linux/`（或 `windows/`）目录里
> 放**该平台独有的文件**，但**不得复制 common 里已有的内容**。

---

## 2. 目录结构（改动前先认清位置）

```
dotfiles/
├── AGENTS.md            # 本文件（AI 维护指南）
├── README.md            # 给人看的说明
├── install.sh           # macOS / Linux 安装脚本（幂等）
├── common/              # 三系统共用
│   ├── .vimrc           #   唯一的 vim 配置（零插件）
│   ├── .gitconfig       #   git 配置（姓名/邮箱用占位符！）
│   ├── .tmux.conf
│   ├── .editorconfig
│   ├── .gemrc
│   ├── .gitignore_global
│   ├── .spacemacs
│   └── vim/
│       └── .ycm_extra_conf.py   # YCM 可选模块用
├── mac/                 # macOS 独有文件（可为空/不存在）
├── linux/               # Linux 独有文件（可为空/不存在）
└── windows/             # Windows 独有
    ├── install.ps1      #   Windows 安装脚本（幂等）
    ├── .condarc .npmrc .minttyrc .wezterm.lua _vsvimrc
    ├── .claude/ .codex/ .config/        # AI 工具配置
    └── AppData/Roaming/{pip,Zed}/       # 按相对路径还原
```

**文件归属判断**：三系统都要用 → `common/`；只有某系统用 → 对应系统目录。

---

## 3. 常见维护任务

### 3.1 修改 vim 行为
- 只改 `common/.vimrc`。**不要**为某个系统单独建副本。
- 平台判断写法（照抄）：
  ```vim
  if has('win32')        " Windows
  if has('mac')          " macOS
  if has('unix')         " Linux/Unix
  if has('nvim')         " Neovim
  if has('gui_running')  " gVim/MacVim
  ```
- 想加补全/插件：**先问用户**。默认答案是不加。若确需，放进 `common/.vimrc`
  末尾"可选模块"区，用 `get(g:, 'dotfiles_enable_xxx', 0)` 开关控制，默认关闭。
- YCM 已降级为可选：用户不常用但保留。启用靠 `~/.vimrc.local` 里的
  `let g:dotfiles_enable_ycm = 1`，需自行编译 YCM。

### 3.2 新增一个配置文件
1. 判断归属目录（见 §2）。
2. 放进对应目录，文件名用真实的目标名（如 `common/.bashrc` 或
   `mac/.hushlogin`）。
3. 在对应安装脚本里加一行 `Install-One` / `install_file`。
4. 若是整目录（如某个 IDE 的一整套配置），在系统目录下建子目录，
   在脚本里用循环安装。
5. 更新 `README.md` 的文件表。

### 3.3 删除一个配置
- 从目录里删文件，同时删掉安装脚本中对应的那一行。
- 同步更新 `README.md` 文件表。不要留悬空引用。

### 3.4 安装 / 验证
```bash
# macOS / Linux
./install.sh --dry-run     # 先看会做什么
./install.sh               # 真正安装
# Windows (PowerShell)
.\windows\install.ps1 -DryRun
.\windows\install.ps1
```
验证 vim 配置语法（无需真的启动 GUI）：
```bash
vim -u common/.vimrc -es -c 'q' </dev/null && echo OK
# 或 Neovim
nvim --headless -u common/.vimrc -c 'qa!' 2>&1
```

---

## 4. 编码纪律（重要，本仓库踩过坑）

- **所有文本文件统一 UTF-8（无 BOM）+ LF 换行**。`.gitattributes` 已强制。
- 历史文件曾是 CRLF/GBK：改动时若发现旧编码，顺手统一为 UTF-8+LF 再提交。
- Windows 批处理若确需 CRLF，在 `.gitattributes` 里单独声明，不要全局改。
- 用 Write 工具新建文件默认就是 UTF-8+LF，可直接用。
- 提交前用 `git diff --stat` 检查是否意外整文件重写（换行符被改的征兆）。

---

## 5. 提交纪律

- 提交信息用简短中文（与历史一致），一句话说清改了什么。
  例：`精简 vim 配置为单文件`、`统一三系统目录结构`。
- 一次提交只做一件事；结构性重构与内容微调分开提交。
- **不要**替用户 `push`，除非用户明确要求。提交前先 `git status` 确认范围。
- 破坏性操作（删文件、改历史、强推）必须先与用户确认。

---

## 6. 与用户协作的偏好（来自历史教训）

- 回复简洁，结论先行，不复述任务、不写过程解说。
- 不做超出请求范围的改动；不为小特性做大重构。
- 遇到"要不要加插件/换工具链"这类取舍，**先问**，不要擅自引入依赖。

---

## 7. 快速自检清单（改完对照）

- [ ] 没有新增按系统复制的重复文件
- [ ] 新增/删除的文件与安装脚本、README 表格一致
- [ ] 文件是 UTF-8 无 BOM + LF
- [ ] vim 配置能 `vim -es -c 'q'` 无报错载入
- [ ] 没有引入密钥/真实邮箱/内网地址
- [ ] 提交信息简短清晰，未擅自 push
