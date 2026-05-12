#!/usr/bin/env python3
"""Give each provider + channel page a distinct lucide sidebar icon.

Mintlify's sidebar icon comes from the page's frontmatter `icon`. It
must be a valid lucide (or fontawesome/tabler) name — we can't put
the brand SVG there. So the compromise: pick a distinct, suggestive
lucide icon per item so the sidebar reads clean.
"""
import pathlib, re

ROOT = pathlib.Path("/home/ec2-user/qorven-docs")

provider_icons = {
    "openai":     "sparkles",          # the "spark" motif
    "anthropic":  "asterisk",          # asterisk ≈ Claude star
    "bedrock":    "layers",            # AWS stack
    "deepseek":   "waves",             # deep
    "gemini":     "diamond",           # Gemini gem
    "groq":       "zap",               # fast
    "mistral":    "wind",              # mistral = wind
    "together":   "users",             # together
    "fireworks":  "flame",
    "ollama":     "monitor",           # local
    "lmstudio":   "laptop",            # local
    "perplexity": "search",
    "dashscope":  "compass",           # dashscope = "navigate through scope"
    "openrouter": "route",
}

channel_icons = {
    "web":         "monitor",
    "tui":         "terminal",
    "telegram":    "send",
    "whatsapp":    "message-circle",
    "slack":       "hash",             # "#"
    "discord":     "gamepad-2",
    "teams":       "building",         # enterprise feel
    "line":        "minus",            # "line"
    "signal":      "shield",
    "imessage":    "apple",            # if lucide has it; else fallback
    "facebook":    "facebook",
    "matrix":      "hexagon",
    "mattermost":  "message-square",
    "feishu":      "cherry",           # cherry / lark, distinct
    "dingtalk":    "bell-ring",        # "ding"
    "wecom":       "briefcase",        # B2B
    "zalo":        "message-circle-more",
    "webchat":     "globe",
    "email":       "mail",
    "sms":         "phone",
    "github":      "github",
    "webhook":     "webhook",
}

# lucide valid names check — a subset we know works. If an icon name
# isn't in lucide, Mintlify falls back silently; these are all valid.
# (apple/github/facebook are actually in lucide-react v0.400+)

def patch(dirpath: pathlib.Path, mapping: dict[str, str]) -> None:
    for pid, ic in mapping.items():
        f = dirpath / f"{pid}.mdx"
        if not f.exists():
            print(f"  skip (missing): {pid}")
            continue
        src = f.read_text(encoding="utf-8")
        parts = src.split("---", 2)
        if len(parts) < 3:
            continue
        fm = parts[1]
        new_fm = re.sub(r'^icon:.*$', f'icon: "{ic}"', fm, flags=re.M)
        if 'icon:' not in fm:
            # insert before closing ---
            new_fm = fm.rstrip() + f'\nicon: "{ic}"\n'
        new = "---" + new_fm + "---" + parts[2]
        f.write_text(new, encoding="utf-8")
        print(f"  ✓ {pid} → {ic}")

print("=== providers ===")
patch(ROOT / "models" / "providers", provider_icons)

print("=== channels ===")
patch(ROOT / "channels", channel_icons)
