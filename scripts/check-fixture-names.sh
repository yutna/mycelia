#!/usr/bin/env bash
# Meta-check for the conformance kit (MYC-ADP-002): every fixture named in a
# Verification field has a file, every file is named somewhere, and each
# file's metadata.id equals its file name.
set -euo pipefail
cd "$(dirname "$0")/.."

named=$(grep -rhoE 'Fixtures? `[a-z0-9-]+`( and `[a-z0-9-]+`)?' --include='*.md' docs SPEC.md \
  | grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u)
files=$(find conformance/fixtures -name '*.yaml' -printf '%f\n' | sed 's/\.yaml$//' | sort -u)

status=0
missing=$(comm -23 <(echo "$named") <(echo "$files"))
unnamed=$(comm -13 <(echo "$named") <(echo "$files"))
if [ -n "$missing" ]; then
  echo "Named in the docs but no fixture file:"; echo "$missing"; status=1
fi
if [ -n "$unnamed" ]; then
  echo "Fixture file not named in any Verification field:"; echo "$unnamed"; status=1
fi
for f in conformance/fixtures/*.yaml; do
  id=$(grep -m1 -E '^  id: ' "$f" | sed 's/^  id: //')
  if [ "$id" != "$(basename "$f" .yaml)" ]; then
    echo "metadata.id '$id' does not match file $f"; status=1
  fi
done
[ "$status" -eq 0 ] && echo "ok -- $(echo "$files" | wc -l) fixtures, names match"
exit "$status"
