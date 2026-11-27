# Worked example

Status: Draft

## 1. Purpose

Show the readiness model working end to end: a synthetic repository, a baseline
assessment, the autonomy ceiling, a gap register, a remediation plan, and a
reassessment. Then show one work item running at the new ceiling, from intake
through `blocked` and an owner answer to `accepted`, with its trace and
evidence (§9). The numbers are illustrative, but the method is the one the
assessment requires.

## 2. The repository

`acme/ledger-service` is a small Node.js service:

- 24,000 lines of TypeScript
- 120 unit and integration tests
- CI runs in 12 minutes
- flake rate around 8 percent
- one shared CI token
- `CODEOWNERS` exists but is stale
- no `AGENTS.md`
- no sandbox
- review is informal and manual
- no mutation testing
- traces live only in CI logs

## 3. Baseline assessment

| Control | Score | Evidence |
| --- | --- | --- |
| `CTL-01` | 2 | README exists; some commands are stale |
| `CTL-02` | 1 | Issues exist; no schema and no risk tier |
| `CTL-03` | 2 | `CODEOWNERS` exists but is stale |
| `CTL-04` | 0 | No `AGENTS.md` |
| `CTL-05` | 1 | One unpinned reference |
| `CTL-06` | 1 | No compaction or memory policy |
| `CTL-07` | 1 | Roles are ad hoc |
| `CTL-08` | 1 | Default permissions; no policies |
| `CTL-09` | 1 | Shared token |
| `CTL-10` | 1 | No red lines |
| `CTL-11` | 0 | No evidence manifest |
| `CTL-12` | 1 | Informal review |
| `CTL-13` | 1 | No run state |
| `CTL-14` | 0 | No failure protocol |
| `CTL-15` | 1 | No budget |
| `CTL-16` | 0 | No worktrees |
| `CTL-17` | 1 | Branch protection only |
| `CTL-18` | 0 | No rollback |
| `CTL-19` | 2 | Unit and integration tests in CI |
| `CTL-20` | 0 | No mutation |
| `CTL-21` | 1 | Ad hoc review |
| `CTL-22` | 1 | Every change is manually accepted |
| `CTL-23` | 1 | CI logs only |
| `CTL-24` | 0 | No metrics or evaluations |

## 4. Baseline ceiling

The L1 gate requires `CTL-02`, `CTL-04`, `CTL-07`, `CTL-08`, `CTL-10` to
`CTL-14` at 2 or higher. Several are below 2, so the L1 gate is unmet.

**Ceiling: L0.** The repository has tests and CI, but it cannot run safely at
L1 because it lacks a work item contract, instructions, roles, policy, and
evidence.

## 5. Gap register

| Control | Severity | Finding | Remediation | Owner | Effort |
| --- | --- | --- | --- | --- | --- |
| `CTL-11` | Blocker | No evidence manifest | Add the manifest and a CI gate | maintainer | 2 days |
| `CTL-04` | Blocker | No agent instructions | Add `AGENTS.md` with commands and rules | maintainer | 1 day |
| `CTL-02` | Blocker | No work item schema or risk tier | Add the schema and a template | maintainer | 2 days |
| `CTL-14` | Blocker | No failure protocol | Adopt the taxonomy and the blocked state | platform | 2 days |
| `CTL-10` | Blocker | No policy red lines | Add policies and negative tests | security | 1 day |
| `CTL-18` | Major | No rollback | Add a tested rollback | platform | 3 days |
| `CTL-20` | Major | No mutation | Add mutation for changed lines | maintainer | 1 day |
| `CTL-23` | Major | No durable trace | Export events to a trace sink | platform | 3 days |

## 6. Remediation plan

| Phase | Work | Exit evidence |
| --- | --- | --- |
| 1 | README, pinned toolchain, `AGENTS.md`, work item schema, ownership | Clean-clone check, schema, `AGENTS.md` |
| 2 | Roles, permissions, policies, identity, evidence manifest, decision rights | Policy tests, manifest, decision matrix |
| 3 | State machine, failure protocol, budgets, sandbox, worktrees, merge queue, rollback | Resume test, kill-switch drill, worktree test |
| 4 | Review rubric, mutation, acceptance sampling, trace, provenance, metrics | Review record, mutation report, trace export |

## 7. Reassessment

| Control | Baseline | After | Evidence |
| --- | --- | --- | --- |
| `CTL-01` | 2 | 3 | Clean-clone check in CI |
| `CTL-02` | 1 | 3 | Work item schema in use |
| `CTL-03` | 2 | 3 | Current ownership |
| `CTL-04` | 0 | 3 | `AGENTS.md` and link check |
| `CTL-05` | 1 | 2 | Pinned references |
| `CTL-06` | 1 | 2 | Compaction policy |
| `CTL-07` | 1 | 3 | Role contracts |
| `CTL-08` | 1 | 3 | Hardened permissions |
| `CTL-09` | 1 | 2 | Bot identity and secret policy |
| `CTL-10` | 1 | 3 | Policies and negative tests |
| `CTL-11` | 0 | 3 | Manifest and gate |
| `CTL-12` | 1 | 2 | Decision matrix |
| `CTL-13` | 1 | 2 | Run state and resume test |
| `CTL-14` | 0 | 2 | Failure taxonomy and drill |
| `CTL-15` | 1 | 2 | Budgets and kill switch |
| `CTL-16` | 0 | 2 | Worktree policy |
| `CTL-17` | 1 | 2 | Merge queue |
| `CTL-18` | 0 | 2 | Rollback drill |
| `CTL-19` | 2 | 3 | Layered checks in CI |
| `CTL-20` | 0 | 2 | Mutation for changed lines |
| `CTL-21` | 1 | 2 | Review record |
| `CTL-22` | 1 | 2 | Acceptance sample |
| `CTL-23` | 1 | 2 | Trace export |
| `CTL-24` | 0 | 2 | Metrics and one evaluation |

## 8. New ceiling

The L2 gate is met: every required control is at 2 or higher. The L3 gate is
not met: `CTL-20`, `CTL-22`, `CTL-23`, and `CTL-24` are still at 2.

**Ceiling: L2.** Next target: L3, with mutation, acceptance sampling, trace,
and metrics at 3.

## 9. One work item from intake to accepted

This section is illustrative, not normative. Every record is in
[`examples/worked-example/`](../../examples/worked-example/) and validates
against its schema (`scripts/check-worked-example.sh`, run by
`mise run lint:schemas` and CI). Record names below are the file names without
the number and `.yaml`. The evidence shows two of the layers the risk matrix
requires for R2
([verification-stack.md](../40-assurance/verification-stack.md) §11); a real
run records every required layer or a skip record for it.

### 9.1 Setup

`acme/ledger-service` now runs at L2 on a conformant runtime
(`mycelia-config`): heartbeat `PT1M`, acknowledgement expiry `P1D`, escalation
chain `ledger-owner` then `platform-lead`, recorded-decision limit zero. Work
item `MYC-200` (`work-item`) asks for a CSV export of monthly statements. It is
R2, `confidential`, and lists `affectedAreas` as path globs.

### 9.2 First run ends `blocked`

An operator starts `RUN-201`, and the start is in the trace
(`trace-start-run-201`); at L2 one operator start per run is enough
(`MYC-EXE-005`). The run takes the lease on `MYC-200` in its own worktree
(`MYC-EXE-004`), creates the branch under an idempotency key
(`idempotency-branch`, `MYC-EXE-003`), and writes a checkpoint at each
transition, each with the work item version (`run-state-run-201`,
`MYC-EXE-001`). The version covers the work item's contract fields; recording a
question or an answer does not change it.

While implementing, the agent finds that converted amounts can have more than
two decimals. Half up matches the PDF statement; half to even matches the
ledger. This changes numbers customers see, so it is a product decision, not an
implementation choice. `MYC-EXE-019` would not allow a recorded decision
anyway: the configured limit is zero (fence 5). The runtime follows the
ambiguity protocol
([failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) §5):

- The question `Q-200-1`, with both options, their consequences, the
  recommendation, and the owner who can answer, goes into the work item
  (`openQuestions`) and the trace (`trace-block`).
- The run checkpoints in `blocked` (`RUN-201#4`), ends `blocked`, and releases
  its lease. The work cycle is recorded as newly blocked, which does not count
  toward the no-progress guard (`work-cycle-201`, `MYC-EXE-015`).

### 9.3 Notification, acknowledgement, and a reply

- The runtime records the idempotency key before it sends
  (`idempotency-notify`), then notifies `ledger-owner`, the first target in the
  chain (`notification`, `trace-notify`, `MYC-EXE-009`). The runtime, not the
  ended run, sends it; the records name `RUN-201` as the run whose block it
  reports. The notification expires one day after delivery.
- The owner acknowledges within the hour. Escalation to `platform-lead` stops,
  but the block stays (`MYC-EXE-017`).
- A support agent replies with an opinion (`reply`, `trace-reply`). The support
  agent has no decision right, so the reply is recorded with
  `clearsBlock: false` and the work item stays `blocked`.

### 9.4 Owner answer and the new run

The owner answers: half up, and the answer does not change the work item
(`owner-answer`, `trace-answer`). Only this record clears the block. The
question's status becomes `answered` with a link to the answer.

The answer authorizes a new run; `RUN-201` stays terminal. An operator starts
`RUN-202` (`trace-start-run-202`, `run-state-run-202`). It takes a new lease and
starts from the blocked checkpoint. The resume checks of
[autonomous-loop.md](../30-execution/autonomous-loop.md) §7 pass: same commit,
branch, policy version, and work item version. The answer states no change, so
the run continues at `implementing` instead of `intake`. Both runs count
against one budget ledger for the work item (`budget-ledger`, `MYC-EXE-007`),
so the restart does not reset the budget.

### 9.5 Evidence, review, acceptance, merge, observation

- `RUN-202` opens the pull request under an idempotency key
  (`idempotency-pull-request`).
- The fast gate selects the statement checks from the selection map and passes
  at the head commit, with the selection map version and duration recorded
  (`evidence-unit`, `evidence-integration`).
- An independent reviewer on another model approves at the same commit
  (`review`) and checks the rounding against the answer.
- At L2 the agent does not merge on evidence gates alone
  ([autonomy-levels.md](../00-foundations/autonomy-levels.md) §2): the owner
  accepts at the same commit (`acceptance`, `trace-acceptance`); a work item
  that was blocked is an exception the owner handles. Only then does the
  runtime merge, under its own key (`idempotency-merge`).
- The run observes the change for the agreed window
  ([change-lifecycle.md](../30-execution/change-lifecycle.md) §10), then ends
  `accepted` (`trace-accepted`). The work cycle cites the merged change and the
  accepted work item as progress (`work-cycle-202`).

### 9.6 Record links

| From | To | Link |
| --- | --- | --- |
| Work item `Q-200-1` | `owner-answer` | `answerRef: ANS-201` |
| `notification` | `idempotency-notify` | Same key: work item, blocked commit, `notify`, `ledger-owner-step-0` |
| `owner-answer` | `run-state-run-201` | `blockedRunID`, `blockedCheckpoint: RUN-201#4` |
| `owner-answer` | `run-state-run-202` | `newRunID`, `newRunFirstCheckpoint: RUN-202#1` |
| Both run states | `budget-ledger` | `budgetLedgerRef: LDG-200`; totals are the sum of both runs |
| `evidence-*`, `review`, `acceptance`, `idempotency-merge` | `run-state-run-202` | All at the final head commit |

## 10. What the example demonstrates

- A repository can have tests and CI and still be at L0.
- Legibility and control raise the ceiling faster than a better model.
- L3 needs evidence depth, not more documentation.
- The method is deterministic: the same evidence produces the same score.
- The gap register tells the team what to fix first.
- A blocked work item is a normal outcome: the question is recorded, one owner
  answer clears it, and a new run resumes from the checkpoint without losing
  budget or evidence history.

## 11. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [readiness-assessment.md](readiness-assessment.md) — the model
- [conformance-profiles.md](conformance-profiles.md) — profiles
- [adoption-guide.md](adoption-guide.md) — adoption path
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- [failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) — blocked
  and owner answer
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md)
  — runtime requirements
- [docs/README.md](../README.md) — documentation map
