# Repository legibility

Status: Draft

## 1. Purpose

A repository that an agent cannot understand is not ready for autonomy. This
document defines what a repository must expose so an agent can work, a reviewer
can verify, and a new contributor can reproduce the result.

## 2. The legibility contract

| Item | What good looks like | Evidence |
| --- | --- | --- |
| Entry point | README states what the project is, who it is for, and how to start | README link check |
| Commands | One canonical install, build, test, lint, and format command | Command block in the README |
| Environment | Toolchain pinned with mise, a container, or both | `mise.toml`, lockfile, container file |
| Architecture map | Directory map, boundaries, and the main data flow | Architecture document |
| Conventions | Style, naming, branch, commit, and pull request rules | `CONTRIBUTING.md`, `AGENTS.md` |
| Test map | Unit, integration, and end-to-end layers; how to run one test | Test README or test command help |
| Ownership | A named owner or team for each area | `CODEOWNERS` or an ownership table |
| Security | Secret policy, dependency policy, and disclosure path | `SECURITY.md`, policy file |
| CI and evidence | Required gates, artifacts, and where to find them | CI workflow and evidence manifest |
| Agent instructions | Current `AGENTS.md`, skills, and references | Instruction files |
| Change history | Decisions and release notes | ADRs, releases |
| Feedback speed | Local checks and CI complete within an agreed budget | Metrics or timing note |

## 3. Legibility tiers

| Tier | Name | Description |
| --- | --- | --- |
| 0 | Opaque | No reliable entry point, no runnable command, no owner |
| 1 | Documented | A README and commands exist, but they may be stale or flaky |
| 2 | Runnable | A clean clone runs the documented checks; CI is deterministic; an owner is named |
| 3 | Verified | The documented commands are checked in CI; links are checked; time and flake budgets are measured |

Tier 3 is the target for L2 and above. Tier 2 is the minimum for L1. Tier 0
caps the autonomy ceiling at L0.

## 4. Assessment questions

- Can a new contributor run the checks from a clean clone with one command?
- Is the toolchain pinned, and is the lockfile committed?
- Is there one test command and one documented way to run a single test?
- Is ownership explicit for every area the work item may touch?
- Are secrets, data classes, and disclosure paths documented?
- Are agent instructions current and consistent with `CONTRIBUTING.md`?
- Are the required CI gates and evidence artifacts documented?
- How long does the local feedback loop take, and how long does CI take?
- Is the flake rate measured and bounded?
- Can the agent tell which files are generated and must not be edited?

## 5. Brownfield adoption

1. Inventory the commands that actually work; do not trust the old README.
2. Add a pinned toolchain and a clean-clone check.
3. Make the test suite deterministic; quarantine flaky tests with an owner.
4. Write the architecture map and the ownership table.
5. Add `AGENTS.md` with the canonical commands.
6. Add the legibility check to CI.
7. Score the tier and record the gap.

Do not wait for a perfect repository. Score it, fix the blocking items, and
re-score.

## 6. Anti-patterns

- A README that says "run the tests" without a command.
- Commands that only exist inside a CI workflow.
- Flaky tests hidden behind automatic retries.
- Multiple package managers or toolchain versions in one repository.
- No owner for a critical area.
- Agent instructions that duplicate and contradict `CONTRIBUTING.md`.
- Generated files that look editable.
- A feedback loop so slow that agents guess instead of checking.

## 7. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [work-intake.md](work-intake.md) — work item contract
- `context-engineering.md` — how context is assembled (planned)
- [reference-architecture.md](../00-foundations/reference-architecture.md) — layers and components
- [docs/README.md](../README.md) — documentation map
