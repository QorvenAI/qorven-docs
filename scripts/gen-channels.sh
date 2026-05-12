#!/usr/bin/env bash
# Generate channel pages. One per integration, using a consistent template.
set -euo pipefail
OUT=/home/ec2-user/qorven-docs/channels
mkdir -p "$OUT"

# channel_id|display|icon|family|setup-source
channels=(
  "web|Web UI|monitor|chat-family|built-in"
  "tui|TUI|terminal|chat-family|built-in"
  "webchat|Embeddable webchat|message-square|chat-family|built-in"
  "telegram|Telegram|send|chat-family|@BotFather"
  "whatsapp|WhatsApp|message-circle|chat-family|Meta Developer Portal"
  "slack|Slack (DM)|slack|chat-family|Slack app"
  "discord|Discord (DM)|gamepad-2|chat-family|Discord developer portal"
  "teams|Microsoft Teams|users|chat-family|Microsoft 365 tenant"
  "line|LINE|message-circle|chat-family|LINE Developers"
  "signal|Signal|shield|chat-family|signal-cli"
  "imessage|iMessage|message-circle|chat-family|Blue Bubbles server"
  "facebook|Facebook Messenger|facebook|chat-family|Meta Developer Portal"
  "matrix|Matrix|hexagon|chat-family|Matrix homeserver"
  "mattermost|Mattermost|message-square|chat-family|Mattermost bot account"
  "feishu|Feishu / Lark|message-circle|chat-family|Feishu Open Platform"
  "dingtalk|DingTalk|message-circle|chat-family|DingTalk Open Platform"
  "wecom|WeCom (WeChat Work)|message-circle|chat-family|WeCom API"
  "zalo|Zalo|message-circle|chat-family|Zalo OA"
  "email|Email (IMAP/SMTP)|mail|non-chat|IMAP + SMTP credentials"
  "sms|SMS (Twilio)|phone|non-chat|Twilio account"
  "github|GitHub|github|non-chat|GitHub app"
  "webhook|Generic webhook|webhook|non-chat|any HTTP client"
)

for entry in "${channels[@]}"; do
  IFS='|' read -r id display icon family src <<< "$entry"
  out="$OUT/${id}.mdx"
  is_family="no"
  if [ "$family" = "chat-family" ]; then is_family="yes"; fi

  cat > "$out" <<EOF
---
title: "$display"
description: "Connect $display to your Qor. Setup, webhook URL, message shape, common issues."
sidebarTitle: "$display"
icon: "$icon"
---

<Info>
  $display is a **${family}** channel. $([ "$is_family" = "yes" ] && echo "Messages merge into your Qor's canonical chat — the web UI and TUI see them alongside every other chat-family channel." || echo "Messages live in their own session, not merged into the canonical chat.")
</Info>

## At a glance

| | |
|---|---|
| **Family** | $family |
| **Setup source** | $src |
| **Inbound** | Webhook / long-poll / socket — see below |
| **Outbound** | \`qorven channels send --channel $id\` or auto-reply from the agent loop |
| **Media** | Text + attachments (where the transport supports it) |
| **Group chats** | [Group handling →](/channels/groups-vs-dms) |

## Setup

<Steps>
  <Step title="Create the channel binding in Settings → Channels">
    In the web UI: **Settings → Channels → Add channel → $display**. Paste the credentials from $src.
  </Step>
  <Step title="Configure the webhook URL (if the provider pushes events)">
    Qorven exposes \`POST /v1/webhooks/$id\` on the web listener. Use your public URL (or a tunnel like Cloudflare / ngrok for dev).
  </Step>
  <Step title="Assign a Qor">
    Bind this channel to one Qor. That Qor receives every inbound message. You can always delegate onward.
  </Step>
  <Step title="Test with one message">
    Send a message from $display. Watch it appear in the web UI canonical chat with the $display badge.
  </Step>
</Steps>

## Routing & overrides

By default, every inbound $display message is routed to the Qor bound to this channel. You can override:

- **By sender** — route VIP senders to a different Qor
- **By keyword** — "URGENT" → escalation Qor
- **By group** — if it's a group chat, use group-scoped settings

See [Channel routing →](/channels/routing).

## Common issues

<AccordionGroup>
  <Accordion title="Messages not arriving">
    - Check \`qorven channels status $id\` — is the binding active?
    - Check the webhook URL is reachable from the internet (provider needs to hit it)
    - Check \`/var/log/qorven/channels.log\` for webhook 4xx/5xx entries
    - Rate limits: every channel has a per-tenant quota; see [quotas](/channels/quotas)
  </Accordion>
  <Accordion title="Replies not going out">
    - Check the Qor has the \`send_message\` tool in its allowlist
    - Check the LLM isn't emitting malformed tool calls — \`qorven logs --filter agent.loop.tool_error\`
    - Check the channel binding's credentials haven't expired (OAuth channels rotate tokens)
  </Accordion>
  <Accordion title="Duplicate messages">
    - Usually webhook retries. Qorven dedupes by \`(channel, external_id)\` but some providers send different IDs on retry. Open an issue with logs.
  </Accordion>
</AccordionGroup>

## Related

<CardGroup cols={2}>
  <Card title="All channels" icon="message-square" href="/channels/index">
    Catalog + concepts.
  </Card>
  <Card title="One Qor, one chat" icon="infinity" href="/architecture/one-qor-one-chat">
    How chat-family channels merge.
  </Card>
  <Card title="Channel routing" icon="git-branch" href="/channels/routing">
    Custom routing rules.
  </Card>
  <Card title="qorven channels CLI" icon="terminal" href="/cli/channels">
    Scripted channel management.
  </Card>
</CardGroup>
EOF
  echo "✓ $out"
done
echo "done. $(ls "$OUT"/*.mdx | wc -l) channel pages."
