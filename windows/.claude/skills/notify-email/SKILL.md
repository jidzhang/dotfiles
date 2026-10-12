---
name: notify-email
description: 邮件通知工具。当用户要求发送邮件通知、报告任务进展或完成情况时使用。触发词：发邮件、邮件通知、发通知、notify、email、发送报告、完成后通知我。用户可能在对话中说"任务完成后给我发邮件"或"发个通知邮件"。
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob, Edit
---

# 邮件通知 Skill

当用户要求发送邮件通知时，调用 Python 脚本发送邮件。

## 环境变量（必须预先配置）

| 变量 | 说明 | 示例 |
|------|------|------|
| `EMAIL_ACCOUNT` | 发件人邮箱地址 | `user@gmail.com` |
| `EMAIL_PASSWORD` | 发件人授权码（非登录密码） | Gmail 应用专用密码 |
| `MY_EMAIL` | 收件人邮箱地址 | `me@example.com` |
| `SMTP_SERVER` | SMTP 服务器（可选，自动推断） | `smtp.gmail.com` |
| `SMTP_PORT` | SMTP 端口（可选，默认 465） | `465` |

### 常见邮箱授权码获取

| 邮箱 | 获取方式 |
|------|---------|
| Gmail | Google 账号 → 安全性 → 两步验证 → 应用专用密码 |
| QQ 邮箱 | 设置 → 账户 → POP3/SMTP 服务 → 生成授权码 |
| 163 邮箱 | 设置 → POP3/SMTP/IMAP → 开启并设置授权密码 |
| Outlook | Microsoft 账号安全 → 高级安全选项 → 应用密码 |

## 脚本位置

```
~/.claude/skills/notify-email/scripts/send_email.py
```

## 调用方式

### 基本用法

```bash
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --subject "任务完成" \
  --body "XXX 任务已完成，请查看。" \
  --type complete
```

### 参数说明

| 参数 | 必需 | 说明 |
|------|------|------|
| `--subject` | 是 | 邮件主题 |
| `--body` | 和 `--body-file` 二选一 | 邮件正文（纯文本，支持换行） |
| `--body-file` | 和 `--body` 二选一 | 从文件读取正文 |
| `--type` | 否 | 通知类型，默认 `info` |
| `--recipient` | 否 | 覆盖收件人邮箱（默认读取 `MY_EMAIL`） |
| `--no-prefix` | 否 | 禁用通知前缀和徽章（仅用于记录场景，见 `save-to-yinxiang`） |

### 通知类型

| type | 含义 | 邮件主题前缀 |
|------|------|-------------|
| `complete` | 任务完成 | ✅ [任务完成] |
| `progress` | 进展更新 | 📊 [进展更新] |
| `error` | 遇到错误 | ❌ [遇到错误] |
| `info` | 一般通知 | ℹ️ [信息通知] |

## 使用示例

### 场景 1：用户说"完成后给我发邮件"

任务完成后执行：
```bash
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --subject "重构任务完成" \
  --body "代码重构已完成。
- 重构了 auth 模块
- 添加了单元测试
- 所有测试通过" \
  --type complete
```

### 场景 2：用户说"发个邮件告诉我进展"

```bash
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --subject "数据库迁移进展" \
  --body "已完成 3/5 张表的迁移，预计还需要 10 分钟。" \
  --type progress
```

### 场景 3：遇到阻塞需要通知

```bash
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --subject "构建失败" \
  --body "CI 构建失败，错误信息：
ModuleNotFoundError: No module named 'xxx'
需要手动安装依赖。" \
  --type error
```

### 场景 4：正文很长时用文件

```bash
# 先把报告写入文件，再用文件发送
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --subject "性能测试报告" \
  --body-file /tmp/report.txt \
  --type info
```

## 操作规则

1. **用户明确要求发邮件时才执行**，不要主动发送
2. 邮件正文要简洁有用，包含关键信息：做了什么、结果如何、是否需要用户操作
3. 正确选择 `--type` 参数，让邮件主题前缀反映实际情况
4. 如果脚本报错（环境变量未设置等），提示用户配置环境变量
5. Windows 路径使用 `~/.claude/skills/notify-email/scripts/send_email.py` 或完整绝对路径均可

## 故障排除

| 错误 | 原因 | 解决 |
|------|------|------|
| `EMAIL_ACCOUNT not set` | 环境变量未配置 | 设置系统环境变量 |
| `SMTP authentication failed` | 密码错误或未用授权码 | 使用授权码而非登录密码 |
| `Connection timed out` | SMTP 服务器不可达 | 检查网络或更换端口 |
| 中文乱码 | 终端编码问题 | 脚本内部已处理 UTF-8，无需担心 |
