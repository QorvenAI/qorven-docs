#!/usr/bin/env bash
# Generate /cli/*.mdx pages from `qorven <cmd> --help` output.
# Re-run whenever the CLI surface changes.

set -euo pipefail

BIN="${QORVEN_BIN:-/tmp/qorven-final}"
OUT="/home/ec2-user/qorven-docs/cli"
mkdir -p "$OUT"

commands=(
  admin agents auth backup channels chat collapse-sessions config cron
  debug doctor gateway health init logs mcp memory migrate models
  providers read research restore rooms scan sessions setup start status
  tasks teams tls tools update usage vault version workflows
  # agent is singular — dev tooling
  agent
)

icons=(
  admin=shield agents=users auth=key backup=save channels=message-square
  chat=message-circle "collapse-sessions"=git-merge config=settings
  cron=clock debug=bug doctor=stethoscope gateway=server health=activity
  init=rocket logs=file-text mcp=plug memory=brain migrate=database-zap
  models=cpu providers=cloud read=file research=search restore=upload
  rooms=users scan=shield-check sessions=list setup=rocket start=play
  status=activity tasks=check-square teams=users tls=lock tools=wrench
  update=arrow-up usage=bar-chart vault=lock-keyhole version=tag
  workflows=git-branch agent=code
)

for cmd in "${commands[@]}"; do
  out="$OUT/${cmd}.mdx"
  icon="settings"
  # find icon key
  for entry in "${icons[@]}"; do
    key="${entry%%=*}"
    val="${entry#*=}"
    if [ "$key" = "$cmd" ]; then icon="$val"; break; fi
  done
  help=$("$BIN" "$cmd" --help 2>&1 || true)
  short=$(printf '%s\n' "$help" | head -1 | sed 's/^#*\s*//')
  {
    printf -- '---\n'
    printf 'title: "%s"\n' "qorven $cmd"
    printf 'description: "%s"\n' "${short:-Qorven CLI subcommand reference for \`$cmd\`.}"
    printf 'sidebarTitle: "%s"\n' "$cmd"
    printf 'icon: "%s"\n' "$icon"
    printf -- '---\n\n'
    printf '<Info>Generated from `qorven %s --help`. Re-run `scripts/gen-cli-reference.sh` after CLI changes.</Info>\n\n' "$cmd"
    printf '## Reference\n\n'
    printf '```text\n'
    printf '%s\n' "$help"
    printf '```\n\n'
    printf '## Examples\n\n<Note>Example section to fill with real operator usage patterns. TBD.</Note>\n\n'
    printf '## Related\n\n<CardGroup cols={2}>\n'
    printf '  <Card title="CLI index" icon="terminal" href="/cli/index">All commands.</Card>\n'
    printf '  <Card title="Global flags" icon="flag" href="/cli/global-flags">`--server`, `--token`, `--output`.</Card>\n'
    printf '</CardGroup>\n'
  } > "$out"
  echo "✓ $out"
done

echo "done. $(ls "$OUT"/*.mdx | wc -l) CLI pages generated."
