# Template and adoption boundary

Status: Draft

## 1. Purpose

Adoption fails when a team forks the core or when every local change becomes a
permanent divergence. This document defines the shared core, the profile, the
local layer, the `mycelia.yaml` root config, and the conformance claim.

## 2. Three layers

| Layer | Owner | Examples | Change process |
| --- | --- | --- | --- |
| Core | Mycelia maintainer | Normative specs, schemas, default profile, assessment | Issue and reviewed pull request |
| Profile | Mycelia maintainer | Minimal, standard, high-assurance | Core process |
| Local | Adopter | Commands, owners, budgets, providers, exceptions | Adopter's process |

The local layer may narrow the core; it may not weaken a red line. A local
override that conflicts with the core is invalid.

## 3. Core

- the normative specification
- the JSON Schemas
- the default OpenCode profile
- the readiness assessment
- the commands and skills
- the conformance tests

The core is versioned and copied. It is not forked.

## 4. Profile

A profile selects a set of controls and thresholds:

| Profile | Target | Controls |
| --- | --- | --- |
| Minimal | L1 | Work item, role, policy, evidence, terminal states |
| Standard | L2 | Minimal plus sandbox, independent review, sampling, trace |
| High-assurance | L3-L4 | Standard plus provenance, mutation, incidents, evals, assessment |

A profile inherits the lower profiles.

## 5. Local

The adopter configures:

- repository name and owner
- commands and test entry points
- risk-tier examples for the repository
- budgets and concurrency
- providers and models
- trace sink and retention
- owners and escalation
- time-bound exceptions
- adapters for the Git provider and CI

The local layer is declared in `mycelia.yaml`.

## 6. `mycelia.yaml`

The root configuration declares:

| Field | Meaning |
| --- | --- |
| `profile` | Minimal, standard, or high-assurance |
| `autonomy.ceiling` | The highest level the repository may run at |
| `autonomy.default` | The default level for a new work item |
| `runtime` | OpenCode version and config path |
| `riskTiers` | Repository examples for R0-R4 |
| `evidenceManifest` | Path to the manifest |
| `roles` | Enabled roles |
| `policies` | Policy bundles |
| `budgets` | Cost, token, step, and concurrency limits |
| `observability` | Trace sink and retention |
| `dataClasses` | Allowed data classes |

## 7. Distribution

- Copy the template, do not fork the core.
- Pin the core version in `mycelia.yaml`.
- Keep local changes in the local layer.
- Upgrade by diffing the new template against the old, not by overwriting the
  adopter's configuration.
- Record the upgrade in the release notes.
- Run the conformance tests after the upgrade.

## 8. Precedence

- The core red lines cannot be weakened.
- The profile sets defaults; the local layer may tighten them.
- The stricter rule wins.
- OpenCode policy precedence is managed, system, Console, global, project.
- A local override that cannot be reconciled leaves the work item `blocked`.

## 9. Conformance claims

An adopter may claim:

- the profile it implements
- the autonomy ceiling with evidence
- the controls it has adopted
- the deviations and exceptions

An adopter may not claim:

- certification by Mycelia
- a level above its assessed ceiling
- a control it has not evidenced
- another harness's conformance

The readiness report is the evidence for the claim.

## 10. Golden path

1. Copy the template.
2. Fill `mycelia.yaml`.
3. Run the readiness assessment.
4. Fix the blocking gaps.
5. Run one low-risk change through the loop.
6. Raise the level only with evidence.

## 11. Anti-patterns

- Forking the core.
- Editing the core in place.
- A local override that weakens a red line.
- A conformance claim with no evidence.
- A template upgrade that overwrites local configuration.
- A profile with no owner.
- An exception that never expires.

## 12. Data contract

- Schema: [schemas/mycelia.schema.json](../../schemas/mycelia.schema.json)
- Example: [examples/mycelia.example.yaml](../../examples/mycelia.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — runtime
- `readiness-assessment.md` — assessment (planned)
- `conformance-profiles.md` — profiles (planned)
- `adoption-guide.md` — guide (planned)
- [docs/README.md](../README.md) — documentation map
