#!/usr/bin/env python3
"""Inject a brand logo at the top of every provider page.

Reads /images/logos/providers/<id>.svg and inserts a <Frame> with the
logo right under the frontmatter. Idempotent — won't duplicate if the
logo is already there.
"""
import pathlib, re

ROOT = pathlib.Path("/home/ec2-user/qorven-docs")
PROV_DIR = ROOT / "models" / "providers"

# id -> (display, color) for consistent text color on the logo tile
brands = {
    "openai":     "OpenAI",
    "anthropic":  "Anthropic (Claude)",
    "bedrock":    "AWS Bedrock",
    "deepseek":   "DeepSeek",
    "gemini":     "Google Gemini",
    "groq":       "Groq",
    "mistral":    "Mistral",
    "together":   "Together AI",
    "fireworks":  "Fireworks",
    "ollama":     "Ollama (local)",
    "lmstudio":   "LM Studio (local)",
    "perplexity": "Perplexity",
    "dashscope":  "Alibaba DashScope / Qwen",
    "openrouter": "OpenRouter",
}

for pid, display in brands.items():
    mdx = PROV_DIR / f"{pid}.mdx"
    if not mdx.exists():
        print(f"skip (missing): {pid}")
        continue
    src = mdx.read_text(encoding="utf-8")

    # Skip if we've already injected a BrandHeader
    if "BrandHeader" in src or f"/images/logos/providers/{pid}.svg" in src:
        print(f"skip (already has logo): {pid}")
        continue

    # Split frontmatter + body
    parts = src.split("---", 2)
    if len(parts) < 3:
        print(f"skip (no frontmatter): {pid}")
        continue
    fm, body = parts[1], parts[2]

    header = f"""
<div className="mb-6 flex items-center gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-3">
  <img src="/images/logos/providers/{pid}.svg" alt="{display} logo" width={{40}} height={{40}} />
  <div>
    <div className="text-sm font-semibold">{display}</div>
    <div className="text-xs opacity-60">Trademark of {display}. Used under [nominative fair use](/reference/brand-trademarks).</div>
  </div>
</div>
"""

    new = "---" + fm + "---\n" + header + body
    mdx.write_text(new, encoding="utf-8")
    print(f"✓ {pid}")
