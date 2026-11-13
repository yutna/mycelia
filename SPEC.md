# Specification

Status: Draft (`v0.1.0`)

Normative language: RFC 2119 and RFC 8174

Requirement IDs: `MYC-<AREA>-###`

Runtime: OpenCode V2, tested with version 2.2.6 or newer

## 1. Purpose

This document is the normative core of Mycelia. It defines conformance, the
requirement model, the factory model, autonomy levels, risk tiers, terminal
states, and the core requirements that every later specification refines.

## 2. Scope and non-goals

The scope, claims, and limitations are in [SCOPE.md](SCOPE.md). This document
does not replace that boundary; it makes the boundary testable.

## 3. Normative language

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY are to be
interpreted as described in RFC 2119 and RFC 8174. Lowercase words are
informative.

## 4. Conformance

Conformance is claimed per profile, not globally.

- A **conformant repository** satisfies the requirements of its declared
  profile and produces the required evidence.
- A **conformant implementation** enforces the requirements of the profile it
  claims, including the policy gates and terminal states.
- A **conformant assessment** follows the readiness model, cites evidence for
  every score, and reports unproven controls as unproven.

A repository that cannot produce evidence for a control does not conform at
the level that requires that control, even if the control is described in its
documentation.

## 5. Requirement model

Every requirement has the following fields:

| Field | Meaning |
| --- | --- |
| **ID** | `MYC-<AREA>-###`, stable for the life of the requirement |
| **Statement** | A normative sentence using RFC 2119 language |
| **Rationale** | Why the requirement exists and what risk it reduces |
| **Applies to** | Autonomy levels and risk tiers that must satisfy it |
| **Evidence** | The artifact and the verifier that prove it |
| **Verification** | The method used to check the evidence |
| **Failure mode** | What happens when the requirement is unmet |

Areas:

| Area | Scope |
| --- | --- |
| `CORE` | Framework-wide invariants |
| `CTX` | Repository legibility, work intake, context engineering |
| `CTL` | Roles, policy, evidence, decisions, sandbox, supply chain |
| `EXE` | Loop, failure handling, concurrency, change lifecycle |
| `ASR` | Verification, test integrity, review, acceptance, release |
| `OBS` | Trace, provenance, metrics |
| `EVO` | Evaluations, rule lifecycle, adoption, incidents, economics |
| `ADP` | Readiness, profiles, conformance, audit |
| `INT` | CLI, file formats, schemas |

## 6. Factory model

The factory has six layers. Each layer answers one question and produces
artifacts the next layer can verify.

| Layer | Question | Primary artifacts |
| --- | --- | --- |
| Context | Does the agent see the right thing? | Work item, repository map, references |
| Control | What is it allowed to do? | Role contract, policy decision, evidence manifest |
| Execution | How does work move? | State record, handoff, change request |
| Assurance | How do we know it is right? | Test evidence, mutation score, review, sign-off |
| Observability | What happened? | Trace, provenance, metrics |
| Evolution | How does it improve? | Evaluation result, rule change, readiness report |

### Actors

| Actor | Purpose |
| --- | --- |
| Human owner | Sets policy, accepts high-risk changes, commands incidents |
| Planner | Decomposes the work item; read-only |
| Implementer | Makes the change; write access limited to the workspace |
| Verifier | Runs the evidence manifest; no write access |
| Reviewer | Independent review against the rubric; no write access |
| Integrator | Prepares the change request and gates; no merge authority by default |
| Assessor | Scores readiness and reports gaps; read-only |

A single agent MAY hold more than one role only when the independence
requirements of the risk tier are still satisfied.

### Work item lifecycle

```text
intake -> plan -> implement -> verify -> review -> accept -> merge -> observe
```

Every transition has a gate. A gate is either automated, independent review,
or human acceptance. A failed gate leaves the work item in `blocked` or
`rejected`, never in `accepted`.

## 7. Autonomy levels

| Level | Name | What runs | Human role |
| --- | --- | --- | --- |
| L0 | Manual | No autonomous execution | Does the work; uses the spec as a checklist |
| L1 | Assisted | Agent proposes changes | Runs checks and merges every change |
| L2 | Supervised | Agent runs the loop in a sandbox; independent reviewer | Accepts by sampling; handles exceptions |
| L3 | Autonomous | Agent merges low and medium risk after evidence gates | Handles high risk, policy, and incidents |
| L4 | Unattended | Multi-agent concurrency; policy-gated merge | Owns policy, audits by sampling, commands incidents |

L4 is **not** "no humans". It means no routine human action for R0-R2 work,
while humans retain policy ownership, R3-R4 decisions, and incident command.

## 8. Risk tiers

| Tier | Examples | Minimum independence |
| --- | --- | --- |
| R0 | Documentation, comments, formatting | CI |
| R1 | Tests, internal tooling, non-production scripts | CI + review |
| R2 | Normal feature or bug fix | Independent review |
| R3 | Auth, payments, data schema, infrastructure, security configuration | Independent review + human acceptance |
| R4 | Production credentials, destructive migrations, incident response, safety-critical changes | Human sign-off + security review |

### Autonomy matrix

| Risk | L1 | L2 | L3 | L4 |
| --- | --- | --- | --- | --- |
| R0 | Human merge | Supervised | Autonomous | Unattended |
| R1 | Human merge | Supervised | Autonomous | Unattended |
| R2 | Human merge | Supervised | Autonomous | Unattended |
| R3 | Human | Human | Human acceptance | Human-on-the-loop |
| R4 | Human | Human | Human | Human sign-off |

"Autonomous" means evidence-gated merge, not unreviewed merge. "Unattended"
means no routine human action, not no accountability.

## 9. Terminal states

Every work item ends in exactly one terminal state. There is no fifth state
and no implicit success.

| State | Meaning | Required artifacts |
| --- | --- | --- |
| `accepted` | The change is delivered and verified | Evidence manifest results, review, gate results, trace |
| `rejected` | The change is refused | Reason, evidence, reviewer or gate decision |
| `blocked` | A human decision is required | The precise question, the blocking condition, the options |
| `aborted` | A policy or budget stopped the work | The policy or budget identifier, the trace, the cleanup result |

### No silent success

A work item MUST NOT reach `accepted` unless its evidence manifest is
satisfied. A missing, stale, self-certified, or unverifiable artifact is a
failure, not a pass. This invariant is the core of the reliability contract in
[SCOPE.md](SCOPE.md).

## 10. Core requirements

| ID | Requirement | Evidence | Verification |
| --- | --- | --- | --- |
| `MYC-CORE-001` | Every work item MUST define its goal, acceptance criteria, non-goals, constraints, risk tier, and required evidence before execution. | Work item record | Schema validation and assessor check |
| `MYC-CORE-002` | Every role MUST have a role contract with allowed actions, denied actions, tools, data classes, and an escalation path. | Role contract | Config validation and review |
| `MYC-CORE-003` | Policy MUST be enforced by the runtime, not only by a prompt. | Policy decision record | Attempt a denied action |
| `MYC-CORE-004` | Every work item MUST end in exactly one terminal state with evidence and a trace. | Terminal state record | Audit sample |
| `MYC-CORE-005` | No work item may reach `accepted` without satisfying its evidence manifest. | Evidence artifacts | Gate check |
| `MYC-CORE-006` | R3 and R4 changes MUST have independent verification and human acceptance. | Review record and sign-off | Audit sample |
| `MYC-CORE-007` | The factory MUST record the model, prompt, policy, and rule versions for every run. | Trace event | Trace audit |
| `MYC-CORE-008` | The factory MUST stop and escalate on ambiguity, policy conflict, or budget exhaustion. | Blocked state and question | Failure drill |
| `MYC-CORE-009` | The factory MUST NOT merge or release without the required gates. | Gate results | CI and ruleset check |
| `MYC-CORE-010` | A repository MUST be assessed against the readiness model before its autonomy level is raised. | Readiness report | Assessment review |
| `MYC-CORE-011` | Every exception MUST be time-bound, owned, and audited. | Exception record | Audit sample |
| `MYC-CORE-012` | The factory MUST record variance when evidence is not reproducible. | Variance note | Reproducibility check |

### Failure modes

An unmet core requirement has one of four outcomes:

1. The work item is `blocked` until the missing artifact or decision arrives.
2. The work item is `rejected` with the reason and evidence.
3. The run is `aborted` by policy or budget.
4. The repository's autonomy ceiling is lowered by the assessor.

Silent success is never an allowed outcome.

## 11. Conformance profiles

| Profile | Target level | Required controls | Human role |
| --- | --- | --- | --- |
| **Minimal** | L1 | Work item, role contract, policy, evidence manifest, terminal states | Merges every change |
| **Standard** | L2 | Minimal plus sandbox, independent review, human acceptance sampling, trace | Accepts by sampling |
| **High-assurance** | L3-L4 | Standard plus provenance, mutation testing, incident response, evaluations, readiness assessment | Policy, high risk, audit |

A profile inherits the requirements of the profiles before it. A repository
MUST declare its profile and target level in `mycelia.yaml` (planned schema).

## 12. Change and versioning

The specification uses Semantic Versioning. A requirement ID is stable after
it becomes normative; a removal or semantic change requires a major version.
The change process, owners, review cadence, and exception rules are in
[GOVERNANCE.md](GOVERNANCE.md).

## 13. Open questions

- How should reviewer independence be measured when only one model is
  available?
- How should readiness scoring work for monorepos and multi-repository
  changes?
- Which controls should be mandatory for L4 in a small team?

## 14. References

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [GLOSSARY.md](GLOSSARY.md) — terminology
- [AGENTS.md](AGENTS.md) — operating contract
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution guide
- [docs/README.md](docs/README.md) — documentation map
- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174)
- [OpenCode documentation](https://opencode.ai/docs/)
