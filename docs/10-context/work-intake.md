# Work intake

Status: Draft

## 1. Purpose

Work intake turns a request into a work item that an agent can execute and a
reviewer can verify. A work item defines the goal, the acceptance criteria, the
non-goals, the risk tier, the data class, and the evidence required to call the
work done.

## 2. Definition of ready

A work item is ready when all of the following are true:

- the goal is stated in one or two sentences
- at least one observable acceptance criterion exists
- the non-goals are explicit
- the risk tier is assigned
- the required evidence is listed
- the data class is assigned
- the approvals are named for R3 and R4
- the rollback plan is stated for R2 and above
- the item validates against the work item schema

A work item missing any of these is `blocked`, not "ready enough".

## 3. Work item fields

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | Yes | Stable identifier, for example `MYC-123` |
| `title` | Yes | Short description of the outcome |
| `goal` | Yes | What must be true when the work is done |
| `context` | No | Background, links, and constraints |
| `acceptanceCriteria` | Yes | Observable outcomes, at least one |
| `nonGoals` | Yes | What the work must not do |
| `constraints` | Yes | Technical, policy, or time limits |
| `riskTier` | Yes | `R0` through `R4` |
| `autonomyLevel` | No | Defaults to the repository ceiling |
| `dataClass` | Yes | `public`, `internal`, `confidential`, or `secret` |
| `affectedAreas` | No | Directories, services, or systems in scope |
| `evidence` | Yes | Required evidence types, thresholds, and verifiers |
| `rollback` | R2+ | How to undo the change |
| `dependencies` | No | Other work items or external decisions |
| `approvals` | R3/R4 | Who must accept the change |
| `links` | No | Issue, design, and reference URLs |

## 4. Intake process

1. **Capture the request.** Record the source: issue, incident, roadmap, or
   review finding.
2. **Restate the goal.** Write one or two sentences that a reviewer can check.
3. **Write acceptance criteria.** Use observable outcomes. Given/When/Then is
   optional but useful when the behavior has preconditions.
4. **Write non-goals.** Name the tempting adjacent changes that are out of
   scope.
5. **Classify the risk tier.** Use R0-R4 from
   [autonomy-levels.md](../00-foundations/autonomy-levels.md).
6. **Select the evidence.** Choose the evidence types and thresholds the risk
   tier requires.
7. **Assign the data class.** Decide what may go to a model provider.
8. **Name the approvals.** For R3 and R4, name the human and security owners.
9. **State the rollback.** For R2 and above, describe how to undo the change.
10. **Validate the item.** Run the schema check.
11. **Link the issue.** The work item is the source of truth; the issue is the
    conversation.

## 5. Acceptance criteria

Good criteria are observable, bounded, and testable:

- "The command exits with status 0 and prints the version."
- "The endpoint returns 401 for a missing token."
- "The migration dry run reports no destructive change."

Poor criteria are vague or implementation-driven:

- "Improve performance."
- "Refactor the service."
- "Use a better algorithm."

Each criterion maps to at least one evidence item. A criterion without evidence
is not ready.

## 6. Evidence selection

| Risk | Minimum evidence |
| --- | --- |
| R0 | Markdown lint, link check |
| R1 | R0 plus unit tests and review |
| R2 | R1 plus integration tests, changed-line coverage, independent review |
| R3 | R2 plus security scan, migration dry run, human acceptance |
| R4 | R3 plus security review, rollback drill, human sign-off |

The evidence manifest is the machine-readable version of this table. The work
item names the required evidence; the verifier produces it.

## 7. Ambiguity and conflict

Intake ends in `blocked` when:

- the goal cannot be stated without guessing
- acceptance criteria contradict each other
- the risk tier cannot be assigned
- the data class is unknown
- a required approval is missing
- the work item depends on an unresolved decision

The blocked state includes the precise question, the options, and the person
who can answer. It never becomes an implicit assumption.

## 8. Definition of done

A work item is done when:

- every acceptance criterion is met
- the evidence manifest is satisfied
- independent review is complete for R2 and above
- human acceptance is recorded for R3 and R4
- the rollback plan is recorded
- the trace is complete
- the work item is in `accepted`

## 9. Anti-patterns

- A goal with no observable outcome.
- No non-goals, so the agent expands the scope.
- The agent chooses its own risk tier.
- "Tests pass" with no command, log, or commit hash.
- A work item that spans several unrelated changes.
- A secret or confidential datum with no data class.
- A rollback plan that has never been tested.

## 10. Data contract

- Schema: [schemas/work-item.schema.json](../../schemas/work-item.schema.json)
- Example: [examples/work-item.example.yaml](../../examples/work-item.example.yaml)

## 11. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [repository-legibility.md](repository-legibility.md) — repository readiness
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [docs/README.md](../README.md) — documentation map
