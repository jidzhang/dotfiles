---
name: Save to Yinxiang (印象笔记)
description: Save content to Evernote (Yinxiang) by sending an email to the user's Yinxiang email address.
---

## Save to Yinxiang

When the user says "保存到印象笔记", "发送到印象笔记", "保存到印象笔记", or similar, save the provided content to their Yinxiang (印象笔记) account by sending an email.

### How it works

Yinxiang (印象笔记) supports saving notes by sending an email to a special Yinxiang email address. This skill sends the content via the `notify-email` script with an explicit `--recipient` override.

### Steps

1. Read the environment variable `MY_YINXIANG_EMAIL` for the destination address.
2. Use the `notify-email` Python script with `--recipient` set to the Yinxiang email address.
3. Set `--subject` to the title provided by the user, or infer a title from the content.
4. Set `--body` or `--body-file` to the content to be saved.
5. Use `--type info`.

### Command template

```bash
python ~/.claude/skills/notify-email/scripts/send_email.py \
  --recipient "$MY_YINXIANG_EMAIL" \
  --no-prefix \
  --subject "<title>" \
  --body "<content>" \
  --type info
```

### Important notes

- **Always use `--no-prefix`** when saving to Yinxiang. This disables the notification badge (`✅ [任务完成]`, `ℹ️ [信息通知]`, etc.) so the subject stays clean as the note title.
- The `--recipient` flag ensures the email goes to Yinxiang, not the default `MY_EMAIL`.
- The email subject becomes the note title in Yinxiang.
- The email body becomes the note content in Yinxiang.
- If the content is very long, write it to a temporary file and use `--body-file` instead of `--body`.
- Do not include AI signatures or promotional text in the note content; keep it clean.
- Confirm success or failure to the user after sending.
