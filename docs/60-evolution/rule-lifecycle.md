# Rule lifecycle

Status: Draft

## 1. Purpose

Rules rot. Without an owner, a version, a test, and a retirement path, the
control plane becomes a museum of stale constraints. This document defines the
lifecycle of a rule and the registry that keeps it honest.

## 2. Rule types

| Type | Examples |
| --- | --- |
| Policy | Deny a shell command, provider, or MCP server |
| Permission | Allow a role to edit a path or run a test |
| Evidence requirement | Require mutation or review for a risk tier |
| Review threshold | Minimum mutation score or coverage |
| Role contract | Allowed and denied actions for a role |
| Budget | Token, cost, time, or concurrency limit |
| Model routing | Model by risk tier or cost |

## 3. Rule record

| Field | Meaning |
| --- | --- |
| `id` | Stable rule identifier |
| `title` | Short description |
| `owner` | Person or role accountable |
| `version` | Semantic version |
| `status` | Draft, active, deprecated, retired |
| `rationale` | Why the rule exists |
| `scope` | Repositories, roles, risk tiers |
| `effectiveAt` | When it becomes active |
| `reviewAt` | When it must be reviewed |
| `evidence` | What proves compliance |
| `tests` | Positive and negative tests |
| `exceptions` | Active exceptions |
| `supersedes` | Rule or version it replaces |

## 4. Lifecycle

| State | Meaning | Enforced |
| --- | --- | --- |
| Draft | Proposed, under review | No |
| Active | Approved and enforced | Yes |
| Deprecated | Still enforced, removal scheduled | Yes |
| Retired | Removed from the runtime | No |

A rule moves forward one state at a time. A rule cannot be retired while an
active exception depends on it.

## 5. Change process

1. Open an issue with the rule and the reason.
2. Write the rule record and the tests.
3. Open a draft pull request.
4. Review the rule, the tests, and the migration.
5. Canary the change where possible.
6. Activate the rule and update the registry.
7. Announce the change to the adopters.

A rule change follows the same review and CI process as any other normative
change.

## 6. Precedence and conflicts

- The stricter rule wins.
- OpenCode policy precedence is managed, system, Console, global, project.
- A project cannot re-enable what a higher authority denied.
- A conflict that cannot be resolved by precedence leaves the work item
  `blocked`.
- A duplicate rule is consolidated, not left to drift.

## 7. Exceptions

An exception is a time-bound, owned deviation:

- names the rule and the scope
- names the owner and the justification
- names the compensating control
- has an expiry and a review date
- is visible in the trace and the readiness report
- cannot disable a red line
- is renewed only with a new review

A permanent exception is a rule change in disguise.

## 8. Testing

- Every rule has a positive test: the allowed action proceeds.
- Every rule has a negative test: the denied action is blocked.
- A threshold rule has a boundary test.
- A policy change runs a dry run against historical decisions.
- The tests are part of the pull request evidence.

## 9. Deprecation and retirement

- Announce the deprecation at least one minor release before removal.
- Name the replacement or the reason for removal.
- Keep the rule enforced until the removal date.
- Remove the rule and update the registry.
- Record the retirement in the release notes.
- A retired rule cannot be silently reintroduced; it needs a new record.

## 10. Rule registry

The registry lists:

| Field | Example |
| --- | --- |
| Rule ID | `RULE-001` |
| Version | `1.2.0` |
| Status | `active` |
| Owner | `security-owner` |
| Review date | `2027-01-31` |
| Replacement | `RULE-014` |

The planned location is `rules.yaml` or a section of `mycelia.yaml`. Until the
schema exists, the registry is a table in the readiness report.

## 11. Metrics

- active rules by type
- active exceptions and expired exceptions
- overdue reviews
- rule violations
- rule age
- rules retired per release

## 12. Anti-patterns

- An orphan rule with no owner.
- A rule with no test.
- A permanent exception.
- Duplicate or conflicting rules.
- A threshold that is never reviewed.
- A deprecation with no replacement or date.
- A retired rule that reappears without a record.
- A registry that is not updated.

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [policy-as-code.md](../20-control/policy-as-code.md) — policy model
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [decision-rights.md](../20-control/decision-rights.md) — decision rights
- [evaluation-and-model-change.md](evaluation-and-model-change.md) — evaluations
- [concern-radar.md](../00-foundations/concern-radar.md) — concerns
- [docs/README.md](../README.md) — documentation map
