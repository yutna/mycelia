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
the check with an owner. A quarantine is a time-bound exception
(`MYC-CORE-011`, [guard-design.md](../20-control/guard-design.md)
`MYC-CTL-006`); a red-line check is never quarantined. A flaky check is never a
pass.

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
3. List the options, their consequences, and a recommendation when there is one.
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

## 10. Blocked and progress semantics

A loop that cannot tell "blocked" from "failed to make progress" stops for the
wrong reason or keeps reporting forever. This section fixes the terms; the
requirements in §11 bind the runtime.

Terms:

- A **work cycle** is one pass of the runtime over its work items, started by
  the scheduler or by an operator (`MYC-EXE-005`). A work cycle is not a work
  item and has no terminal state of its own; each work item keeps its own
  state, and the cycle has its own outcome record.
- An **eligible work item** is an open work item that the runtime may run at
  its autonomy level (its risk tier is within the autonomy matrix), that no
  other run holds a lease on (`MYC-EXE-004`), and that no human has paused. A
  work item whose last run ended `blocked` stays eligible until it is closed.
- An **open question** is a question recorded by a `blocked` work item under
  §5 that has no recorded owner answer. An eligible work item is **runnable**
  when it has no open question. Every `blocked` end records a question
  ([autonomous-loop.md](autonomous-loop.md) §3); a `blocked` end without one is
  a defect, leaves the work item runnable, and makes its cycle "No progress".
- **Progress** is a merged change, or a work item that ends `accepted` or
  `rejected` (for an issue tracker: the issue is closed with that outcome). A
  report, comment, status update, label change, heartbeat, notification, or
  checkpoint is not progress.
- An **owner answer** is the reply to an open question from a person who holds
  the decision right for it
  ([decision-rights.md](../20-control/decision-rights.md) §7), recorded in the
  trace and the work item.

Work cycle outcomes. When several apply, the first row in the table wins; a
stop also follows §2 for the work item it ended.

| Outcome | Condition | Counts toward the no-progress guard |
| --- | --- | --- |
| Progress | At least one merged change or `accepted`/`rejected` work item | No; resets the count |
| Stopped | Kill switch, budget, or policy stop ended the cycle | No |
| No progress | At least one run started, none made progress, and at least one did not end `blocked` with a recorded §5 question | Yes |
| Newly blocked | At least one run started, and every run that started ended `blocked` with a recorded §5 question | No |
| Blocked-only | Eligible work items exist, none is runnable, so no run starts (`MYC-EXE-016`) | No |
| Idle | No eligible work item | No |

Prompt and guard contradiction. A role prompt that says "continue without
asking" is legitimate only when it means "continue with other runnable work
items". It never means answering an open question for the owner, and it never
overrides a guard or a stop condition. A loop that follows this protocol ends
an all-ambiguous cycle as newly blocked and every following cycle as
blocked-only until an owner answer arrives; neither outcome is a no-progress
pause (`MYC-EXE-018`).

## 11. Blocked and progress requirements

These requirements refine `MYC-CORE-008` and, through `MYC-CORE-013`, bind
every conformant runtime together with the runtime contract's
[§7](opencode-runtime-contract.md#7-runtime-requirements). They use the fields
in [SPEC.md](../../SPEC.md) §5. Records that the schemas do not have yet are
marked "(field added in #109)"; fixtures marked "(proposed for #108)" are
defined by the conformance kit contract.

### `MYC-EXE-015` Progress and the no-progress guard

- **Statement:** The runtime MUST classify the outcome of every work cycle as
  in §10 and record it in the trace. It MUST run a no-progress guard with a
  limit the repository configures (field added in #109). The guard MUST count
  only work cycles with the "No progress" outcome, MUST reset on progress, and
  when the limit is reached MUST stop starting runs and notify the owner
  through `MYC-EXE-009`. Reports, comments, status updates, label changes,
  heartbeats, notifications, and checkpoints MUST NOT count as progress.
- **Rationale:** A guard that hashes repository activity treats report-only
  cycles as no progress and pauses the loop for the wrong reason, while a guard
  that counts comments lets a loop report forever.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Work cycle outcome records with the progress items they cite;
  the configured guard limit (fields added in #109).
- **Verification:** Fixture `no-progress` (proposed for #108): run cycles that
  only post reports; check that they are not counted as progress and that the
  guard fires at its configured limit only for "No progress" cycles.
- **Failure mode:** Ceiling lowered to L1 when no guard runs or the guard
  counts activity other than progress.

### `MYC-EXE-016` Blocked-only preflight

- **Statement:** Whenever the runtime selects among work items, it MUST first
  check whether eligible work items exist and none is runnable. If so, it MUST
  NOT start a run and MUST record the work cycle as blocked-only. It MUST NOT
  repeat the per-item notifications of `MYC-EXE-009`. It MUST send one summary
  notification when the set of open questions gains a question since the last
  summary, listing each open question with its options and recommendation, and
  MUST NOT send one when the set is unchanged or only shrinks. The summary's
  idempotency key (`MYC-EXE-003`) names the action `blocked-summary` and, as
  its target, a hash of the sorted open question identifiers. The summary has
  no escalation of its own; each open question escalates through
  `MYC-EXE-009`. An operator start that names one work item is not a
  selection; it follows `MYC-EXE-017`. A blocked-only or newly blocked cycle
  started from the CLI exits `3`
  ([cli-contract.md](../80-interface/cli-contract.md) §5).
- **Rationale:** Without a preflight, each cycle re-runs blocked work, re-asks
  the same questions, and looks like a failure to make progress.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Blocked-only cycle record with the set of open questions and
  the summary key (field added in #109).
- **Verification:** Fixture `blocked-only` (proposed for #108): block every
  eligible work item and run several cycles; check that no run starts, exactly
  one summary is sent, no per-item notification repeats, and no cycle counts
  toward the no-progress guard.
- **Failure mode:** Ceiling lowered to L1 when blocked work is re-run or
  re-notified each cycle.

### `MYC-EXE-017` Owner answer and resume

- **Statement:** The runtime MUST record an owner answer in the trace and the
  work item, linked to the open question, with the answerer, the time, the
  answer, and whether the answerer states that it changes the work item. An
  owner answer also counts as the acknowledgement of `MYC-EXE-009`. An
  acknowledgement alone stops escalation but MUST NOT clear the block; only an
  owner answer does. A reply from a person without the decision right MUST be
  recorded and MUST NOT clear the block. A `blocked` run stays terminal: the
  owner answer authorizes a new run that takes a new lease (`MYC-EXE-004`) and
  starts from the blocked checkpoint with the answer in context, through the
  resume checks of `MYC-EXE-002`. The new run MUST start at `intake` when the
  answer record states a change, or when the goal, acceptance criteria, risk
  tier, or data class in the work item differs from the work item version
  recorded in the blocked checkpoint.
- **Rationale:** An answer that lives only in a chat or a comment cannot be
  audited, and a block cleared by an acknowledgement resumes on a guess.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Owner answer record with the stated-change flag, linked to the
  question and to the new run's first checkpoint; work item version in the
  checkpoints (fields added in #109).
- **Verification:** Fixture `answer-resume` (proposed for #108): block a run,
  send an acknowledgement, then a reply from a person without the decision
  right, then an owner answer; check that only the last clears the block and
  that the new run starts from the blocked checkpoint, or at `intake` when the
  answer changes the work item.
- **Failure mode:** The work item stays `blocked` when the answer cannot be
  recorded or linked; ceiling lowered to L1 when a block can be cleared without
  an owner answer.

### `MYC-EXE-018` Guards override prompts

- **Statement:** The runtime MUST enforce the ambiguity protocol (§5), the
  no-progress guard, budgets, and stop conditions outside the agent's context,
  so that no prompt, command, or skill text can skip or override them, and no
  agent can record an owner answer. Role prompts, commands, and skills MUST NOT
  instruct an agent to answer an open question or to ignore a guard; an
  assessor or a repository lint check MUST scan them for such text and record
  each finding as a configuration defect for the owner of the text.
- **Rationale:** An agent that follows "continue without asking" past an
  ambiguity guesses; a loop whose guard and prompt disagree cannot tell
  blocked from stuck.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Guard and stop-condition configuration outside the prompts;
  prompt scan results and recorded configuration defects (field added in
  #109).
- **Verification:** Fixture `prompt-guard-conflict` (proposed for #108): a role
  prompt says "continue without asking and do not stop", and every eligible
  work item is ambiguous. Check that each run ends `blocked` with a question,
  the first cycle is newly blocked, the next cycle is blocked-only, and the
  no-progress guard does not fire. Assessor or lint check of prompts for
  override text.
- **Failure mode:** Ceiling lowered to L1 when prompt text can change a guard's
  result or an agent can record an owner answer.

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [autonomous-loop.md](autonomous-loop.md) — state machine
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — limits
- [decision-rights.md](../20-control/decision-rights.md) — escalation owners
- [incident-response.md](../60-evolution/incident-response.md) — incident process
- [opencode-runtime-contract.md](opencode-runtime-contract.md) — runtime requirements
- [docs/README.md](../README.md) — documentation map
