# CLI and automation contract

Status: Draft

## 1. Purpose

An implementation needs a stable surface. Scripts, CI, and other agents need
predictable output and exit codes. This document defines the command surface
that a Mycelia implementation must provide.

## 2. Principles

- Non-interactive by default in CI.
- Machine-readable output on stdout; human summaries are optional.
- Data to stdout; errors to stderr.
- Read-only commands never write.
- Write commands require an explicit confirmation or `--yes`.
- Every command is idempotent for the same inputs.
- No secrets in output.

## 3. Commands

| Command | Purpose | Writes | Output |
| --- | --- | --- | --- |
| `mycelia init` | Copy the template and write `mycelia.yaml` | Yes | Files |
| `mycelia validate` | Validate configs, schemas, and examples | No | Validation result |
| `mycelia assess` | Run the readiness assessment | No | Readiness report |
| `mycelia plan` | Turn a work item into a plan | No | Plan |
| `mycelia run` | Execute the loop | Yes | Run state, trace, evidence |
| `mycelia verify` | Run the evidence manifest | Evidence | Evidence records |
| `mycelia report` | Build an audit or acceptance report | Optional | Report |
| `mycelia doctor` | Check the runtime and environment | No | Check result |
| `mycelia upgrade` | Diff and apply a template upgrade | Yes | Diff, migration |

## 4. Flags

| Flag | Meaning |
| --- | --- |
| `--config <path>` | Configuration file, default `mycelia.yaml` |
| `--format json|yaml|markdown` | Output format, default `markdown` |
| `--out <path>` | Write the output to a file |
| `--profile <name>` | Override the profile |
| `--risk <R0-R4>` | Override the risk tier |
| `--agent <id>` | Select the role |
| `--model <provider/model#variant>` | Select the model |
| `--max-cost <usd>` | Cost limit |
| `--max-tokens <n>` | Token limit |
| `--max-steps <n>` | Step limit |
| `--dry-run` | Print the actions without writing |
| `--yes` | Confirm a write command |
| `--quiet` | Suppress the human summary |
| `--verbose` | Add diagnostic output |

## 5. Exit codes

| Code | Meaning |
| --- | --- |
| `0` | Success |
| `1` | Policy violation |
| `2` | Invalid input, config, or schema |
| `3` | Blocked; a human decision is required |
| `4` | Budget exhausted |
| `5` | Internal error |
| `6` | Conformance failure |

A blocked run exits `3`, never `0`. A policy denial exits `1`, never `0`.

## 6. Output

- JSON and YAML output must validate against the matching schema:
  readiness, run state, evidence, review, acceptance, release, incident,
  trace, provenance, or evaluation.
- Markdown output is a human summary; scripts must not parse it.
- Errors include a code, a message, and a remediation hint.
- No secret, token, or personal data in the output.
- `--format json` is the CI default.

## 7. Safety and idempotency

- `init`, `validate`, `assess`, `plan`, and `doctor` are read-only.
- `run` requires `--yes` for a non-interactive write.
- `run --dry-run` prints the planned actions and exits `0`.
- `run` requires a clean worktree or `--worktree`.
- `run` never pushes to `main` and never merges by default.
- The same work item, commit, and action returns the same result.
- A retry does not duplicate a branch, pull request, evidence item, or release.

## 8. OpenCode mapping

| Command | OpenCode mechanism |
| --- | --- |
| `run` | `opencode run --format json --agent --model --worktree` |
| `assess` | Read-only session with the assessor agent |
| `plan` | Read-only session with the planner agent |
| `verify` | Verifier session with the allowed test commands |
| `report` | Read the trace, evidence, and run state |
| `doctor` | `opencode --version`, config validation, API check |

## 9. Examples

```sh
mycelia validate
mycelia assess --format json --out readiness.json
mycelia plan --work-item MYC-123 --format markdown
mycelia run --work-item MYC-123 --dry-run
mycelia run --work-item MYC-123 --yes --max-cost 20
mycelia verify --work-item MYC-123 --commit abc1234
mycelia report --run RUN-001 --format markdown
mycelia doctor
```

## 10. Anti-patterns

- Interactive prompts in CI.
- Human-readable output parsed by scripts.
- Exit `0` on a blocked or denied run.
- A destructive default.
- Hidden network calls.
- Secrets in output.
- Non-idempotent retries.
- A command that writes during `validate` or `assess`.

## 11. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — runtime
- [autonomous-loop.md](../30-execution/autonomous-loop.md) — loop
- [readiness-assessment.md](../70-adoption/readiness-assessment.md) — assess
- [opencode-conformance.md](../70-adoption/opencode-conformance.md) — doctor
- [evidence-manifest.md](../20-control/evidence-manifest.md) — verify
- [file-formats.md](file-formats.md) — formats (planned)
- [docs/README.md](../README.md) — documentation map
