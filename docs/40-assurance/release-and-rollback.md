# Release and rollback assurance

Status: Draft

## 1. Purpose

A merge is not a release. This document defines the release gate, progressive
delivery, rollback triggers, the tested rollback path, and post-release
verification. It is the assurance that a released change can be trusted and
undone.

## 2. Release types

| Type | Examples | Extra gate |
| --- | --- | --- |
| Documentation | Specs, guides, links | Link check, version tag |
| Library or package | npm, pip, container image | Package integrity, provenance |
| Service | API, worker, web app | Canary, SLO, rollback |
| Model or provider | Model version, route, prompt | Evaluation, fallback |
| Policy or configuration | Permissions, policies, flags | Policy test, staged rollout |
| Agent profile | Agents, commands, skills | Config validation, canary |

## 3. Release gates

| Gate | Requirement |
| --- | --- |
| Evidence | The release evidence manifest is satisfied |
| Security | No critical or high finding; review for R3/R4 |
| Provenance | The artifact and source are attested |
| Rollback | The rollback plan is tested |
| Human | Sign-off for R3/R4 |
| Notes | Release notes are generated or written |

A failed gate holds the release. There is no "ship and fix later" for a failed
security or rollback gate.

## 4. Release process

1. The version milestone reaches 100 percent.
2. The release preflight checks version files and artifacts.
3. The tag is created on the default branch.
4. The release notes are generated from merged changes.
5. The publish job uploads the artifact.
6. The smoke test runs against the released artifact.
7. The release record is written.
8. The observation window starts.

The repository uses milestone closure as the release trigger. The release is
not a separate manual step unless the project has a publish job.

## 5. Progressive delivery

| Technique | Use | Control |
| --- | --- | --- |
| Canary | A small traffic share gets the new version | Error rate, latency, SLO burn |
| Feature flag | Incomplete behavior stays off | Owner, expiry, default off |
| Blue-green | Instant switch between two environments | Health check, switch back |
| Dark launch | Real load without user impact | Compare results, no side effects |
| Ring deployment | Internal, beta, then general | Ring promotion criteria |

A canary without a metric is a delay, not a control. A feature flag without an
owner and an expiry is technical debt.

## 6. Rollback

Triggers:

- error rate or latency above the threshold
- SLO error budget burn
- security finding
- data corruption or inconsistency
- user report of a critical regression
- failed smoke test

Plan:

- revert the release commit or deploy the previous artifact
- disable the feature flag
- restore the data from a tested backup or run the down migration
- communicate to the owners and users
- record the rollback in the trace and the release record

The rollback must be possible within the observation window. An untested
rollback is not a control.

## 7. Post-release verification

- Run a smoke test against the released artifact.
- Watch error rate, latency, and saturation for the observation window.
- Check the error budget and the cost budget.
- Read the user report channel.
- Compare the canary with the baseline.
- Close the release or roll back.

The observation window depends on the risk tier:

| Risk | Window |
| --- | --- |
| R0 | Link check |
| R1 | One CI run |
| R2 | One hour |
| R3 | One day |
| R4 | One week or the agreed window |

## 8. Release record

The record contains:

- the version and commit
- the risk tier
- the gate results
- the rollback plan and whether it was tested
- the decision: release, hold, or rollback
- the timestamp
- the trace event

## 9. Anti-patterns

- Treating a merge as a release.
- No rollback plan.
- An untested rollback.
- A canary with no metric.
- A feature flag with no owner or expiry.
- Releasing without on-call coverage.
- Ignoring post-release metrics.
- A tag with no release notes.
- A security exception without an owner.

## 10. Data contract

- Schema: [schemas/release-record.schema.json](../../schemas/release-record.schema.json)
- Example: [examples/release-record.example.yaml](../../examples/release-record.example.yaml)

## 11. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [change-lifecycle.md](../30-execution/change-lifecycle.md) — merge and release
- [verification-stack.md](verification-stack.md) — checks
- [test-integrity.md](test-integrity.md) — mutation
- [review-rubric.md](review-rubric.md) — review
- [human-acceptance.md](human-acceptance.md) — acceptance
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- `incident-response.md` — incident (planned)
- [docs/README.md](../README.md) — documentation map
