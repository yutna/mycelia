# Adoption guide

Status: Draft

## 1. Purpose

The specification is only useful if a team can adopt it without a big-bang
rewrite. This guide defines the greenfield and brownfield paths, the phases,
the entry and exit criteria, and the evidence for each step.

## 2. Prerequisites

- a named human owner
- access to the repository and CI
- authority to change branch protection and permissions
- a pilot repository or service
- a security owner for R3 and R4
- a rollback path for anything already in production

## 3. Minimal viable adoption

1. Add a work item with a goal, acceptance criteria, risk tier, and evidence.
2. Add a role contract and a policy with red lines.
3. Add canonical checks that run from a clean clone.
4. Add an evidence manifest for R0 and R1.
5. Use the draft-first pull request flow and forbid direct pushes to `main`.

This is enough for L1. Do not wait for the full profile.

## 4. Greenfield

1. Create the repository from the template.
2. Fill `mycelia.yaml`.
3. Copy `opencode.json` and `.opencode/`.
4. Add the CI checks and the evidence manifest.
5. Run the readiness assessment.
6. Run one R0 change through the full loop.
7. Raise the level only with evidence.

## 5. Brownfield

1. Pick a pilot repository or service.
2. Run the baseline assessment; record the ceiling.
3. Make the repository legible: README, commands, pinned toolchain, ownership.
4. Make the checks deterministic; quarantine flaky tests with an owner.
5. Add `AGENTS.md` and the role contracts.
6. Add the policy red lines and the evidence manifest.
7. Add the sandbox, budgets, and kill switch.
8. Add independent review and acceptance sampling.
9. Add trace and provenance.
10. Reassess and promote one level at a time.

Start with R0 and R1 work. Do not start with the riskiest change in the
repository.

## 6. Phases

| Phase | Entry | Exit |
| --- | --- | --- |
| 0 Baseline | Access and owner | Readiness report with ceiling |
| 1 Legibility | Baseline | Clean clone runs the checks |
| 2 Feedback | Legibility | CI green; flake rate bounded |
| 3 Control | Feedback | Roles, policy, evidence, decision rights |
| 4 Containment | Control | Sandbox, budgets, kill switch |
| 5 Assurance | Containment | Independent review, mutation, acceptance |
| 6 Observability | Assurance | Trace, provenance, metrics |
| 7 Promotion | All phases | Readiness report meets the target; drills pass |

Every phase has an owner and evidence. A phase without evidence is not
complete.

## 7. Roles

| Role | Responsibility |
| --- | --- |
| Human owner | Owns the adoption and the risk |
| Platform engineer | Builds the runtime, CI, sandbox, and trace sink |
| Security owner | Reviews the policy, secrets, and R4 changes |
| Maintainer | Keeps the local profile and the evidence current |
| Pilot team | Runs the first changes and reports friction |

## 8. Evidence per phase

- Baseline: readiness report, ceiling, gap register.
- Legibility: clean-clone log, command list, ownership record.
- Feedback: CI result, flake rate, check time.
- Control: role contracts, policy tests, evidence manifest.
- Containment: sandbox config, budget test, kill-switch drill.
- Assurance: review record, mutation report, acceptance sample.
- Observability: trace export, provenance record, metrics.
- Promotion: readiness report, canary result, human approval.

## 9. Common blockers

| Blocker | Remedy |
| --- | --- |
| Flaky tests | Quarantine with an owner and an expiry; do not retry to pass |
| No CI | Start with lint, link check, and schema validation |
| No owner | Assign one before starting |
| Monorepo ambiguity | Add per-package commands and ownership |
| Secrets in the environment | Move to a broker; deny `.env` |
| Approval fatigue | Sample by risk; raise the evidence quality |
| Legacy release | Add a rollback and a canary before changing the release |
| No test suite | Add characterization tests before refactoring |

## 10. Upgrade

- Reassess after each phase.
- Read the new template diff; do not overwrite local configuration.
- Run the conformance tests.
- Record the upgrade and the new ceiling.
- Announce the change to the pilot team.

## 11. Anti-patterns

- A big-bang adoption.
- Buying a better model instead of fixing the repository.
- Skipping the baseline.
- Starting with an over-permissioned pilot.
- No human owner.
- No rollback.
- Claiming a level without evidence.
- Copying the normative specs into the adopter.

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [readiness-assessment.md](readiness-assessment.md) — assessment
- [conformance-profiles.md](conformance-profiles.md) — profiles
- [template-and-adoption.md](../60-evolution/template-and-adoption.md) — boundary
- [repository-legibility.md](../10-context/repository-legibility.md) — legibility
- [work-intake.md](../10-context/work-intake.md) — work item
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — sandbox
- [human-acceptance.md](../40-assurance/human-acceptance.md) — acceptance
- `worked-example.md` — example (planned)
- [docs/README.md](../README.md) — documentation map
