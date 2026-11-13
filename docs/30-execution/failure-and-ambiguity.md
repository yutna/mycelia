# Failure and ambiguity protocol

Status: Draft

## 1. Purpose

A reliable factory is defined by how it fails. Every failure needs a
classification, an allowed response, a retry limit, and a terminal state. Every
ambiguity needs a precise question, not a guess.

## 2. Failure taxonomy

| Class | Detection | Allowed response | Retries | Terminal |
| --- | --- | --- | --- | --- |
| Specification ambiguity | Intake or plan | Ask a precise question | 0 | `blocked` |
| Missing context | Plan or implement | Narrow the search or ask | 1 | `blocked` |
| Product test failure | Verify | Return to implementing | 2 | `blocked` or `rejected` |
| Flaky check | Verify | Re-run once, then quarantine | 1 | `blocked` |
| Policy violation | Any state | Stop and record | 0 | `aborted` |
| Permission denial | Any state | Ask for a policy decision or stop | 0 | `blocked` or `aborted` |
| Budget exhaustion | Any state | Stop | 0 | `aborted` |
| Transient tool failure | Any state | Retry with backoff | 3 | `aborted` or `blocked` |
| Model or provider failure | Any state | Retry or fall back | 2 | `aborted` |
| Merge conflict | Merging | Rebase or re-implement | 2 | `blocked` |
| Security finding | Verify or review | Reject and open an incident | 0 | `rejected` |
| Missing or stale evidence | Verify | Reproduce or ask | 0 | `blocked` |
| Human rejection | Accepting | Reject | 0 | `rejected` |
| Unknown | Any state | Stop | 0 | `blocked` |

## 3. Failure classes

### Specification ambiguity

The goal, acceptance criteria, risk tier, data class, or approval is unclear or
contradictory. The loop stops at `intake` or `planned` and asks.

### Missing context

The agent cannot find the file, command, or decision it needs. It may narrow the
search once. If the context is still missing, it asks.

### Product test failure

A test fails because the change is wrong. The loop returns to `implementing`
with the failing output. After the retry limit, the run is `blocked` or
`rejected`.

### Flaky check

A check fails for infrastructure or nondeterminism. Re-run once, then quarantine
the check with an owner. A flaky check is never a pass.

### Policy violation

A tool call or change violates a policy. Stop immediately, record the decision,
and end in `aborted`. A policy violation is not a retry.

### Permission denial

A permission rule denies an action. The agent may ask for a policy decision; it
may not work around the rule. If no decision arrives, the run is `blocked`.

### Budget exhaustion

A step, time, token, cost, or tool-call limit is reached. Stop and end in
`aborted`. A human may grant a new budget in a new run.

### Transient tool failure

A network, registry, or service error that is likely temporary. Retry with
backoff, up to three times. The retry must be idempotent.

### Model or provider failure

A timeout, rate limit, refusal, or provider error. Retry once or fall back to an
approved model. A refusal is not bypassed with a different model unless the
policy allows that route.

### Merge conflict

The base branch changed. Rebase or re-implement, up to two times. If the
conflict is semantic, ask.

### Security finding

A scan or review finds a vulnerability. Reject the change and open an incident.
Do not retry with a weaker check.

### Missing or stale evidence

The evidence manifest is not satisfied, or the evidence belongs to another
commit. Reproduce the evidence or ask. Do not mark it as pass.

### Human rejection

A human rejects the change. The run ends in `rejected` with the reason.

### Unknown

If the failure does not match a class, stop and ask. An unknown failure is not
a retry candidate.

## 4. Retry policy

- Retry only transient and product failures.
- Use the retry limits in the taxonomy.
- Use backoff between attempts.
- Record the attempt number and the reason.
- Keep the same work item and commit context.
- Make every retry idempotent.
- After the limit, end in `blocked` or `aborted`.
- Never retry a policy, security, ambiguity, or budget failure.

## 5. Ambiguity protocol

Ambiguity is detected when:

- the goal cannot be stated without assuming something
- acceptance criteria contradict each other
- the risk tier or data class is unknown
- the required approval is missing
- two authoritative sources conflict
- the change would violate a non-goal

The protocol:

1. Stop the run; do not choose silently.
2. Write the precise question.
3. List the options and their consequences.
4. Name the owner who can answer.
5. Record the question in the trace and the work item.
6. End in `blocked`.
7. Resume only after the answer is recorded.

A good question is specific and answerable:

- "Should this change preserve backward compatibility, or may it break the API?"
- "Which file is the source of truth: `schema.json` or `api.yaml`?"
- "Is this change R2 or R3? The work item touches authentication."

A bad question is vague:

- "What do you want?"
- "Is this okay?"

A recommendation is allowed, but it is not a decision.

## 6. Escalation ladder

1. **Self-check.** Reproduce the failure and confirm the classification.
2. **Retry.** Only for transient or product failures, within the limit.
3. **Narrow.** Reduce the scope without changing the intent.
4. **Ask.** Write the precise question and end in `blocked`.
5. **Abort.** Stop on policy, security, or budget.

Escalation targets:

| Role | Escalates to |
| --- | --- |
| Planner | Human owner |
| Implementer | Planner or human owner |
| Verifier | Maintainer |
| Reviewer | Human owner |
| Integrator | Maintainer or human owner |
| Security | Security owner |

## 7. Failure evidence

Every failure records:

- the failing command or check
- the exit status and a short output
- the commit and branch
- the classification
- the attempt number
- the decision and the owner
- the trace event

Failure evidence is part of the audit trail. A failure with no evidence cannot
be reviewed.

## 8. Postmortem and feedback

A critical failure or a repeated failure triggers a blameless postmortem:

- timeline
- impact
- root cause and contributing factors
- how it was detected
- how it was contained
- what worked and what did not
- actions with owners and due dates

The actions update at least one of:

- a test or a golden task
- a policy or permission rule
- the threat model
- the concern radar
- a runbook or a skill

A postmortem that produces no change is incomplete.

## 9. Anti-patterns

- Retrying forever.
- Guessing on ambiguity.
- Treating a flaky check as a pass.
- Hiding a policy violation.
- Switching models to bypass a refusal without a policy.
- Escalating without a question.
- Recording a failure without evidence.
- Blaming the model instead of the system.
- A postmortem with no action.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [autonomous-loop.md](autonomous-loop.md) — state machine
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — limits
- [decision-rights.md](../20-control/decision-rights.md) — escalation owners
- `incident-response.md` — incident process (planned)
- [docs/README.md](../README.md) — documentation map
