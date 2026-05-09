# home-files

Windows 开发环境配置文件（dotfiles）仓库，用于备份和同步各开发工具的配置。

## 目录结构

```
home-files/
├── .claude/                    # Claude Code 技能和配置
│   ├── CLAUDE.md               #   Claude Code 项目指令
│   ├── settings.json           #   Claude Code 设置
│   └── skills/                 #   自定义技能集
│       ├── debug-issue/        #     调试问题
│       ├── explore-codebase/   #     代码库探索
│       ├── msvc-cl/            #     MSVC 编译
│       ├── notify-email/       #     邮件通知
│       ├── pptx-report/        #     PPT 报告生成
│       ├── refactor-safely/    #     安全重构
│       ├── review-changes/     #     代码审查
│       └── save-to-yinxiang/   #     保存到印象笔记
├── .codex/                     # Codex 配置
│   ├── config.toml             #   Codex 主配置（GLM 模型）
│   └── models.json             #   模型目录
├── .config/
│   └── opencode/               # OpenCode 配置
│       ├── opencode.json       #   OpenCode 主配置
│       └── oh-my-openagent.json
├── AppData/
│   └── Roaming/
│       ├── pip/pip.ini         # pip 配置（清华镜像源）
│       └── Zed/settings.json   # Zed 编辑器配置
├── .condarc                    # Conda 配置（清华镜像源）
├── .gitignore                  # Git 忽略规则
├── .minttyrc                   # MinTTY 终端配置
├── .npmrc                      # npm 配置（腾讯镜像源）
├── .vimrc                      # Vim 编辑器配置
└── .wezterm.lua                # WezTerm 终端配置
```

## 配置说明

### 终端

| 文件 | 工具 | 说明 |
|------|------|------|
| `.wezterm.lua` | WezTerm | Tmux 风格快捷键（Leader=Ctrl+B），Dracula 主题，JetBrains Mono 字体，半透明窗口 |
| `.minttyrc` | MinTTY (Git Bash) | JetBrains Mono 字体，windows10 主题，块状光标，高透明度 |

### 编辑器

| 文件 | 工具 | 说明 |
|------|------|------|
| `.vimrc` | Vim | Space 作为 Leader 键，evening 配色，`jj` 映射为 ESC |
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

## 使用方法

将配置文件复制或软链接到对应的用户目录（`%USERPROFILE%`）即可生效：

```powershell
# 示例：软链接 .vimrc
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.vimrc" -Target "<仓库路径>\.vimrc"

# 示例：软链接 .wezterm.lua
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "<仓库路径>\.wezterm.lua"

# 示例：软链接 .condarc
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.condarc" -Target "<仓库路径>\.condarc"
```

> **注意**：需要以管理员权限运行 PowerShell 来创建符号链接，或者开启开发者模式。

## 开发环境

- **操作系统**：Windows
- **编译器**：MSVC (Visual Studio)
- **Python**：3.13
- **编码规范**：UTF-8（无 BOM），MSVC 编译加 `-utf-8` 参数
- **C++ 标准**：最低 C++11

## License

个人配置文件，仅供参考。