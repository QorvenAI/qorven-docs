#!/usr/bin/env bash
# Create a solid stub for every page referenced in docs.json that doesn't
# exist yet. Each stub has frontmatter + a TBD info block + a related
# card group. So the navigation loads; so marketing can see the shape;
# so anchor pages stay visibly distinct from stubs.
set -euo pipefail

ROOT=/home/ec2-user/qorven-docs
cd "$ROOT"

# Extract every page path from docs.json
pages=$(python3 -c "
import json
with open('docs.json') as f: d = json.load(f)
def walk(o):
    if isinstance(o, dict):
        if 'pages' in o:
            for p in o['pages']:
                if isinstance(p, str): print(p)
                elif isinstance(p, dict): walk(p)
        for v in o.values(): walk(v)
    elif isinstance(o, list):
        for x in o: walk(x)
walk(d)
")

created=0
skipped=0
for p in $pages; do
  # Skip the root index
  if [ "$p" = "index" ]; then continue; fi
  mdx="${p}.mdx"
  if [ -f "$mdx" ]; then skipped=$((skipped+1)); continue; fi

  dir=$(dirname "$mdx")
  [ -d "$dir" ] || mkdir -p "$dir"

  # Derive a friendly title from the path's last segment
  name=$(basename "$p")
  title=$(echo "$name" | sed 's/-/ /g' | python3 -c "import sys; s=sys.stdin.read().strip(); print(' '.join(w.capitalize() if w not in ('a','an','the','of','in','for','and','or','vs') else w for w in s.split()))")

  cat > "$mdx" <<EOF
---
title: "$title"
description: "$title — reference and how-to for Qorven operators."
sidebarTitle: "$title"
---

<Note>
  This page is a stub. Anchor pages in this section have the full deep-dive; this one captures the subject and will be fleshed out in the next pass.
</Note>

## What this is

$title is part of $(dirname "$p" | sed 's|/| → |g') in Qorven. It exists because $(echo "$name" | sed 's/-/ /g') is a distinct concern that operators need to configure or reference directly.

## Where this fits

<CardGroup cols={2}>
  <Card title="Architecture overview" icon="layers" href="/architecture/overview">
    The 5-minute tour.
  </Card>
  <Card title="CLI index" icon="terminal" href="/cli/index">
    Scripted equivalents.
  </Card>
</CardGroup>

## Coming next

- Full reference with examples
- Screenshots from the live UI
- CLI + API equivalents
- Troubleshooting section

In the meantime: [open an issue](https://github.com/qorvenai/qorven/issues) with what you need covered and we'll prioritise.
EOF
  echo "✓ $mdx"
  created=$((created+1))
done

echo "---"
echo "created: $created"
echo "skipped: $skipped"
echo "total:   $(find . -name '*.mdx' | grep -v node_modules | wc -l)"
