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
| Merge conflict | Merging | Update the branch from the default branch or re-implement | 2 | `blocked` |
| Stale base | Verify | Update the branch and re-run (`MYC-EXE-020`) | 1 per failure; total capped by `MYC-EXE-020` | Merge conflict or product test failure |
| Breaking dependency update | Verify | Stop; propose a migration work item (`MYC-CTL-007`) | 0 | `rejected` |
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
`MYC-CTL-006`). A red-line check is never quarantined: it fails closed and the
change is `blocked`. A flaky check is never a pass.

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

The base branch changed. Update the branch by merging the default branch, or
re-implement, up to two times. If the conflict is semantic, ask.

### Stale base

A check fails because the branch base is old. Update the branch from the
default branch and re-run once (`MYC-EXE-020`). A conflict is a merge conflict;
a failure after the update is classified on its own.

### Breaking dependency update

A dependency update fails a compile, type, or test check while its change patch
touches only dependency manifests and lockfiles. It is not retried as a product
failure: the update is `rejected` and a migration work item is proposed
(`MYC-CTL-007`).

### Security finding

A scan or review finds a vulnerability. Reject the change and open an incident.
Do not retry with a weaker check.

### Missing or stale evidence

The evidence manifest is not satisfied, or the evidence belongs to another
commit and was not carried under `MYC-EXE-021`. Reproduce the evidence or ask.
Do not mark it as pass.

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

One kind of choice is not an ambiguity in this sense: an **implementation
choice**, a choice the work item leaves open and that none of the conditions
above describes, such as an internal structure, which existing pattern or
algorithm to use, or a name that follows an existing repository convention.
At R0-R2 an agent may make an implementation choice itself and record it,
within the fences of `MYC-EXE-019`. Every other decision belongs to a human
([decision-rights.md](../20-control/decision-rights.md) §2) and follows the
protocol above.

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
- A **recorded decision** is an implementation choice an agent made and
  recorded under `MYC-EXE-019`. It is not an open question, it does not block
  the work item, and it is not progress.
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
| Newly blocked | At least one run started, and every run that started ended `blocked` with a recorded §5 question (including a rejected recorded decision, `MYC-EXE-019`) | No |
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

### `MYC-EXE-019` Recorded implementation choices

- **Statement:** An agent MAY make an implementation choice (§5) without
  blocking only when every fence below holds. The runtime MUST check each
  fence from recorded data:
  1. The work item is R0, R1, or R2.
  2. The work item's goal, acceptance criteria, non-goals, constraints, risk
     tier, and data class are unchanged from the work item version in the
     checkpoint.
  3. The work item lists `affectedAreas` as repository path globs, and the run
     diff stays inside them. The diff modifies or deletes no protected file:
     tests, guard configuration and fixtures
     ([guard-design.md](../20-control/guard-design.md) §2), policy and
     permission configuration, schemas, CI workflows, the evidence manifest,
     and the work item. Adding a new test file inside `affectedAreas` is
     allowed. A repository list of further protected paths is added in #109.
  4. The record cites an evidence reference of an allowed type (a test
     result, a prototype run, a measurement, or an existing repository
     convention cited by path) produced or checked at the current commit.
  5. The work item has fewer recorded decisions than the configured limit
     (field added in #109). When no limit is configured, the limit is zero.

  Whether a choice is an implementation choice, and whether its evidence
  settles it, is judged by the independent reviewer, not by the runtime: a
  work item with any recorded decision MUST have an independent review
  ([review-rubric.md](../40-assurance/review-rubric.md)) whatever its risk
  tier. A recorded decision MUST NOT satisfy or waive any gate; merges,
  releases, external messages, and data or schema migrations keep their own
  gates. A need found outside `affectedAreas` is not decided: the agent records
  it as a proposed new work item and does not change files outside the areas.

  The runtime MUST record each recorded decision in the trace with the options
  considered, the choice, the evidence, and the fence results, and MUST list it
  in the pull request under "Recorded decisions". When a fence fails, the
  choice is an open question under §5 and the work item ends `blocked`. When
  the independent reviewer or an accepting human rejects a recorded decision,
  the work item ends `blocked` with that decision as an open question whose
  recommendation is the agent's choice; it resumes through `MYC-EXE-017`.
- **Rationale:** Blocking on every open choice stops the loop on questions an
  experiment or an existing convention can settle, while letting an agent
  decide anything it judges reversible lets it guess on goals, scope, and risk.
  A narrow class, fences checked outside the agent, and a mandatory independent
  review keep the loop moving without trusting a weak model's judgment.
- **Applies to:** L2-L4; R0-R2 only.
- **Evidence:** Recorded decision records in the trace and the pull request,
  with the fence results (fields added in #109); the review record that checks
  them.
- **Verification:** Fixture `recorded-decision` (proposed for #108): an R3 work
  item, a modified protected file, a work item without path-glob
  `affectedAreas`, evidence from an older commit, no configured limit, and a
  work item over the limit each turn the choice into an open question; an R0
  work item with a recorded decision gets an independent review; a reviewer
  rejection and an accepting-human rejection each end the work item `blocked`
  with the decision as the recommendation.
- **Failure mode:** The work item is `blocked` when a fence fails or a recorded
  decision is rejected; ceiling lowered to L1 when the runtime lets an agent
  decide outside the fences or without an independent review.

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
