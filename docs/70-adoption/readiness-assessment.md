# Readiness assessment

Status: Draft

## 1. Purpose

This is the question the whole specification exists to answer: what does this
repository lack for safe autonomy, and what should be fixed first? The
assessment scores 24 controls, computes the autonomy ceiling, and produces a
gap register with owners and remediation.

## 2. Principles

- Evidence-based: a control without evidence is unproven.
- Deterministic: the same repository and evidence produce the same score.
- No self-report: a claim in a document is not evidence.
- Weakest link: one unmet blocking control caps the ceiling.
- Independent: the assessor is read-only and separate from the implementer.
- Reassessed: a score expires when the repository or the policy changes.

## 3. Domains and controls

| ID | Domain | Question | Evidence |
| --- | --- | --- | --- |
| `CTL-01` | Repository legibility | Is there a repository map, canonical commands, and a pinned toolchain? | `mise.toml`, README, clean-clone check |
| `CTL-02` | Work intake | Is there a work item with goal, acceptance criteria, risk tier, and evidence? | Work item schema and a real item |
| `CTL-03` | Ownership | Is there an owner and an escalation path? | `CODEOWNERS` or ownership table |
| `CTL-04` | Instructions | Is `AGENTS.md` current and consistent with `CONTRIBUTING.md`? | Instruction files and a link check |
| `CTL-05` | References and skills | Are references and skills pinned and reviewed? | Pins, review dates |
| `CTL-06` | Memory | Is compaction and durable memory governed? | Config, memory policy |
| `CTL-07` | Role contracts | Does every role have allowed and denied actions? | Role contracts |
| `CTL-08` | Least privilege | Are permissions and policies enforced by the runtime? | Config, negative tests |
| `CTL-09` | Identity and secrets | Is the agent identity separate, and are secrets denied? | Bot account, policy, trace |
| `CTL-10` | Policy red lines | Are destructive actions hard-denied? | Policy file and tests |
| `CTL-11` | Evidence manifest | Is the definition of done machine-readable? | Manifest and gate result |
| `CTL-12` | Decision rights | Is acceptance allocated by risk tier? | Decision matrix and records |
| `CTL-13` | Durable loop | Is state checkpointed and resumable? | Run state, resume test |
| `CTL-14` | Failure protocol | Is ambiguity blocked and failure classified? | Failure taxonomy, drill |
| `CTL-15` | Budgets and stop | Are budgets enforced and is the kill switch tested? | Limits, kill-switch drill |
| `CTL-16` | Concurrency | Are worktrees and ownership used? | Worktree record, lock policy |
| `CTL-17` | Merge queue | Is integration serialized and tested on the merged result? | Queue config, CI result |
| `CTL-18` | Rollback | Is there a tested rollback path? | Rollback plan and drill |
| `CTL-19` | Verification stack | Are the required checks layered and deterministic? | CI jobs, flake rate |
| `CTL-20` | Test integrity | Are mutation and test-diff guards enforced? | Mutation report, guard |
| `CTL-21` | Independent review | Is review separate and rubric-based? | Review record |
| `CTL-22` | Human acceptance | Is acceptance sampled by risk? | Acceptance record |
| `CTL-23` | Trace and provenance | Are trace and provenance complete and tamper-evident? | Trace export, hash chain |
| `CTL-24` | Metrics and evolution | Are health, evaluations, and incident drills in place? | Metrics, eval record, drill |

## 4. Scoring

| Score | Meaning |
| --- | --- |
| 0 | Absent: no artifact or practice |
| 1 | Manual: documented but ad hoc and human-dependent |
| 2 | Defined: documented, applied, and partly automated |
| 3 | Automated and evidenced: enforced by the runtime or CI, with current evidence and an audit sample |

Rules:

- A score requires evidence. Self-report is not evidence.
- Evidence must be current within the declared review window.
- A control with a missing prerequisite is capped at the prerequisite's score.
- The assessor records the evidence references, not only the number.
- A score of 3 requires at least one audit sample.

## 5. Gates and ceiling

| Level | Required controls |
| --- | --- |
| L1 | `CTL-01`-`CTL-04`, `CTL-07`, `CTL-08`, `CTL-10`-`CTL-14` at 2 or higher |
| L2 | L1 plus `CTL-05`, `CTL-06`, `CTL-09`, `CTL-15`-`CTL-17`, `CTL-19`, `CTL-21` at 2 or higher |
| L3 | L2 plus `CTL-20`, `CTL-22`, `CTL-23`, `CTL-24` at 3 or higher |
| L4 | L3 plus `CTL-15`, `CTL-16`, `CTL-17`, `CTL-23`, `CTL-24` at 3 or higher, and the incident and concurrency drills passed |

The assessment computes the ceiling:

1. Start at L4.
2. If any L4 gate is unmet, lower the ceiling to L3.
3. If any L3 gate is unmet, lower the ceiling to L2.
4. If any L2 gate is unmet, lower the ceiling to L1.
5. If any L1 gate is unmet, the ceiling is L0.
6. The highest level whose gates are all met is the ceiling.

The recommended level is the highest level supported by evidence. It is
normally equal to the ceiling; it is lower when a human owner chooses to run
below the ceiling.

## 6. Gap register

Every control below its required score produces a gap:

| Field | Meaning |
| --- | --- |
| `controlID` | The control |
| `severity` | `blocker` if it caps the target level; `major` if it blocks the next level; `minor` otherwise |
| `finding` | What is missing |
| `remediation` | The smallest action that raises the score |
| `owner` | Who fixes it |
| `effort` | An estimate |

Sort the register by severity. Fix blockers first; a long list of minors does
not raise the ceiling while a blocker remains.

## 7. Assessment process

1. Collect the repository, commit, config, CI results, evidence, traces, and
   policies.
2. Verify that each artifact exists and is current.
3. Score each control with evidence references.
4. Check the gates.
5. Compute the ceiling.
6. Write the gap register.
7. Review the report with the owner.
8. Record the report.
9. Reassess after the remediation.

## 8. Assessor independence

- The assessor is read-only.
- The assessor uses a separate context from the implementer.
- An L3 or L4 claim needs a human review of the evidence.
- A promotion cannot rely on the implementer's self-assessment.
- The assessor declares conflicts of interest.

## 9. Reassessment

Reassess:

- after the remediation of a blocker
- quarterly
- after an incident
- after a model, provider, or policy change
- before an autonomy promotion

An expired report is not evidence.

## 10. Report

The report contains:

- repository, commit, time, and assessor
- profile and recommended level
- the ceiling
- the 24 control scores with evidence
- the gap register
- notes and limitations

## 11. Anti-patterns

- Self-report as evidence.
- Scoring from documentation only.
- Averaging scores instead of checking gates.
- Ignoring a blocker because the average is high.
- Stale evidence.
- An assessor with write access.
- A report with no owner.
- A promotion without a reassessment.

## 12. Data contract

- Schema: [schemas/readiness-report.schema.json](../../schemas/readiness-report.schema.json)
- Example: [examples/readiness-report.example.yaml](../../examples/readiness-report.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and ceiling
- [repository-legibility.md](../10-context/repository-legibility.md) — legibility
- [work-intake.md](../10-context/work-intake.md) — work item
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [autonomous-loop.md](../30-execution/autonomous-loop.md) — loop
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — runtime
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- `conformance-profiles.md` — profiles (planned)
- `worked-example.md` — example (planned)
- [docs/README.md](../README.md) — documentation map
