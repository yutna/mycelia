# Autonomous loop and durable execution

Status: Draft

## 1. Purpose

The loop is the backbone of the factory. It moves a work item through a
bounded, durable state machine, writes a checkpoint at every transition, and
ends in exactly one terminal state.

## 2. Loop overview

```text
intake -> planned -> implementing -> verifying -> reviewing
       -> accepting -> merging -> observing -> accepted

any state -> blocked | rejected | aborted
```

Every arrow has a gate. A gate is automated, independent review, or human
acceptance. A failed gate ends the run in `blocked`, `rejected`, or `aborted`;
it never falls through to `accepted`.

## 3. States

| State | Purpose | Exit gate | Artifacts |
| --- | --- | --- | --- |
| `intake` | Validate the work item | Schema valid, definition of ready met | Work item, risk tier, manifest |
| `planned` | Produce a plan | Plan covers criteria and non-goals; no ambiguity | Plan, risks, open questions |
| `implementing` | Make the change | Local checks pass; no policy violation | Change, local evidence |
| `verifying` | Run the evidence manifest | All required evidence present, fresh, pass | Evidence records |
| `reviewing` | Independent review | No blocking findings | Review record |
| `accepting` | Human decision | Approval recorded for the risk tier | Acceptance record |
| `merging` | Merge gate | CI, review, evidence, branch policy | Merge result |
| `observing` | Post-merge observation | No regression in the window | Observation record |
| `accepted` | Terminal success | n/a | Complete evidence and trace |
| `rejected` | Terminal refusal | n/a | Reason and evidence |
| `blocked` | Terminal needs human | n/a | Question, options, owner |
| `aborted` | Terminal stopped | n/a | Policy or budget cause |

## 4. Transitions

| From | To | Gate |
| --- | --- | --- |
| `intake` | `planned` | Work item valid |
| `intake` | `blocked` | Missing goal, criteria, risk tier, or data class |
| `planned` | `implementing` | Plan complete and approved for R3/R4 |
| `planned` | `blocked` | Ambiguity or conflicting criteria |
| `implementing` | `verifying` | Local checks pass; no policy violation |
| `implementing` | `blocked` | Repeated failure or ambiguity |
| `implementing` | `aborted` | Budget or policy stop |
| `verifying` | `reviewing` | Manifest satisfied |
| `verifying` | `rejected` | Required evidence failed |
| `verifying` | `blocked` | Evidence or verifier missing |
| `reviewing` | `accepting` | No blocking findings |
| `reviewing` | `rejected` | Blocking finding |
| `accepting` | `merging` | Approval recorded |
| `accepting` | `blocked` | Approval missing |
| `merging` | `observing` | Merge gate pass |
| `merging` | `aborted` | Merge failure or policy stop |
| `observing` | `accepted` | No regression |
| `observing` | `rejected` | Regression found |
| any | `aborted` | Kill switch, budget, or policy |

## 5. Invariants

1. One active run per work item.
2. No transition without a gate.
3. Every transition writes a checkpoint.
4. The state is durable; a restart resumes from the last checkpoint.
5. Evidence is tied to the current commit.
6. A terminal state is final; a new attempt needs a new run or a human decision.
7. The agent cannot skip a state, change its policy, raise its budget, or lower
   its risk tier.
8. No silent success.

## 6. Durable execution

A checkpoint records:

- state and timestamp
- commit and branch
- role, model, and policy version
- budget consumed
- evidence references
- open questions
- trace event

The checkpoint is stored in the run state and the trace. The run state is the
source of truth for resume; the trace is the audit record.

## 7. Resume

To resume a run:

1. Load the last checkpoint.
2. Verify the branch and commit.
3. Re-read the work item and the evidence manifest.
4. Re-check the budget and the policy version.
5. Re-run any evidence that is stale.
6. Continue from the checkpointed state.

If the commit changed, invalidate the evidence and restart at `implementing`.
If the policy changed, re-evaluate the transition before continuing.

## 8. Idempotency

- Every side effect has an idempotency key: work item, commit, and action.
- Execution is at least once; the effect must be at most once where possible.
- A merge is idempotent by commit; if the commit is already merged, the run is
  `accepted`.
- Pull request creation, comments, and labels are deduplicated by key.
- A retry must not create a duplicate branch, pull request, or release.
- A repeated transition with the same key returns the original result.

## 9. Budgets and stop conditions

The loop stops when:

- the step, time, token, cost, or tool-call budget is exhausted
- the maximum attempt count is reached
- the work item is ambiguous
- a policy conflict cannot be resolved
- the kill switch is triggered

A retry uses backoff and a new attempt number. After the maximum attempt count,
the run ends in `blocked` or `aborted`, never in an infinite loop.

## 10. Human handoff

A `blocked` run reports:

- the precise question
- the options and their consequences
- the owner who can answer
- the evidence already collected
- the work already completed

The answer is recorded in the trace and becomes part of the work item. The next
run starts from the blocked checkpoint with the answer in context.

## 11. OpenCode mapping

| Loop need | OpenCode mechanism |
| --- | --- |
| Start a run | `opencode run --format json --agent <role> --worktree <name>` |
| Continue a run | `--session <id>` or `--continue` |
| Orchestrate | `opencode serve` plus the session API |
| Stop | `session.interrupt`, kill switch |
| Wait | `session.wait` |
| Checkpoint | Run state file plus trace event |
| Context recovery | Sessions, compaction, snapshots |
| Concurrency | Worktrees, subagents |
| Limits | Agent `steps`, runner timeout, provider usage limits |

## 12. Verification

- State machine test: every allowed transition succeeds; every forbidden
  transition fails.
- Resume test: kill the run at each state and resume from the checkpoint.
- Idempotency test: repeat each side effect and check for duplicates.
- Budget test: exhaust each budget dimension and check `aborted`.
- Kill-switch test: stop a run and verify credentials and trace.
- Evidence mismatch test: change the commit and verify the evidence is
  invalidated.
- Record the test output as evidence.

## 13. Anti-patterns

- A loop with no terminal state.
- Retrying forever.
- Keeping state only in memory.
- Skipping review or acceptance.
- Using evidence from an earlier commit.
- Letting an agent raise its own budget.
- Running two active runs on the same work item.
- Merging without a gate.
- Treating a timeout as success.

## 14. Data contract

- Schema: [schemas/run-state.schema.json](../../schemas/run-state.schema.json)
- Example: [examples/run-state.example.yaml](../../examples/run-state.example.yaml)

## 15. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [work-intake.md](../10-context/work-intake.md) — work item contract
- [evidence-manifest.md](../20-control/evidence-manifest.md) — definition of done
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — limits
- `failure-and-ambiguity.md` — failure protocol (planned)
- `multi-agent-concurrency.md` — concurrency (planned)
- `opencode-runtime-contract.md` — runtime contract (planned)
- [docs/README.md](../README.md) — documentation map
