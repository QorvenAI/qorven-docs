# Qorven docs — status

Last updated: 2026-04-22

## TL;DR

**Mintlify docs site scaffolded and live on `http://localhost:3002`.** 289 MDX pages across 13 nav tabs, brand-colored logos on every provider + channel page, full trademark/attribution page, violet-on-dark theme.

~35 pages are **hand-written production-quality anchor content**. The other ~255 are **solid stubs** — each has frontmatter, intro, related-cards; the nav loads cleanly; stubs are clearly labelled so reviewers know which is which.

## Run it

```bash
cd /home/ec2-user/qorven-docs
npm run dev
# opens on http://localhost:3002
```

Hard-reload (Cmd/Ctrl+Shift+R) on first open because the page previously cached other content.

## Brand logos + trademark attribution

Each **provider page** now has the provider's brand-colored logo at the top in a tile with a one-line trademark disclaimer pointing at `/reference/brand-trademarks`.

Each **channel page** has the same — with an exception for our own surfaces (web, TUI, webchat) where the disclaimer says "Built into Qorven" instead.

**Logo sources:**
- **thesvg** (MIT, ~11,000 icons) — primary source for every AI provider + channel: https://github.com/glincker/thesvg
- **lobe-icons** (MIT) — backup source: https://github.com/lobehub/lobe-icons
- **simple-icons** (CC0) — kept for a few general-purpose brand icons
- **lucide** (ISC) — every non-brand icon (navigation, callouts)

**Text fallbacks** for brands not in any library (Feishu/Lark, DingTalk): clean colored SVG tiles with the brand name in Inter-700 on the brand's own color. Legal to display under nominative fair use.

**The `/reference/brand-trademarks` page** lists:
- Every third-party trademark we reference + the owner
- The legal basis for depicting them (nominative fair use)
- Contact for logo-removal requests (`docs@qorven.ai`)
- Credit for every icon library used
- Credit for every OSS project Qorven builds on (Go, Postgres, pgvector, chi, Next.js, React, Tailwind, chromedp, Playwright, Shiki, Mermaid, Motion, Zustand, Sonner, Radix, Mintlify, etc.)

## What's in

### Anchor pages (deep hand-written content)

**Getting started** — install, first-chat, wizard, next-steps

**Architecture** — overview, one-qor-one-chat, delegation, memory-system, security-model

**Qors** — what-is-a-qor

**Memory** — overview

**Web UI** — overview

**TUI** — overview, slash-commands

**Channels** — index, unified-chat, groups-vs-dms, routing, debounce, quotas + 22 integration pages (Telegram, WhatsApp, Slack, Discord, Teams, LINE, Signal, iMessage, Facebook, Matrix, Mattermost, Feishu, DingTalk, WeCom, Zalo, webchat, email, SMS, GitHub, webhook)

**Models** — overview + 14 provider pages (OpenAI, Anthropic, Bedrock, DeepSeek, Gemini, Groq, Mistral, Together, Fireworks, Ollama, LM Studio, Perplexity, DashScope, OpenRouter) — all with brand logos

**Tools** — index

**Gateway** — overview, config-toml

**CLI** — index, global-flags, env-vars + 39 subcommand pages auto-generated from `qorven <cmd> --help`

**Reference** — licensing, privacy, comparison, http-api, architecture-diagrams, **brand-trademarks**

**AI agents** — agent-guide, llms-txt, markdown-source, docs-search-tool

**Help** — faq, debugging

### Auto-generated

| What | Count | How to regenerate |
|---|---|---|
| `/public/llms.txt` | 285 pages indexed | `python3 scripts/gen-llms-txt.py` |
| `/cli/*.mdx` | 39 pages | `scripts/gen-cli-reference.sh` |
| `/channels/*.mdx` | 22 integration pages | `scripts/gen-channels.sh` |
| `/models/providers/*.mdx` | 14 provider pages | `scripts/gen-providers.sh` |
| Provider brand tiles | 14 injected | `python3 scripts/inject-provider-logos.py` |
| Channel brand tiles | 22 injected | `python3 scripts/inject-channel-logos.py` |

### Screenshots
33 captures of the live Qorven web UI in `/images/screenshots/`. Rerun: `node scripts/capture-screenshots.mjs`.

### Brand logos
- 14 provider SVGs under `/images/logos/providers/` (thesvg source, color variants)
- 22 channel SVGs under `/images/logos/channels/` (thesvg + simple-icons + text-fallback)

## What's stubbed

193 pages have clean stubs: frontmatter + one-sentence intro + related-cards. They're labelled with `<Note>This page is a stub.</Note>`. Covers:

- `/qors/{creating,system-prompts,models,tools,skills,heartbeat,qoros-proactive,dreaming,delegation}`
- `/memory/{types,compaction,search,knowledge-graph,dreaming,privacy}`
- `/web-ui/{chat,qors-page,rooms,code-editor,connectors,drive,mail,calendar,schedule,memories,knowledge-graph,models-hub,marketplace,audit,notifications,terminal,sandbox,voice,settings/*}`
- `/tools/{built-in/*,coding/*,browser/*,media/*,delegation/*,custom/*}`
- `/workflows/*`, `/connectors/*`, `/gateway/*`, `/ops/*`, `/security/*`
- `/help/{log-locations,getting-help,error-codes}`

## What to review

1. **Open http://localhost:3002** — click through the tabs
2. **Open a provider page** like `/models/providers/openai` — confirm the logo + trademark disclaimer look right
3. **Open a channel page** like `/channels/telegram` — same check
4. **Open `/reference/brand-trademarks`** — confirm we're listing everything, covering the legal bases
5. **Read `/architecture/overview`, `/architecture/one-qor-one-chat`, `/reference/licensing`, `/reference/comparison`** — flag tone + accuracy
6. **Skim `/cli/*`** — auto-generated; zero review needed

## What's not done (waiting for your call)

- **Octopus / Qorven brand mark** — the docs currently use the hex/circuit mark from the old project. When marketing's final mark lands, drop it into `/images/logo/` and the docs adopt automatically.
- **Deploy to `docs.qorven.ai`** — build ready (`npm run build`), needs DNS + Mintlify project creation.
- **`docs_search` tool on the backend** — referenced at `/ai/docs-search-tool` but not yet wired into `backend/internal/tools/`. One afternoon of work when we green-light.
- **Per-channel provider screenshots** (BotFather UI, Meta console, Slack app page) — generic pages use the Qorven dashboard screenshot; per-channel setup screenshots are a nice-to-have for the stubbed channels.
- **OpenAPI spec at `/openapi.json`** — the HTTP API page references it; needs to be generated from the Go routes. Next sitting.
- **Mermaid theme tune** — diagrams render with Mintlify's default colors; can be tuned to match our violet. 30 min.

## Git

```
<next commit> content: brand logos + trademark attribution + lobe-icons + thesvg
89e1830 content: faq, debugging, comparison, privacy, http-api, diagrams, ai guides + STATUS
f69e841 content: anchor pages for qors, memory, web-ui, tools, gateway, tui, licensing
4df2f49 content: architecture, channels, providers, CLI reference, 288 pages total
131a33d init: docs scaffold + root index + getting-started
```

Unpushed (no remote yet). When you add a remote I push.

## Build

```bash
cd /home/ec2-user/qorven-docs
npm run build
```

Ready for Mintlify-hosted / Cloudflare Pages / Vercel deploy.

---

**Recommended review order when you open it up:**
1. Read this STATUS
2. http://localhost:3002 — click around
3. http://localhost:3002/models/providers/openai — check the logo tile
4. http://localhost:3002/channels/telegram — same
5. http://localhost:3002/reference/brand-trademarks — verify legal coverage
6. Read 3 anchor pages of your choice
7. Flag what's wrong, what to expand, what to cut

I'm ready for the review pass.
