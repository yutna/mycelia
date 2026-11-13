# Incident response

Status: Draft

## 1. Purpose

Autonomy changes the incident surface. An agent can leak a secret, weaken a
test, merge a bad change, or exhaust a budget faster than a human. The factory
needs a practiced response, not an improvised one.

## 2. Severity

| Severity | Criteria | Response |
| --- | --- | --- |
| SEV1 | Active data loss, secret exposure, security breach, or full outage | Immediate; incident commander; all hands |
| SEV2 | Major degradation, contained security issue, or a release that must be rolled back | Within the hour |
| SEV3 | Limited impact, one repository or one role, workaround exists | Same day |
| SEV4 | Near miss or no impact | Next business day |

Severity can rise as information arrives. It rarely falls without evidence.

## 3. Roles

| Role | Responsibility |
| --- | --- |
| Incident commander | Owns the response and the decisions |
| Operations lead | Runs containment and recovery |
| Security lead | Leads security investigation |
| Communications lead | Internal and external updates |
| Scribe | Timeline, actions, and evidence |
| Subject-matter expert | Repairs the specific system |

One person may hold several roles in a small team. The commander is always a
human.

## 4. Lifecycle

```text
detect -> triage -> contain -> eradicate -> recover -> postmortem
```

Each step records a timestamp, an owner, and the evidence.

- **Detect.** Alert, report, or audit finding.
- **Triage.** Assign severity, commander, and roles.
- **Contain.** Stop the spread: kill switch, revoke credentials, quarantine a
  component, roll back a release.
- **Eradicate.** Remove the cause.
- **Recover.** Restore service and verify.
- **Postmortem.** Learn and change the system.

## 5. Playbooks

### Prompt injection or policy bypass

- Stop the session.
- Preserve the trace.
- Identify the source: repo, issue, web, MCP, or tool.
- Quarantine the source.
- Add a regression test and a policy rule.

### Secret leak

- Revoke and rotate the secret.
- Audit its use.
- Remove it from logs and traces.
- Notify the owner.
- Add a secret-scan test.

### Malicious MCP server, plugin, or skill

- Disable the component.
- Remove it from the allowlist.
- Rotate credentials.
- Review other repositories that used it.
- Add a supply-chain check.

### Runaway agent or budget exhaustion

- Trigger the kill switch.
- Interrupt the session.
- Revoke the credentials.
- Preserve the trace.
- Lower the budget or the autonomy ceiling.

### Bad release

- Stop the rollout.
- Roll back to the previous artifact.
- Disable the feature flag.
- Verify the recovery.
- Record the release and rollback.

### Data corruption

- Stop writes.
- Restore from the tested backup or run the down migration.
- Reconcile the data.
- Verify the invariants.
- Record the recovery.

### Trace gap

- Stop high-risk work.
- Restore the trace from the buffer or backup.
- Mark the affected runs unproven.
- Re-run the evidence if possible.
- Record the gap.

## 6. Kill switch and break-glass

- The kill switch stops the run, revokes credentials, disables the component,
  and preserves the trace.
- Break-glass is time-bound, owned, and recorded.
- Break-glass cannot disable the trace or the evidence requirement for R3/R4.
- The post-incident review happens before the next release.

## 7. Communication

- Use one internal channel and one status owner.
- Update at a fixed cadence until resolved.
- State what is known, what is not known, and when the next update will be.
- Do not speculate about cause or blame.
- External communication for a security or data incident goes through the
  owner and legal review.

## 8. Postmortem

A postmortem is blameless and evidence-based:

- timeline
- impact
- root cause and contributing factors
- detection and response
- what worked and what did not
- actions with owners and due dates

A postmortem without an action is incomplete.

## 9. Feedback

Every incident updates at least one of:

- a policy or permission rule
- a regression test
- an evaluation task
- a runbook
- the threat model
- the concern radar
- the readiness assessment

## 10. Incident record

The record contains:

- severity and category
- status
- commander
- detection time
- summary
- containment
- postmortem link
- actions with owners and due dates
- trace reference

## 11. Anti-patterns

- No incident commander.
- Blame instead of system change.
- No timeline.
- No containment before root cause.
- No postmortem.
- A postmortem with no action.
- Ignoring a near miss.
- Disabling the trace to "move faster".
- External communication without review.

## 12. Data contract

- Schema: [schemas/incident-record.schema.json](../../schemas/incident-record.schema.json)
- Example: [examples/incident-record.example.yaml](../../examples/incident-record.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — threats
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — demotion
- [decision-rights.md](../20-control/decision-rights.md) — break-glass
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — containment
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — kill switch
- [adversarial-and-resilience.md](../40-assurance/adversarial-and-resilience.md) — drills
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- `economics.md` — cost (planned)
- [docs/README.md](../README.md) — documentation map
