# Windows 配置

本目录是 dotfiles 仓库的 Windows 专属部分。通用配置在 [`../common/`](../common/)，
整体说明见 [`../README.md`](../README.md)，AI 维护约定见 [`../AGENTS.md`](../AGENTS.md)。

安装：`..\windows\install.ps1`（幂等，冲突文件备份为 `*.bak`）。
符号链接需开启开发者模式或以管理员运行，否则自动降级为复制。

## 目录内容

```
windows/
├── install.ps1                         # Windows 安装脚本
├── .condarc                            # Conda（清华 TUNA 镜像）
├── .npmrc                              # npm（腾讯云镜像）
├── .minttyrc                           # MinTTY (Git Bash) 终端
├── .wezterm.lua                        # WezTerm 终端
├── _vsvimrc                            # Visual Studio VsVim 配置
├── .claude/                            # Claude Code 配置 + 自定义技能
│   ├── CLAUDE.md
│   ├── settings.json
│   └── skills/{debug-issue,explore-codebase,msvc-cl,notify-email,
│               pptx-report,refactor-safely,review-changes,save-to-yinxiang}
├── .codex/{config.toml,models.json}    # Codex 配置（GLM 模型）
├── .config/opencode/                   # OpenCode 配置
└── AppData/Roaming/
    ├── pip/pip.ini                     # pip（清华 TUNA 镜像）
    └── Zed/settings.json               # Zed 编辑器
```

> 注意：vim 配置已统一到 [`../common/.vimrc`](../common/.vimrc)，本目录不再单独存放。

## 配置说明

### 终端

| 文件 | 工具 | 说明 |
|------|------|------|
| `.wezterm.lua` | WezTerm | Tmux 风格快捷键（Leader=Ctrl+B），Dracula 主题，JetBrains Mono 字体，半透明窗口 |
| `.minttyrc` | MinTTY (Git Bash) | JetBrains Mono 字体，windows10 主题，块状光标，高透明度 |

### 编辑器

| 文件 | 工具 | 说明 |
|------|------|------|
| `_vsvimrc` | VsVim (Visual Studio) | Space 作为 Leader，VS 功能集成（`gd`/`gr` 等） |
| `AppData/Roaming/Zed/settings.json` | Zed | One Light 主题，完整 IDE 配置，关闭 AI 功能 |

### 包管理器镜像源

| 文件 | 工具 | 镜像源 |
|------|------|--------|
| `.condarc` | Conda | 清华大学 TUNA 镜像 |
| `.npmrc` | npm | 腾讯云镜像 |
| `AppData/Roaming/pip/pip.ini` | pip | 清华大学 TUNA 镜像 |

### AI 编程助手

| 文件 | 工具 | 说明 |
|------|------|------|
| `.codex/config.toml` | Codex | GLM-5.1 模型（智谱 AI） |
| `.claude/CLAUDE.md` | Claude Code | Windows + MSVC 开发环境指令 |
| `.config/opencode/opencode.json` | OpenCode | GLM-5.1 模型 |

## 开发环境约定

- **编译器**：MSVC (Visual Studio)
- **Python**：3.13
- **源码编码**：UTF-8（无 BOM）；MSVC 编译加 `/utf-8`
- **PowerShell 脚本**：必须 UTF-8 **with BOM**（PowerShell 5.1 会把无 BOM
  的 UTF-8 当 ANSI 读，中文注释会导致语法错位），换行 CRLF
- **C++ 标准**：最低 C++11
