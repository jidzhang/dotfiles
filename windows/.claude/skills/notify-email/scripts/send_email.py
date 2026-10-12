"""
Email notification script for Claude Code / OpenCode skill.

Reads credentials from environment variables:
  - EMAIL_ACCOUNT   : sender email address
  - EMAIL_PASSWORD  : sender password / app-specific password
  - MY_EMAIL        : recipient email address
  - SMTP_SERVER     : (optional) SMTP server, auto-detected by sender domain
  - SMTP_PORT       : (optional) SMTP port, default 465 (SSL)
"""

import argparse
import os
import smtplib
import sys
import re
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

SMTP_MAP = {
    "gmail.com": ("smtp.gmail.com", 465),
    "outlook.com": ("smtp-mail.outlook.com", 587),
    "hotmail.com": ("smtp-mail.outlook.com", 587),
    "live.com": ("smtp-mail.outlook.com", 587),
    "yahoo.com": ("smtp.mail.yahoo.com", 465),
    "yahoo.co.jp": ("smtp.mail.yahoo.co.jp", 465),
    "qq.com": ("smtp.qq.com", 465),
    "163.com": ("smtp.163.com", 465),
    "126.com": ("smtp.126.com", 465),
    "yeah.net": ("smtp.yeah.net", 465),
    "sina.com": ("smtp.sina.com", 465),
    "foxmail.com": ("smtp.qq.com", 465),
    "icloud.com": ("smtp.mail.me.com", 587),
    "me.com": ("smtp.mail.me.com", 587),
    "mail.ru": ("smtp.mail.ru", 465),
    "yandex.com": ("smtp.yandex.com", 465),
    "protonmail.com": ("smtp.protonmail.ch", 587),
}

TYPE_CONFIG = {
    "complete": ("\u2705", "任务完成"),
    "progress": ("\U0001f4ca", "进展更新"),
    "error": ("\u274c", "遇到错误"),
    "info": ("\u2139\ufe0f", "信息通知"),
}


def detect_smtp(sender):
    domain = sender.rsplit("@", 1)[-1].lower()
    if domain in SMTP_MAP:
        return SMTP_MAP[domain]
    return (f"smtp.{domain}", 465)


def build_html_body(subject, body, notif_type, no_prefix=False):
    import html as _html

    # 按行处理：分隔线转换为 hr，其他内容正常转义
    lines = body.split('\n')
    processed_lines = []

    for line in lines:
        stripped = line.strip()
        if stripped and re.match(r'^[\=\-\*\#]+$', stripped) and len(stripped) >= 5:
            processed_lines.append('<hr style="border:none;border-top:1px solid #e5e7eb;margin:6px 0;"/>')
        else:
            processed_lines.append(_html.escape(line))

    result_lines = []
    for i, line in enumerate(processed_lines):
        result_lines.append(line)
        if i < len(processed_lines) - 1 and not line.startswith('<hr'):
            result_lines.append('<br>')

    escaped_body = '\n'.join(result_lines)

    if no_prefix:
        return f"""\
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;font-family:system-ui,-apple-system,sans-serif;">
  <div style="max-width:600px;margin:20px auto;background:#ffffff;padding:24px;">
    <h2 style="margin:0 0 16px 0;font-size:18px;color:#111827;">{_html.escape(subject)}</h2>
    <div style="color:#374151;font-size:14px;line-height:1.8;">
      {escaped_body}
    </div>
  </div>
</body>
</html>"""

    emoji, label = TYPE_CONFIG.get(notif_type, ("\U0001f4cc", "通知"))
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    badge_colors = {
        "complete": "#10b981",
        "progress": "#3b82f6",
        "error": "#ef4444",
        "info": "#6366f1",
    }
    badge_color = badge_colors.get(notif_type, "#6b7280")

    return f"""\
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:system-ui,-apple-system,sans-serif;">
  <div style="max-width:600px;margin:20px auto;background:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,0.1);">
    <div style="background:{badge_color};padding:16px 24px;">
      <span style="font-size:20px;">{emoji}</span>
      <span style="color:#ffffff;font-size:16px;font-weight:600;margin-left:8px;">{label}</span>
    </div>
    <div style="padding:24px;">
      <h2 style="margin:0 0 16px 0;font-size:18px;color:#111827;">{_html.escape(subject)}</h2>
      <div style="color:#374151;font-size:14px;line-height:1.8;">
        {escaped_body}
      </div>
    </div>
    <div style="padding:12px 24px;background:#f9fafb;border-top:1px solid #e5e7eb;">
      <span style="color:#9ca3af;font-size:12px;">{now}</span>
    </div>
  </div>
</body>
</html>"""


def send_email(subject, body, notif_type, attachments=None, recipient_override=None, no_prefix=False):
    sender = os.environ.get("EMAIL_ACCOUNT", "").strip()
    password = os.environ.get("EMAIL_PASSWORD", "").strip()
    recipient = (recipient_override or os.environ.get("MY_EMAIL", "")).strip()

    if not sender:
        print("ERROR: EMAIL_ACCOUNT environment variable not set.", file=sys.stderr)
        sys.exit(1)
    if not password:
        print("ERROR: EMAIL_PASSWORD environment variable not set.", file=sys.stderr)
        sys.exit(1)
    if not recipient:
        print("ERROR: MY_EMAIL environment variable not set.", file=sys.stderr)
        sys.exit(1)

    smtp_server = os.environ.get("SMTP_SERVER", "").strip()
    smtp_port = os.environ.get("SMTP_PORT", "").strip()

    if smtp_server:
        port = int(smtp_port) if smtp_port else 465
    else:
        smtp_server, port = detect_smtp(sender)

    if no_prefix:
        full_subject = subject
    else:
        emoji, label = TYPE_CONFIG.get(notif_type, ("\U0001f4cc", "通知"))
        full_subject = f"{emoji} [{label}] {subject}"

    msg = MIMEMultipart("mixed")
    msg["Subject"] = full_subject
    msg["From"] = f"CodeAgent <{sender}>"
    msg["To"] = recipient

    alt_part = MIMEMultipart("alternative")
    alt_part.attach(MIMEText(body, "plain", "utf-8"))
    html_body = build_html_body(subject, body, notif_type, no_prefix)
    alt_part.attach(MIMEText(html_body, "html", "utf-8"))
    msg.attach(alt_part)

    if attachments:
        for filepath in attachments:
            filepath = os.path.abspath(filepath)
            if not os.path.isfile(filepath):
                print(
                    f"WARN: Attachment not found, skipping: {filepath}", file=sys.stderr
                )
                continue
            filename = os.path.basename(filepath)
            with open(filepath, "rb") as f:
                part = MIMEBase("application", "octet-stream")
                part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header("Content-Disposition", f'attachment; filename="{filename}"')
            msg.attach(part)

    try:
        if port == 465:
            server = smtplib.SMTP_SSL(smtp_server, port, timeout=30)
        else:
            server = smtplib.SMTP(smtp_server, port, timeout=30)
            server.ehlo()
            server.starttls()
            server.ehlo()
        server.login(sender, password)
        server.sendmail(sender, [recipient], msg.as_string())
        server.quit()
        print(f"OK: Email sent to {recipient}")
    except smtplib.SMTPAuthenticationError:
        print(
            "ERROR: SMTP authentication failed. Check EMAIL_ACCOUNT and EMAIL_PASSWORD.",
            file=sys.stderr,
        )
        sys.exit(1)
    except smtplib.SMTPException as e:
        print(f"ERROR: SMTP error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Failed to send email: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Send notification email.")
    parser.add_argument("--subject", required=True, help="Email subject")
    parser.add_argument("--body", default="", help="Email body text")
    parser.add_argument("--body-file", default=None, help="Read body from file")
    parser.add_argument(
        "--type",
        default="info",
        choices=list(TYPE_CONFIG.keys()),
        help="Notification type (default: info)",
    )
    parser.add_argument(
        "--attach",
        nargs="*",
        default=None,
        help="File path(s) to attach",
    )
    parser.add_argument(
        "--recipient",
        default=None,
        help="Override recipient email address",
    )
    parser.add_argument(
        "--no-prefix",
        action="store_true",
        help="Disable notification prefix and badge (for note-taking, not alerts)",
    )
    args = parser.parse_args()

    body = args.body
    if args.body_file:
        with open(args.body_file, "r", encoding="utf-8") as f:
            body = f.read()

    if not body:
        print("ERROR: --body or --body-file is required.", file=sys.stderr)
        sys.exit(1)

    send_email(args.subject, body, args.type, args.attach, args.recipient, args.no_prefix)


if __name__ == "__main__":
    main()
