#!/usr/bin/env bash
# Generate model provider pages.
set -euo pipefail
OUT=/home/ec2-user/qorven-docs/models/providers
mkdir -p "$OUT"

# id|display|icon|category|key-env|api-base
providers=(
  "openai|OpenAI|cloud|openai|OPENAI_API_KEY|https://api.openai.com/v1"
  "anthropic|Anthropic (Claude)|cloud|anthropic|ANTHROPIC_API_KEY|https://api.anthropic.com"
  "bedrock|AWS Bedrock|cloud|bedrock|AWS credentials|us-east-1"
  "deepseek|DeepSeek|cloud|openai-compat|DEEPSEEK_API_KEY|https://api.deepseek.com/v1"
  "gemini|Google Gemini|cloud|openai-compat|GEMINI_API_KEY|https://generativelanguage.googleapis.com/v1beta/openai"
  "groq|Groq (fast inference)|zap|openai-compat|GROQ_API_KEY|https://api.groq.com/openai/v1"
  "mistral|Mistral|cloud|openai-compat|MISTRAL_API_KEY|https://api.mistral.ai/v1"
  "together|Together AI|cloud|openai-compat|TOGETHER_API_KEY|https://api.together.xyz/v1"
  "fireworks|Fireworks|cloud|openai-compat|FIREWORKS_API_KEY|https://api.fireworks.ai/inference/v1"
  "ollama|Ollama (local)|monitor|openai-compat|none (local)|http://localhost:11434/v1"
  "lmstudio|LM Studio (local)|monitor|openai-compat|none (local)|http://localhost:1234/v1"
  "perplexity|Perplexity (search)|search|openai-compat|PERPLEXITY_API_KEY|https://api.perplexity.ai"
  "dashscope|Alibaba DashScope / Qwen|cloud|openai-compat|DASHSCOPE_API_KEY|https://dashscope.aliyuncs.com"
  "openrouter|OpenRouter (aggregator)|link|openai-compat|OPENROUTER_API_KEY|https://openrouter.ai/api/v1"
)

for entry in "${providers[@]}"; do
  IFS='|' read -r id display icon cat env api <<< "$entry"
  out="$OUT/${id}.mdx"
  is_local="no"
  if [[ "$api" == *localhost* ]]; then is_local="yes"; fi

  cat > "$out" <<EOF
---
title: "$display"
description: "Configure $display as an LLM backend for your Qors. Setup, models, rate limits, common issues."
sidebarTitle: "$display"
icon: "$icon"
---

<Info>
  $display is available as a provider in Qorven. $([ "$is_local" = "yes" ] && echo "Runs locally — no outbound calls, no API costs." || echo "Add your API key once; rotate across keys automatically on rate-limits.")
</Info>

## At a glance

| | |
|---|---|
| **Category** | $cat |
| **API base** | \`$api\` |
| **Key env var** | \`$env\` |
| **Provider type** | $([ "$cat" = "openai-compat" ] && echo "OpenAI-compatible" || echo "Native") |

## Setup

<Steps>
  <Step title="Get credentials from $display">
    $([ "$is_local" = "yes" ] && echo "Install $display locally. See their docs." || echo "Create an API key in the $display console.")
  </Step>
  <Step title="Add the key in Qorven">
    **Settings → Provider Keys → Add provider → $display → paste key → Save.**

    The key is AES-256-GCM encrypted with your install's encryption key before it hits the database.
  </Step>
  <Step title="Mark a default model">
    **Models Hub → Models →** pick which $display model is the default for new Qors.
  </Step>
  <Step title="Test">
    Ask Prime any question. In the LLM trace you'll see \`provider=$id\`.
  </Step>
</Steps>

## Popular models

<Note>
  The full model list is in the [models catalog](/models/overview). Qorven's catalog keeps costs + context windows + capability flags up to date weekly from the providers.
</Note>

## Rate limits & failover

Qorven supports multiple keys per provider. When one rate-limits, the next is tried automatically. When all keys on a provider are exhausted, failover moves to the next provider in your priority list. [Failover →](/models/failover)

## Common issues

<AccordionGroup>
  <Accordion title="401 Invalid key">
    Key is wrong, expired, or from the wrong org. Test with \`qorven providers verify $id\`.
  </Accordion>
  <Accordion title="429 Rate-limited">
    Provider is throttling. Add another key, or lower your Qor's model to a less-busy tier. Failover handles this automatically if configured.
  </Accordion>
  <Accordion title="402 Insufficient balance">
    Usually a missed top-up. Check the provider's billing dashboard. Qorven will fail over to the next provider; flag loudly if all are exhausted.
  </Accordion>
  <Accordion title="Timeout">
    Check your \`QORVEN_OUTBOUND_TIMEOUT\` (default 120s). Some local models need more. For $display specifically: $([ "$is_local" = "yes" ] && echo "check the local daemon is up and the port is open." || echo "check your network egress allows the provider's domain.")
  </Accordion>
</AccordionGroup>

## Related

<CardGroup cols={2}>
  <Card title="Provider keys" icon="key" href="/models/provider-keys">
    Full key management UI + CLI.
  </Card>
  <Card title="Models overview" icon="cloud" href="/models/overview">
    Catalog, defaults, cost.
  </Card>
  <Card title="Failover" icon="arrow-right" href="/models/failover">
    Multi-key, multi-provider rotation.
  </Card>
  <Card title="qorven providers CLI" icon="terminal" href="/cli/providers">
    Scripted provider management.
  </Card>
</CardGroup>
EOF
  echo "✓ $out"
done
echo "done. $(ls "$OUT"/*.mdx | wc -l) provider pages."
