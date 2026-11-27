#!/usr/bin/env bash
# Validate every record of the worked example against the schema whose kind
# const matches the record's kind. Fails on an unknown kind or an empty
# directory.
set -euo pipefail
cd "$(dirname "$0")/.."

dir=examples/worked-example
shopt -s nullglob
records=("$dir"/*.yaml)
if [ "${#records[@]}" -eq 0 ]; then
  echo "No records in $dir"; exit 1
fi

declare -A schema_for
for s in schemas/*.schema.json; do
  kind=$(tr -d ' \n' < "$s" | grep -oE '"kind":\{"const":"[A-Za-z]+"\}' | sed 's/.*"const":"//; s/"}//' || true)
  [ -n "$kind" ] && schema_for[$kind]=$s
done

declare -A files_for
status=0
for r in "${records[@]}"; do
  kind=$(grep -m1 -E '^kind: ' "$r" | sed 's/^kind: //')
  s=${schema_for[$kind]:-}
  if [ -z "$s" ]; then
    echo "No schema for kind '$kind' in $r"; status=1; continue
  fi
  files_for[$s]="${files_for[$s]:-} $r"
done
[ "$status" -eq 0 ] || exit "$status"

for s in "${!files_for[@]}"; do
  # shellcheck disable=SC2086
  pipx run check-jsonschema --schemafile "$s" ${files_for[$s]}
done
echo "ok -- ${#records[@]} worked example records valid"
