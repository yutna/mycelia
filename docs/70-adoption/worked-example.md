# Worked example

Status: Draft

## 1. Purpose

Show the readiness model working end to end: a synthetic repository, a baseline
assessment, the autonomy ceiling, a gap register, a remediation plan, and a
reassessment. The numbers are illustrative, but the method is the one the
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

## 9. What the example demonstrates

- A repository can have tests and CI and still be at L0.
- Legibility and control raise the ceiling faster than a better model.
- L3 needs evidence depth, not more documentation.
- The method is deterministic: the same evidence produces the same score.
- The gap register tells the team what to fix first.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [readiness-assessment.md](readiness-assessment.md) — the model
- [conformance-profiles.md](conformance-profiles.md) — profiles
- [adoption-guide.md](adoption-guide.md) — adoption path
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- [docs/README.md](../README.md) — documentation map
