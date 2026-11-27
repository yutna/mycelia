#!/usr/bin/env bash
# Meta-check for the conformance kit (MYC-ADP-002): every fixture named in a
# Verification field has a file, every file is named somewhere, each file's
# metadata.id equals its file name, every expected record kind has a schema,
# and a case's profiles are a subset of its fixture's. Names are cited as
# Fixture `name`, Fixtures `a` and `b`, or a comma list, and may wrap lines.
set -euo pipefail
cd "$(dirname "$0")/.."

named=$(find docs -name '*.md' -print0 | xargs -0 cat SPEC.md | tr '\n' ' ' | tr -s ' ' \
  | grep -oE 'Fixtures? `[a-z0-9-]+`((, | and |, and )`[a-z0-9-]+`)*' \
  | grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u)
files=$(for f in conformance/fixtures/*.yaml; do basename "$f" .yaml; done | sort -u)

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
# Every record kind in expect.evidence is the kind of a schema in schemas/.
kinds=$(cat schemas/*.schema.json | tr -d ' \n' | grep -oE '"kind":\{"const":"[A-Za-z]+"\}' \
  | sed 's/.*"const":"//; s/"}//' | sort -u)
used=$(grep -h 'evidence: \[' conformance/fixtures/*.yaml | sed 's/.*evidence: \[//; s/\].*//' | tr ',' '\n' \
  | tr -d ' ' | sort -u)
unknown=$(comm -23 <(echo "$used") <(echo "$kinds"))
if [ -n "$unknown" ]; then
  echo "Record kind in expect.evidence with no schema:"; echo "$unknown"; status=1
fi

# A case's profiles are a subset of its fixture's profiles.
for f in conformance/fixtures/*.yaml; do
  fixture=$(grep -m1 -E '^  profiles: ' "$f" | sed 's/.*\[//; s/\].*//' | tr ',' '\n' | tr -d ' ' | sort -u)
  { grep -E '^      profiles: ' "$f" || true; } | while read -r line; do
    case_profiles=$(echo "$line" | sed 's/.*\[//; s/\].*//' | tr ',' '\n' | tr -d ' ' | sort -u)
    extra=$(comm -23 <(echo "$case_profiles") <(echo "$fixture"))
    if [ -n "$extra" ]; then echo "Case profile not in fixture profiles in $f: $extra"; exit 1; fi
  done || status=1
done

[ "$status" -eq 0 ] && echo "ok -- $(echo "$files" | wc -l) fixtures, names, record kinds, and profiles match"
exit "$status"
