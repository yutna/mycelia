# Multi-agent concurrency

Status: Draft

## 1. Purpose

Concurrency is where a factory gains throughput and where it loses work. This
document defines how multiple agents work at the same time without overwriting
each other: topology, work partitioning, worktrees, ownership, merge queue, WIP
limits, handoffs, and conflict handling.

## 2. Topologies

| Topology | Shape | Use |
| --- | --- | --- |
| Singleton | One agent, several roles in sequence | Small repository, low risk |
| Crew | Planner, implementer, verifier, reviewer, integrator | Standard profile |
| Swarm | Many workers on a task DAG | Large backlog, L3/L4 |

Start with singleton or crew. Move to a swarm only when the worktree, ownership,
and merge queue controls are in place.

## 3. Work partitioning

- Represent the work as a directed acyclic graph (DAG).
- A node is one work item or one task with its own acceptance criteria.
- An edge is a dependency: the downstream node cannot start until the upstream
  node is `accepted`.
- Fan out independent tasks; fan in at a verification node.
- No two nodes may write the same file at the same time.
- One active run per work item.
- One work item per pull request.

An unpartitioned backlog is not a swarm; it is a queue of conflicts.

## 4. Worktrees

- One worktree per task or agent.
- Create the worktree from `main`.
- Do not share a worktree between agents.
- Load configuration and plugins from the canonical checkout.
- Keep the worktree inside the sandbox.
- Remove the worktree after the merge or the abort.
- Do not reuse a worktree across trust levels.

OpenCode worktrees provide the isolation. The specification requires them for
concurrent work.

## 5. Ownership and locks

- Claim a file or directory before editing it.
- Prefer partitioning by directory over fine-grained file locks.
- A lock has an owner, a task, a timestamp, and a TTL.
- A stale lock is reported, not silently stolen.
- If two tasks need the same file, serialize them.
- If a task needs a file owned by another task, request a handoff instead of
  editing around the owner.
- The ownership record is part of the task DAG.

## 6. Merge queue

- Merges are serialized through a merge queue.
- The queue runs CI on the merged result, not only on the branch.
- The order follows the task DAG and the queue policy.
- The merge method is squash; the branch is deleted.
- A failed queue entry returns the task to `implementing` or `blocked`.
- A semantic conflict that a clean merge cannot detect is a review finding.
- Do not bypass the queue for R1 and above.

## 7. WIP limits and backpressure

- Set a WIP limit per repository, role, and integration queue.
- Admit work only when a slot is free.
- Queue the rest; do not start it.
- Use the limit to keep review time and merge time bounded.
- Measure queue time and cycle time.
- Raise the limit only when the evidence shows the system can absorb it.

A WIP limit that is never reached is not a control. A WIP limit that is always
exceeded is a capacity problem.

## 8. Trunk-based development

- Keep branches short-lived.
- Prefer small pull requests that merge within a day.
- Use feature flags for incomplete work instead of a long-lived branch.
- Rebase on `main` before the merge queue.
- Delete the branch after the merge.

## 9. Handoffs

- Handoffs are artifact-mediated, not prompt chains.
- A handoff names the from and to roles, the task, the artifacts, the evidence,
  the open questions, and the deadline.
- The receiver verifies the artifacts before acting.
- The handoff is recorded in the trace.
- A handoff does not transfer authority; the receiver's role contract still
  applies.

## 10. Conflict handling

| Conflict | Response |
| --- | --- |
| Same file, two agents | Serialize; one waits for the other |
| Same branch, two agents | Forbidden; one worktree per task |
| Duplicate task | Deduplicate by work item ID and idempotency key |
| Stale lock | Report to the owner; do not steal silently |
| Clean merge, semantic conflict | Review finding; rework or split the task |
| Queue failure | Return to implementing or blocked |
| Rebase conflict | Re-implement small, or ask |

A semantic conflict is the dangerous one. Tests and review are the detection.

## 11. Resource limits

- Cap concurrent runs per repository and per role.
- Cap tokens, cost, CI minutes, and storage per run and per day.
- Reserve capacity for rollback and incident response.
- Stop admitting work when the limit is reached.
- Record the queue and the reason in the trace.

## 12. Observability

Every run and task records:

- run ID and task ID
- worktree path and branch
- owning role and agent
- parent task and dependencies
- merge queue position
- trace correlation ID

Without correlation, a concurrency incident cannot be reconstructed.

## 13. Verification

- Two agents edit the same file: one waits; no lost update.
- Two agents use the same branch: the second is rejected.
- Duplicate task: only one run is created.
- Stale lock: reported, not stolen.
- Merge queue: CI runs on the merged result.
- Semantic conflict: caught by review or tests.
- WIP limit: new work is queued, not started.
- Record the test output as evidence.

## 14. Anti-patterns

- Many agents in one worktree.
- Two agents on one branch.
- A merge queue that only tests the branch, not the merged result.
- A lock with no TTL.
- A stale lock stolen silently.
- A WIP limit that is ignored.
- A handoff that forwards a chat transcript.
- A long-lived branch as the integration strategy.
- Concurrency without trace correlation.

## 15. Data contract

- Schema: [schemas/handoff.schema.json](../../schemas/handoff.schema.json)
- Example: [examples/handoff.example.yaml](../../examples/handoff.example.yaml)

## 16. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [threat-model.md](../00-foundations/threat-model.md) — concurrency threats
- [autonomous-loop.md](autonomous-loop.md) — state machine
- [failure-and-ambiguity.md](failure-and-ambiguity.md) — failure protocol
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — limits
- `change-lifecycle.md` — branch, pull request, merge (planned)
- [docs/README.md](../README.md) — documentation map
