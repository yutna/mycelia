# Human acceptance harness

Status: Draft

## 1. Purpose

The last line of defense is a human who can see the evidence and decide. This
document defines when a human must accept, what they receive, how sampling
works, how the decision is recorded, and how trust is calibrated.

## 2. When human acceptance is required

| Risk | Acceptance |
| --- | --- |
| R0 | Automated gate; sample |
| R1 | Automated gate and review; sample |
| R2 | Independent review; sample at L3/L4 |
| R3 | Human acceptance, always |
| R4 | Human acceptance and security sign-off, always |

A policy change, a model change, or an autonomy promotion also requires human
acceptance, regardless of the risk tier.

## 3. Acceptance packet

The acceptor receives:

- the work item and acceptance criteria
- a diff summary and the files changed
- the evidence manifest and results
- the test-integrity report
- the review record and findings
- the risk tier and affected areas
- the rollback plan
- open questions and known limitations
- the cost and budget used
- a recommended decision

The packet is a summary, not a replacement for the diff. The acceptor can open
the diff and the trace.

## 4. Sampling

- R3 and R4 are always human-reviewed.
- R0-R2 are sampled at L3 and L4.
- Sampling is random and risk-weighted; record the selection method and the
  seed.
- Set a minimum sample per milestone.
- If a sample fails, expand the sample and lower the autonomy ceiling until the
  cause is fixed.
- A sample that passes does not prove the unsampled changes are correct; it is
  evidence, not a guarantee.

## 5. Sign-off

A sign-off records:

- who accepted, and in which role
- what was reviewed
- the decision
- any conditions
- the timestamp
- the trace event

A sign-off without the evidence reviewed is not a sign-off.

## 6. Decisions

| Decision | Meaning | Next state |
| --- | --- | --- |
| `accept` | The change may proceed | `merging` |
| `revise` | The change needs work | `implementing` |
| `block` | The change must not proceed | `blocked` or `rejected` |

A `revise` decision includes the findings and the owner. A `block` decision
includes the reason and the escalation path.

## 7. Rework loop

- Record a reason code: correctness, scope, test quality, security, evidence,
  performance, or documentation.
- Feed the reason into the evaluation suite and the rule lifecycle.
- Track the rework rate by reason and by role.
- A repeated reason is a system problem, not an individual problem.
- A rework that changes the work item requires a new acceptance.

## 8. Trust calibration

Track:

- sample failure rate
- false acceptance rate
- human override rate
- review time per risk tier
- rework rate
- escaped defects

If false acceptance rises, lower the autonomy ceiling or increase the sample.
If the override rate falls and the sample passes, consider promotion only with
a readiness report.

## 9. OpenCode mapping

| Need | OpenCode mechanism |
| --- | --- |
| Ask a precise question | `question` tool |
| Request approval | Permission prompt or form |
| Read the evidence | `read`, `git diff`, CI artifacts |
| Read the checks | `gh pr checks`, `gh pr view` |
| Record the decision | Acceptance record plus a pull request comment |
| Stop the run | `session.interrupt`, kill switch |

The acceptance record can be attached to the pull request or stored in the
repository's evidence directory.

## 10. Anti-patterns

- A 100 percent manual review queue.
- Rubber-stamping.
- An acceptance with no packet.
- Sampling that is not random.
- Accepting without a rollback plan.
- Ignoring a failed sample.
- No record of who accepted.
- Treating a sample as proof for the unsampled changes.

## 11. Data contract

- Schema: [schemas/acceptance-record.schema.json](../../schemas/acceptance-record.schema.json)
- Example: [examples/acceptance-record.example.yaml](../../examples/acceptance-record.example.yaml)

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [decision-rights.md](../20-control/decision-rights.md) — decision matrix
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [review-rubric.md](review-rubric.md) — review
- [verification-stack.md](verification-stack.md) — checks
- [test-integrity.md](test-integrity.md) — mutation
- `release-and-rollback.md` — release (planned)
- [docs/README.md](../README.md) — documentation map
