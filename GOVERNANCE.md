# Governance

This document defines who may change the specification, how a change is
approved, and how rules and exceptions are maintained.

## Owner

The repository maintainer is the specification owner. Security requirements
have a security owner. Adopters own their local profile, policies, and
exceptions; they do not inherit an approval from this repository.

## Decision rights

| Change | Decision | Approver |
| --- | --- | --- |
| Editorial correction | Merge | Maintainer |
| New or changed normative requirement | Accept | Maintainer and independent review |
| Security requirement | Accept | Security owner and maintainer |
| New concern in the radar | Record | Maintainer |
| Exception | Grant | Rule owner and maintainer, time-bound |
| Breaking change | Accept | Maintainer and independent review, major version |
| Autonomy promotion | Approve | Maintainer and assessor evidence |

A reviewer can block a change. A block is resolved by evidence, a narrower
scope, or an explicit maintainer decision recorded in the pull request.

## Change process

1. Open an issue in the current `vX.Y.Z` milestone.
2. Open a draft pull request and link the issue with `Closes #N`.
3. For a normative, security, or breaking change, request an independent
   review.
4. Run the checks: `mise run lint`, `mise run lint:config`, and
   `mise run lint:actions` when workflows change.
5. Mark the pull request ready only when every required check is green.
6. Squash merge. The pull request title becomes the commit on `main`.
7. Close the milestone at 100 percent to create the release.

## Versioning

The project uses Semantic Versioning.

- A requirement ID is stable after it becomes normative.
- A clarification that does not change the obligation is a patch.
- A new requirement, or a stricter obligation, is a minor release.
- A removal, a semantic change, or a change that invalidates a conformance
  claim is a major release.
- A deprecated requirement remains documented for at least one minor release
  before removal.
- Release notes list added, changed, deprecated, and removed requirements.

## Review cadence

Review the specification:

- quarterly, together with the concern radar
- after an incident or a near miss
- after a model, provider, or policy change
- after a major OpenCode release
- before raising a repository's autonomy level

The review records its scope, findings, and dispositions. An empty review is
not a review.

## Decision records

A decision that changes a trade-off or a boundary needs an Architecture
Decision Record (ADR):

- context: the problem and the forces
- decision: the chosen option
- consequences: what becomes easier and what becomes harder
- status: proposed, accepted, superseded, or rejected

The planned location is `docs/00-foundations/decisions/`. Until the directory
exists, the pull request description holds the record.

## Rule lifecycle

Every rule and policy moves through four states:

1. **Draft** — proposed, not enforced.
2. **Active** — enforced by the runtime and checked by the assessment.
3. **Deprecated** — still enforced, scheduled for removal.
4. **Retired** — removed and recorded in the release notes.

Each rule has an owner, a rationale, an effective date, and a review date. A
rule change follows the same issue, draft pull request, review, and merge
process as any other normative change.

## Exceptions

An exception is a time-bound, owned deviation from a rule.

- The record names the rule, the scope, the owner, and the justification.
- The record names the compensating control.
- The record has an expiry date.
- Renewal requires a new review.
- The exception is visible in the trace and the readiness report.
- A permanent exception is not allowed; change the rule instead.

## Conflict resolution

- The stricter rule wins.
- OpenCode policy precedence is: managed configuration, system configuration,
  connected Console workspace, global configuration, project configuration.
- A policy conflict that cannot be resolved by precedence leaves the work item
  in `blocked`; it never becomes a silent override.
- A spec conflict is resolved in favor of the requirement that protects
  evidence, safety, or human oversight.

## Audit

`AUDIT.md` (planned) records the audit method, findings, dispositions, and
limitations. The audit is evidence-based. It is not a certification and does
not transfer an approval to an adopter.

## Concern radar

[The concern radar](docs/00-foundations/concern-radar.md) is the living
catalog of industry concerns. Each entry has a status: adopted, adapted,
watch, or out of scope. A new keyword or framework is recorded there before it
changes the specification.

## Related documents

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [GLOSSARY.md](GLOSSARY.md) — terminology
- [AGENTS.md](AGENTS.md) — operating contract
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution guide
- [docs/README.md](docs/README.md) — documentation map
