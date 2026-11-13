# Autonomy levels and risk tiers

Status: Draft

This document expands the L0-L4 and R0-R4 definitions in [SPEC.md](../../SPEC.md)
into preconditions, evidence, and operating rules.

## 1. Purpose

The autonomy level says how much the factory may do without routine human
action. The risk tier says how much independence a change needs. The two
together decide who accepts a change.

## 2. Autonomy levels

| Level | What runs | Human role | Preconditions | Evidence |
| --- | --- | --- | --- | --- |
| L0 Manual | Nothing autonomous | Does the work; uses the spec as a checklist | None | Manual record |
| L1 Assisted | Agent proposes a plan and a change | Runs checks and merges every change | Work item, role contract, policy, evidence manifest | Agent output and human-run checks |
| L2 Supervised | Agent runs the loop in a sandbox; independent reviewer | Accepts by sampling; handles exceptions | L1 plus sandbox, independent review, acceptance sampling, trace | Manifest, review, sample record |
| L3 Autonomous | Agent merges R0-R2 after evidence gates | Handles R3 and R4, policy, incidents | L2 plus provenance, mutation testing, incident response, evaluations, readiness assessment | Gates, trace, provenance, evaluation |
| L4 Unattended | Multi-agent concurrency; policy-gated merge | Owns policy, audits by sampling, commands incidents | L3 plus concurrency controls, merge queue, budgets, observability, audit sampling, incident drills | All evidence plus sampling and drills |

### L0 — Manual

The factory is a checklist. A human writes the change, runs the checks, and
records the evidence. The specification is still useful because it defines what
evidence a human should produce.

### L1 — Assisted

The agent may plan and propose a patch. A human runs the checks and merges every
change. The value is faster drafting, not delegation of judgment. The
repository needs a work item, a role contract, policy, and an evidence
manifest before L1 is meaningful.

### L2 — Supervised

The agent runs the loop inside a sandbox. A verifier runs the evidence manifest,
and an independent reviewer checks the change. A human accepts by sampling and
handles exceptions. The repository needs a trace so the sample can be audited.

### L3 — Autonomous

The agent may merge R0-R2 changes after the evidence gates pass. A human still
handles R3 and R4, policy changes, and incidents. The repository needs
provenance, mutation testing, an incident process, and an evaluation suite
before L3 is safe.

### L4 — Unattended

Multiple agents may work concurrently on a task DAG. A merge queue serializes
the integration. Policy gates decide R0-R2 merges; humans are on the loop for
R3 and sign off on R4. The repository needs concurrency controls, budgets, 24/7
observability, audit sampling, and incident drills.

L4 is not "no humans". It is "no routine human action for R0-R2 work, with
humans retaining policy ownership, high-risk decisions, and incident command."

## 3. Risk tiers

| Tier | Examples | Required independence | Acceptance | Rollback |
| --- | --- | --- | --- | --- |
| R0 | Documentation, comments, formatting | CI | Automated gate | Revert |
| R1 | Tests, internal tooling, non-production scripts | CI plus review | Automated gate plus review | Revert |
| R2 | Normal feature or bug fix | Independent review | Review plus evidence gates | Revert or feature flag |
| R3 | Auth, payments, data schema, infrastructure, security configuration | Independent review plus human acceptance | Human acceptance | Tested rollback plan |
| R4 | Production credentials, destructive migrations, incident response, safety-critical changes | Human plus security review | Human sign-off | Tested rollback plan and incident command |

### R0 — Documentation and formatting

Low blast radius. The main risk is misinformation. CI and a link check are
enough. A human may sample.

### R1 — Tests and internal tooling

The change can affect the feedback loop but not production behavior. A review
is required because a weak test can hide a defect.

### R2 — Normal feature or bug fix

The change affects product behavior. Independent review and evidence gates are
required. A rollback path must exist.

### R3 — Sensitive areas

The change can affect access, money, data shape, infrastructure, or security.
A human must accept it, even at L4. The rollback plan must be tested.

### R4 — Critical and security-sensitive

The change can affect production credentials, destructive data operations,
incident response, or safety. A human signs off, and a security review is
required. The rollback plan and incident command must be ready.

## 4. Autonomy matrix

| Risk | L1 | L2 | L3 | L4 |
| --- | --- | --- | --- | --- |
| R0 | Human merge | Supervised | Autonomous | Unattended |
| R1 | Human merge | Supervised | Autonomous | Unattended |
| R2 | Human merge | Supervised | Autonomous | Unattended |
| R3 | Human | Human | Human acceptance | Human-on-the-loop |
| R4 | Human | Human | Human | Human sign-off |

"Autonomous" means evidence-gated merge, not unreviewed merge. "Unattended"
means no routine human action, not no accountability.

## 5. Autonomy ceiling

The autonomy ceiling is the highest level the repository may run at, given its
weakest blocking control. It is not an average and not a target.

### Calculation

1. Start at L4.
2. Check every precondition for L4. If any is unmet, lower the ceiling to L3.
3. Check every precondition for L3. If any is unmet, lower the ceiling to L2.
4. Check every precondition for L2. If any is unmet, lower the ceiling to L1.
5. Check every precondition for L1. If any is unmet, the ceiling is L0.
6. The first level whose preconditions are all met is the ceiling.
7. Record the evidence for each met and unmet control.

A single unmet blocking control caps the ceiling. A strong control elsewhere
does not compensate.

### Examples

| Condition | Ceiling |
| --- | --- |
| No concurrency controls | L3 |
| No mutation testing | L2 |
| No independent review | L1 |
| No work item or evidence manifest | L0 |

The ceiling is per repository. A work item may run below the ceiling, but never
above it. R3 and R4 still require human acceptance at any ceiling.

## 6. Promotion

A repository may be promoted one level at a time when:

- it has completed at least one full version milestone at the current level
- no critical incident or escaped defect is attributable to the factory
- the evaluation suite passes at the required threshold
- the readiness report shows every blocking control for the next level is met
- the human owner approves the promotion
- the promotion is recorded in the readiness report and the governance record

Promotion is not automatic. A passing check is necessary, not sufficient.

## 7. Demotion

A repository must be demoted when:

- a critical incident or escaped defect is attributable to the factory
- evidence is found to be fabricated, stale, or self-certified
- a policy violation occurs
- gate failures repeat beyond the agreed threshold
- model or provider drift exceeds the evaluation threshold
- a security finding invalidates a control

A security incident may demote the repository immediately. Otherwise the human
owner decides, records the reason, and runs the incident process. Promotion
requires a new assessment.

## 8. Operating rules

1. A human can stop any run at any time.
2. An agent cannot change its own autonomy level, policy, risk tier, or
   evidence manifest.
3. R3 and R4 always require a human, even at L4.
4. A work item may run below the repository ceiling.
5. A work item must never run above the repository ceiling.
6. The ceiling is recorded in `mycelia.yaml` (planned) and the readiness report.
7. An exception is time-bound and does not raise the ceiling.
8. The default level is L1 until an assessment says otherwise.

## 9. Assessment questions

- Which level is claimed, and which evidence supports each precondition?
- Which unmet control caps the ceiling?
- What is the next promotion step?
- What would trigger a demotion?
- Which R3 and R4 changes are currently waiting for a human?

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](principles.md) — design principles
- [threat-model.md](threat-model.md) — threats and controls
- [reference-architecture.md](reference-architecture.md) — layers and components
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [docs/README.md](../README.md) — documentation map
