# Conformance kit

Status: Draft

## 1. Purpose

`MYC-CORE-013` requires a repository at L2 or higher to run on a conformant
runtime, shown by a passing conformance result. A third party needs a way to
produce that result without reading the reference runtime's code. This
document defines the conformance kit: the command, the fixtures as data, the
result, and when a result is valid.

From `v2.0.0` the kit is a contract and a set of fixtures in this repository.
The code that executes the fixtures comes with the reference runtime in
`runtime/` from `v2.1.0` ([ADR-0001](../00-foundations/decisions/0001-scope-boundary.md)).
Any implementation of this contract may produce a conformance result.

## 2. Scope

- The kit tests runtime behavior: how a run ends, what it records, and what it
  refuses. The requirements it covers name their fixture under
  "Verification".
- The [OpenCode conformance checklist](opencode-conformance.md) tests the
  repository's OpenCode configuration (`OC-01` to `OC-23`). Where a check and a
  fixture cover the same behavior (`OC-08` denied action, `OC-18` stop, `OC-22`
  kill switch), the fixture is the normative test and the check points to it.
- A verification without a fixture name is an assessor check, not part of the
  kit.

## 3. Command

`mycelia conformance --repo <path> --profile <profile>` runs every fixture that
applies to the profile against the runtime and writes a conformance result.

| Flag | Meaning |
| --- | --- |
| `--repo <path>` | The repository under test, in a disposable clone or sandbox |
| `--profile <profile>` | `minimal`, `standard`, or `high-assurance` |
| `--fixtures <path>` | The fixture directory; default the pinned kit's `conformance/fixtures/` |
| `--only <fixture>` | Run one fixture; the result is then partial and not valid for a claim |
| `--format <format>` | `json` or `yaml`; the result validates against `conformance-result.schema.json` |
| `--out <path>` | Write the result to a file |

| Exit code | Meaning |
| --- | --- |
| `0` | Every applicable fixture case passed |
| `2` | Invalid fixture, profile, or configuration |
| `5` | Internal error of the kit |
| `6` | At least one applicable fixture case failed or errored |

These are the exit codes of `mycelia conformance` itself. Each fixture case
also states the exit code the run under test must return (`runExitCode`), from
[cli-contract.md](../80-interface/cli-contract.md) §5.

### `MYC-INT-001` Conformance command

- **Statement:** A conformance kit implementation MUST provide the command,
  flags, and exit codes in §3, MUST run each applicable fixture case in an
  isolated repository and runtime state, and MUST write a result that
  validates against `schemas/conformance-result.schema.json`. A case that
  cannot run (setup failure, timeout, crash) MUST be reported as `error`, never
  as `pass` or `not-applicable`.
- **Rationale:** A result that different implementations write in different
  shapes, or that hides a crashed case, cannot be compared or trusted.
- **Applies to:** Any implementation of the kit; L2-L4 claims.
- **Evidence:** The conformance result file.
- **Verification:** Schema validation of the result; assessor check that the
  results cover every applicable fixture case.
- **Failure mode:** The result is invalid for a conformance claim; the ceiling
  stays at L1 (`MYC-CORE-013`).

## 4. Fixture format

Each fixture is one YAML file in `conformance/fixtures/`, named after the
fixture, and validates against `schemas/conformance-fixture.schema.json`.

| Field | Meaning |
| --- | --- |
| `metadata.id` | Fixture name; equals the file name and the name in "Verification" |
| `spec.requirements` | The requirement IDs the fixture verifies |
| `spec.profiles` | The profiles the fixture applies to |
| `spec.cases[].given` | Starting conditions: work item, run state, repository, configuration, runtime |
| `spec.cases[].when` | Ordered steps from the step vocabulary below |
| `spec.cases[].expect.terminalState` | `accepted`, `rejected`, `blocked`, `aborted`, or `none` when no run starts |
| `spec.cases[].expect.runExitCode` | The exit code of the run or work cycle under test |
| `spec.cases[].expect.cycleOutcome` | The work cycle outcome, for cycle-level cases ([failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) §10) |
| `spec.cases[].expect.stateAfter` | The loop state a resumed or restarted run continues in |
| `spec.cases[].expect.evidence` | The record kinds the run must produce |
| `spec.cases[].expect.trace` | Trace events that must appear |
| `spec.cases[].expect.absent` | Effects that must not happen |

Every expected outcome comes from the failure mode or statement of the
requirement the fixture verifies; a fixture does not define behavior. Record
kinds that are not yet schemas are added with the runtime data contracts
(#109).

Step vocabulary:

| Step | Meaning |
| --- | --- |
| `start-run`, `start-second-run`, `operator-start` | Start a run for the work item |
| `start-cycle` | Start a work cycle over the eligible work items |
| `stop-runner`, `restart-runtime` | Stop the runner (optionally in a given state) and restart the runtime |
| `engage-kill-switch` | Engage the kill switch |
| `consume-budget` | Consume budget in a given dimension |
| `fail-check`, `flake-check` | Make a check fail, deterministically or once |
| `disconnect-trace` | Drop the event stream for a period |
| `trigger-ask` | Cause a permission evaluation that resolves to `ask` |
| `block-run` | Make the run end `blocked` with a question |
| `send-acknowledgement`, `expire-acknowledgement` | Acknowledge a notification, or let its expiry pass |
| `send-reply`, `send-owner-answer` | Reply to an open question, without or with the decision right |
| `record-decision`, `reject-decision` | Record an implementation choice; reject it as reviewer or accepting human |
| `push-change`, `mark-ready`, `enter-merge-queue` | Change the pull request and move it toward merge |
| `advance-base`, `update-base` | Move the default branch; update the branch from it |
| `replay-step` | Repeat a step with its side effect |
| `break-policy-statement` | Make a policy statement invalid so OpenCode drops it |
| `place-host-marker` | Put marker skills in host configuration outside the factory |
| `propose-dependency-update` | Propose a dependency version change |
| `reach-terminal-state` | Let the run continue to its terminal state |

## 5. Scenarios

| Fixture | Verifies | Expected outcomes |
| --- | --- | --- |
| `terminal-states` | `MYC-CORE-004`, `MYC-CORE-005` | `accepted` 0, `rejected` 7, `blocked` 3, `aborted` by policy 1 |
| `resume` | `MYC-EXE-001`, `-002`, `-003` | `accepted` 0 after a stop in each state; `blocked` 3 on a checkpoint mismatch |
| `retry-limit` | `MYC-EXE-003` | `blocked` 3 past the retry limit; no duplicate effect on replay |
| `concurrent-run` | `MYC-EXE-004` | Second run refused; the first ends `accepted` 0 |
| `stale-run` | `MYC-EXE-006` | Detected, recorded, resumed to `accepted` 0 |
| `budget-exhausted` | `MYC-EXE-007` | `aborted` 4 across a restart |
| `kill-switch` | `MYC-EXE-008` | `aborted` 1; no run starts after a restart |
| `notification` | `MYC-EXE-009` | `blocked` 3 with escalation on expiry |
| `headless-ask` | `MYC-EXE-010` | `blocked` 3; the `ask` is denied |
| `stale-evidence` | `MYC-EXE-011` | `blocked` 3; never `accepted` |
| `trace-gap` | `MYC-EXE-012` | `blocked` 3 on an unreconciled gap |
| `policy-load` | `MYC-EXE-013` | `aborted` 1 before the first prompt |
| `host-isolation` | `MYC-EXE-014` | Markers absent and `accepted` 0; a loaded marker gives `aborted` 1 |
| `no-progress` | `MYC-EXE-015` | Guard stops at its limit (exit 3); progress resets it |
| `blocked-only` | `MYC-EXE-016` | No run, one summary, exit 3 |
| `answer-resume` | `MYC-EXE-017` | Only the owner answer clears the block; resume state |
| `prompt-guard-conflict` | `MYC-EXE-018` | `blocked` 3, blocked-only, guard does not fire |
| `recorded-decision` | `MYC-EXE-019` | Each fence and rejection path |
| `stale-base` | `MYC-EXE-020` | Update and re-run before classifying; budget `aborted` 4 |
| `carry-over` | `MYC-EXE-021` | Results carry only when proven safe |
| `fast-gate` | `MYC-ASR-001` | No required layer dropped |
| `selection-map-miss` | `MYC-ASR-002` | Miss recorded as a selection-map defect |
| `full-gate-budget` | `MYC-ASR-004` | `aborted` 4 over the maximum; queue rebuilds not counted |
| `skip-rule` | `MYC-ASR-005` | `blocked` 3 without replacement evidence or with a self-added rule |
| `dependency-tier` | `MYC-CTL-007` | Tier per rule; failing major update `rejected` 7 |

### `MYC-ADP-002` Kit coverage

- **Statement:** Every fixture named in a "Verification" field MUST exist as a
  file in `conformance/fixtures/`, every fixture file MUST be named in at least
  one "Verification" field, and each file's `metadata.id` MUST equal its file
  name. A meta-check MUST enforce this in CI.
- **Rationale:** A requirement that names a missing fixture is untested; a
  fixture no requirement names tests nothing anyone relies on. This applies
  `MYC-CTL-005` to the kit itself.
- **Applies to:** This repository; any fork of the kit.
- **Evidence:** Meta-check output (`scripts/check-fixture-names.sh`).
- **Verification:** CI runs the meta-check on every change.
- **Failure mode:** The change is `rejected`.

## 6. Result

A conformance result records the runtime and its version, the OpenCode version
tested, the kit version and commit, the profile, the repository commit, and
the status of every fixture case (`pass`, `fail`, `error`, or
`not-applicable`), with what was observed and the evidence produced.

### `MYC-ADP-001` Valid conformance result

- **Statement:** A conformance result supports a claim (`MYC-CORE-013`) only
  when all of these hold: it validates against the result schema; it was
  produced from a pinned kit version (tag or commit) that is the current kit
  version or one the claim names; every fixture case that applies to the
  claimed profile has status `pass`; `not-applicable` appears only for cases
  whose fixture does not list the profile; and the runtime version, the
  OpenCode version, the kit version, and the profile match the runtime the
  repository actually runs. A result MUST be produced again when any of these
  change. A result from an older kit does not cover fixtures added later.
- **Rationale:** A passing result on another runtime version, another profile,
  or an older kit says nothing about the runtime in use.
- **Applies to:** L2-L4 claims.
- **Evidence:** The conformance result and the runtime environment record
  (`MYC-EXE-014`).
- **Verification:** Assessor check of the result against the runtime record
  and the kit version.
- **Failure mode:** Ceiling lowered to L1 (`MYC-CORE-013`).

## 7. Profiles

| Profile | Required fixtures |
| --- | --- |
| `minimal` | None; a runtime is required only from L2 |
| `standard` | Every fixture that lists `standard` |
| `high-assurance` | Every fixture that lists `high-assurance` |

Every fixture in this version lists both `standard` and `high-assurance`,
because every requirement it verifies applies from L2.

## 8. Anti-patterns

- A fixture whose expected outcome no requirement states.
- Reporting a crashed case as `not-applicable`.
- Claiming conformance with a result from another runtime version.
- A fixture that checks only that a run finished, not how it ended.
- Editing a fixture to match a runtime instead of fixing the runtime.

## 9. Related documents

- [SPEC.md](../../SPEC.md) — `MYC-CORE-013`
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md)
  — runtime requirements
- [failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) —
  blocked and progress requirements
- [cli-contract.md](../80-interface/cli-contract.md) — commands and exit codes
- [opencode-conformance.md](opencode-conformance.md) — configuration checklist
- [conformance-profiles.md](conformance-profiles.md) — profiles
- [guard-design.md](../20-control/guard-design.md) — meta-check pattern
- [docs/README.md](../README.md) — documentation map
