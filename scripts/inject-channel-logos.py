#!/usr/bin/env python3
"""Inject a brand logo at the top of every channel page."""
import pathlib

ROOT = pathlib.Path("/home/ec2-user/qorven-docs")
CH_DIR = ROOT / "channels"

brands = {
    "web":         "Qorven Web UI",
    "tui":         "Qorven TUI",
    "telegram":    "Telegram",
    "whatsapp":    "WhatsApp",
    "slack":       "Slack",
    "discord":     "Discord",
    "teams":       "Microsoft Teams",
    "line":        "LINE",
    "signal":      "Signal",
    "imessage":    "iMessage",
    "facebook":    "Facebook Messenger",
    "matrix":      "Matrix",
    "mattermost":  "Mattermost",
    "feishu":      "Feishu / Lark",
    "dingtalk":    "DingTalk",
    "wecom":       "WeCom (WeChat Work)",
    "zalo":        "Zalo",
    "webchat":     "Qorven webchat",
    "email":       "Email (IMAP/SMTP)",
    "sms":         "SMS (via Twilio)",
    "github":      "GitHub",
    "webhook":     "Generic webhook",
}

first_party = {"web", "tui", "webchat"}  # no trademark disclaimer for our own surfaces

for cid, display in brands.items():
    mdx = CH_DIR / f"{cid}.mdx"
    if not mdx.exists():
        print(f"skip (missing): {cid}")
        continue
    src = mdx.read_text(encoding="utf-8")
    if "BrandHeader" in src or f"/images/logos/channels/{cid}.svg" in src:
        print(f"skip (already has logo): {cid}")
        continue

    parts = src.split("---", 2)
    if len(parts) < 3:
        print(f"skip (no frontmatter): {cid}")
        continue
    fm, body = parts[1], parts[2]

    if cid in first_party:
        disclaimer = "Built into Qorven."
    else:
        disclaimer = f"Trademark of {display}. Used under [nominative fair use](/reference/brand-trademarks)."

    header = f"""
<div className="mb-6 flex items-center gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-3">
  <img src="/images/logos/channels/{cid}.svg" alt="{display} logo" width={{40}} height={{40}} />
  <div>
    <div className="text-sm font-semibold">{display}</div>
    <div className="text-xs opacity-60">{disclaimer}</div>
  </div>
</div>
"""

    new = "---" + fm + "---\n" + header + body
    mdx.write_text(new, encoding="utf-8")
    print(f"✓ {cid}")
