#!/usr/bin/env python3
"""Generate /llms.txt — the machine-readable index of every doc page.

One line per page: `<url> — <description>`. Description from the page's
frontmatter `description` field. Sorted by the navigation order.
"""
import json, re, pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "public" / "llms.txt"
OUT.parent.mkdir(parents=True, exist_ok=True)

with (ROOT / "docs.json").open() as f:
    cfg = json.load(f)

pages = []
def walk(o):
    if isinstance(o, dict):
        if "pages" in o:
            for p in o["pages"]:
                if isinstance(p, str): pages.append(p)
                elif isinstance(p, dict): walk(p)
        for v in o.values(): walk(v)
    elif isinstance(o, list):
        for x in o: walk(x)
walk(cfg)

def desc_of(path: str) -> str:
    mdx = ROOT / f"{path}.mdx"
    if not mdx.exists(): return ""
    head = mdx.read_text(encoding="utf-8").split("---", 2)
    if len(head) < 3: return ""
    for line in head[1].splitlines():
        m = re.match(r'\s*description:\s*"(.*)"\s*$', line)
        if m: return m.group(1)
    return ""

lines = [
    "# Qorven documentation",
    "",
    "Machine-readable index of every documentation page. Each line: `<URL> — <description>`.",
    "",
    "**Canonical HTML:** append the path to `https://docs.qorven.ai/`.",
    "**Canonical Markdown:** append `.md` to any path.",
    "",
    "## Pages",
    ""
]

for p in pages:
    d = desc_of(p) or "(no description)"
    lines.append(f"https://docs.qorven.ai/{p} — {d}")

lines.append("")
lines.append("## Dynamic endpoints")
lines.append("")
lines.append("https://docs.qorven.ai/docs/api/search — POST {query,max_results} → top-K matches")
lines.append("https://docs.qorven.ai/openapi.json — OpenAPI spec for the /v1/* HTTP API")
lines.append("")

OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"wrote {OUT} with {len(pages)} pages")
