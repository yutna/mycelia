# Assurance case

Status: Draft

## 1. Purpose

An assurance case states a claim, argues why it is true, and shows the evidence.
This document is the top-level case for Mycelia: it connects the claims to the
specification and the evidence.

The structure follows the claims-arguments-evidence pattern used by Goal
Structuring Notation (GSN). It is informative, not a formal proof.

## 2. Claim hierarchy

**C1.** For a repository assessed at level Lx, the factory constrains authority,
bounds execution, produces trustworthy evidence, and recovers from failure.

| Subclaim | Statement |
| --- | --- |
| C1.1 | Authority is bounded by roles, policy, and isolation. |
| C1.2 | Work is well-formed by intake and context. |
| C1.3 | Execution is bounded, durable, and recoverable. |
| C1.4 | Evidence is trustworthy and independently verified. |
| C1.5 | Operations are observable and incidents are recoverable. |
| C1.6 | The system evolves only through evaluated change. |

## 3. Arguments and evidence

| Claim | Argument | Evidence |
| --- | --- | --- |
| C1.1 | Roles limit actions; policies deny red lines; the sandbox contains the process | Role contract, policy decision, negative test, sandbox test |
| C1.2 | The work item defines the goal and the evidence; context is assembled and refreshed | Work item, context manifest, readiness report |
| C1.3 | The loop has gates, checkpoints, budgets, and terminal states | Run state, resume test, kill-switch drill |
| C1.4 | The manifest defines done; mutation protects tests; review and acceptance are independent | Evidence manifest, test integrity report, review record, acceptance record |
| C1.5 | Every action is traced; provenance links artifacts; incidents have a playbook | Trace export, provenance record, incident record |
| C1.6 | Model, prompt, and policy changes pass an evaluation; rules have a lifecycle | Evaluation record, rule registry, readiness report |

## 4. GSN-style view

```text
C1 Factory safe at Lx
├── C1.1 Authority bounded
│   ├── A1 Role contracts limit actions
│   ├── A2 Policies deny red lines
│   └── E1 Negative policy and sandbox tests
├── C1.2 Work well-formed
│   ├── A3 Work item defines done
│   ├── A4 Context is assembled and fresh
│   └── E2 Work item and context evidence
├── C1.3 Execution bounded
│   ├── A5 State machine with gates
│   ├── A6 Budgets and stop conditions
│   └── E3 Run state and drills
├── C1.4 Evidence trustworthy
│   ├── A7 Manifest and verification
│   ├── A8 Test integrity
│   ├── A9 Independent review
│   └── E4 Integrity, review, acceptance
├── C1.5 Operations observable
│   ├── A10 Trace and provenance
│   ├── A11 Incident response
│   └── E5 Trace, provenance, incident
└── C1.6 Evolution controlled
    ├── A12 Evaluations
    ├── A13 Rule lifecycle
    └── E6 Evaluation, registry, readiness
```

## 5. Assurance deficits

The case is only as strong as its evidence. Known deficits:

- The specification is not a certification.
- The controls depend on the implementation, not only on the document.
- Human factors, such as approval fatigue, are mitigated but not eliminated.
- The model provider is a trust boundary outside the factory.
- Model behavior can change without a version change.
- Evidence can be stale or incomplete.
- The external framework mapping is informative.
- No formal proof is claimed.

Each deficit is either accepted with a rationale or tracked as a gap.

## 6. Review

Review the assurance case:

- before an L3 or L4 promotion
- quarterly
- after an incident
- after a model, provider, or policy change
- after a framework or standard change

The review records the claims checked, the evidence sampled, the deficits
accepted, and the actions.

## 7. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [coverage-crosswalk.md](coverage-crosswalk.md) — framework mapping
- [readiness-assessment.md](readiness-assessment.md) — assessment
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [incident-response.md](../60-evolution/incident-response.md) — incidents
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [docs/README.md](../README.md) — documentation map
