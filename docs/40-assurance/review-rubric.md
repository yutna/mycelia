# Review rubric and independent review

Status: Draft

## 1. Purpose

Review is the control that catches what tests miss. A rubric makes review
consistent; independence makes it trustworthy. This document defines both, plus
the review record.

## 2. Independence

| Risk | Minimum independence |
| --- | --- |
| R0 | CI and sampling |
| R1 | CI and review |
| R2 | Independent context |
| R3 | Independent context and a different model or a human |
| R4 | Human and security review |

Rules:

- The author does not review its own change.
- The reviewer sees the diff, the work item, and the evidence.
- The reviewer does not see the author's private reasoning.
- The reviewer runs in a separate session or a separate model.
- A human reviews R3 and R4 even when an agent reviewed first.

## 3. Inputs

The reviewer reads:

- the work item and acceptance criteria
- the diff
- the evidence manifest and results
- the test-integrity report
- the policy decisions
- the trace for the run
- the rollback plan

A review without the evidence is a style check, not an assurance check.

## 4. Rubric dimensions

| Dimension | What to check | Blocking for |
| --- | --- | --- |
| Correctness | Acceptance criteria met; no regression; edge cases | R1-R4 |
| Scope | Only the issue; no unrelated change | R1-R4 |
| Test quality | Meaningful tests; mutation; no weakening | R2-R4 |
| Security | Secrets, injection, permissions, data class | R1-R4 |
| Readability | Names, structure, comments, docs | R2-R4 |
| Reversibility | Rollback, feature flag, migration plan | R2-R4 |
| Evidence | Manifest satisfied; trace complete | R2-R4 |
| Performance | Budget met; no regression | R2-R4 when relevant |
| Observability | Logs, metrics, traces | R2-R4 when relevant |
| Docs | Updated for behavior change | R1-R4 when relevant |

Each dimension is `pass`, `fail`, or `not-applicable`. A blocking dimension that
is `fail` blocks the merge. A `not-applicable` must be justified.

## 5. Severity

| Severity | Meaning | Action |
| --- | --- | --- |
| Blocker | A correctness, security, or evidence failure | Fix before merge |
| Major | A significant gap or risk | Fix or record a time-bound exception |
| Minor | A quality issue | Fix or follow up |
| Nit | A preference | Optional |

Only a blocker prevents the merge. A major issue prevents the merge unless the
human owner grants an exception.

## 6. Decision

| Decision | Meaning |
| --- | --- |
| `approve` | No blocking findings; the change may proceed |
| `request-changes` | Findings must be addressed before approval |
| `reject` | The change should not proceed; a new work item is needed |

A decision is recorded with the findings, the evidence, and the reviewer's
identity.

## 7. Process

1. Read the work item and acceptance criteria.
2. Read the diff, not only the summary.
3. Check the evidence manifest and the trace.
4. Check the test diff and the integrity report.
5. Re-run or verify the key checks when needed.
6. Apply the rubric.
7. Write findings with file and line references.
8. Record the decision.
9. Hand off to acceptance or back to the implementer.

## 8. LLM-as-judge

An agent reviewer is useful, but it has biases:

- position bias: the first option looks better
- verbosity bias: longer answers look better
- self-preference: the same model prefers its own style
- sycophancy: the model agrees with the author

Mitigations:

- Use a different context from the author.
- For R3 and R4, use a different model or a human.
- Use the rubric, not free-form judgment.
- Blind the reviewer to the author's reasoning.
- Calibrate on a small set of known-good and known-bad changes.
- Sample and compare with human review.
- Record the model, version, and prompt version.

An LLM review is evidence, not a substitute for human accountability.

## 9. Review record

The record contains:

- the commit
- the reviewer and role
- the independence level
- the dimension results
- the findings with severity, file, and line
- the decision
- the timestamp and trace event

## 10. Anti-patterns

- Rubber-stamping.
- A style-only review.
- Reviewing your own work.
- Blocking without a reason.
- Reviewing without the evidence.
- Expanding the scope during review.
- Using an LLM as the only reviewer for R3 or R4.
- Reviewing the summary instead of the diff.
- A review record with no decision.

## 11. Data contract

- Schema: [schemas/review-record.schema.json](../../schemas/review-record.schema.json)
- Example: [examples/review-record.example.yaml](../../examples/review-record.example.yaml)

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [threat-model.md](../00-foundations/threat-model.md) — threats
- [verification-stack.md](verification-stack.md) — checks
- [test-integrity.md](test-integrity.md) — mutation and test weakening
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [decision-rights.md](../20-control/decision-rights.md) — acceptance
- `human-acceptance.md` — acceptance harness (planned)
- [docs/README.md](../README.md) — documentation map
