# Decision rights and human oversight

Status: Draft

## 1. Purpose

Evidence only matters if someone with the right authority accepts it. Decision
rights define who decides what, how human oversight is allocated, and how the
system prevents both unmanaged autonomy and rubber-stamping.

## 2. Decision classes

| Class | Examples | Default authority |
| --- | --- | --- |
| Editorial | Typo, formatting, link fix | Maintainer |
| Normative | New or changed requirement | Maintainer and independent review |
| Security | Security requirement or finding | Security owner and maintainer |
| Breaking | Removal or semantic change | Maintainer and independent review, major version |
| Exception | Time-bound deviation from a rule | Rule owner and maintainer |
| Autonomy promotion | Raise the repository ceiling | Human owner, with assessor evidence |
| Autonomy demotion | Lower the ceiling after an incident | Security owner or maintainer triggers; human owner confirms |
| Incident command | Contain, revert, communicate | Human owner or delegate |
| Release | Tag and publish | Maintainer; human owner for R3/R4 |
| Risk tier | Assign R0-R4 to a work item | Planner proposes; human owner confirms R3/R4 |

## 3. Decision matrix

| Decision | Proposer | Approver | Consulted | Informed |
| --- | --- | --- | --- | --- |
| Editorial change | Contributor or agent | Maintainer | None | None |
| Normative change | Maintainer | Maintainer and independent reviewer | Adopters | Contributors |
| Security change | Security owner | Security owner and maintainer | Human owner | Contributors |
| Breaking change | Maintainer | Maintainer and independent reviewer | Adopters | Contributors |
| Exception | Rule owner | Rule owner and maintainer | Security owner for security rules | Auditors |
| Autonomy promotion | Assessor | Human owner | Security owner | Contributors |
| Autonomy demotion | Security owner or maintainer | Human owner | Security owner | Contributors |
| Incident command | On-call human | Human owner or delegate | Security owner | Stakeholders |
| Release | Integrator | Maintainer | Human owner for R3/R4 | Users |
| R3 acceptance | Implementer and reviewer | Human owner | Security owner | Auditors |
| R4 sign-off | Implementer and reviewer | Human owner and security owner | Auditors | Stakeholders |

## 4. Human oversight models

| Model | Meaning | Typical level |
| --- | --- | --- |
| Human in the loop (HITL) | A human approves a specific action before it happens | L1, L2, R3/R4 at L3/L4 |
| Human on the loop (HOTL) | A human monitors sampling and can intervene | R0-R2 at L3/L4 |
| Human in command (HIC) | A human owns policy, accountability, and incident command | Always |

HITL is not the same as HIC. A human can approve many low-risk actions and
still not be in command of the policy. Mycelia requires both: HIC always, HITL
or HOTL by risk.

## 5. Risk-based approval

| Risk | Approval |
| --- | --- |
| R0 | Automated gate; human sampling |
| R1 | Automated gate plus reviewer |
| R2 | Independent reviewer |
| R3 | Human acceptance |
| R4 | Human sign-off plus security review |

The approval requirement matches the autonomy matrix in
[autonomy-levels.md](../00-foundations/autonomy-levels.md). An agent cannot
approve an R3 or R4 change for itself.

## 6. Approval fatigue

Human attention is finite. The system must protect it:

- Route only R3 and R4 to a human by default; sample R0-R2.
- Cap the human review queue with a WIP limit.
- Provide an acceptance packet: summary, diff, evidence, risk, rollback, open
  questions.
- Give the reviewer a time budget; if it cannot be met, block the work instead
  of rubber-stamping it.
- Rotate reviewers where possible.
- Measure review time, override rate, and false acceptance rate.
- Escalate when the queue exceeds capacity.
- Never set an approval quota that rewards speed over evidence.

## 7. Escalation and blocked state

A blocked decision reports:

- the precise question
- the options and their consequences
- the owner who can answer
- the blocking condition
- the work already completed
- the evidence already collected

The agent cannot approve its own escalation. The answer is recorded in the
trace and becomes part of the work item.

## 8. Break-glass

Break-glass is emergency access for an incident or a critical fix.

- It requires an owner, a reason, a scope, and an expiry.
- It is recorded before or immediately after use.
- It cannot disable the trace, the audit record, or the evidence requirement
  for R3 and R4.
- A second person reviews it where the team has one; a solo maintainer records
  it and schedules a post-incident review.
- The post-incident review happens before the next release.
- Break-glass is not an exception for routine work.

## 9. Decision record

Every non-trivial decision records:

- who decided, and in which role
- the decision and the alternatives considered
- the evidence relied on
- the conditions and the expiry, for exceptions
- the timestamp
- the trace event or issue link

The record is part of the audit trail. A decision without a record is a
missing control.

## 10. Separation of duties

- The author and the verifier are different actors for R2 and above.
- The approver is not the author for R3 and R4.
- The security review for R4 is independent.
- A single agent cannot hold both the implementer and reviewer role for R2 and
  above.
- The reviewer sees the diff and the evidence, not the author's private
  reasoning.

## 11. Delegation

- The human owner may delegate R0-R2 approval to an agent at L3 or L4 when the
  policy allows it.
- R3 and R4 approval is not delegated to an agent.
- A delegation is recorded, scoped, and time-bound.
- The delegate cannot approve its own work.
- The human owner remains accountable.

## 12. Anti-patterns

- A 100 percent manual review queue that everyone rubber-stamps.
- An agent approving its own change.
- A security owner bypassed for an R4 change.
- Break-glass used as the normal path.
- An approval with no evidence.
- A decision with no record of who made it.
- A queue so long that review time is measured but ignored.
- Delegating R3 or R4 to an agent.

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- [policy-as-code.md](policy-as-code.md) — policy model
- [evidence-manifest.md](evidence-manifest.md) — definition of done
- `human-acceptance.md` — acceptance packet and sampling (planned)
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [docs/README.md](../README.md) — documentation map
