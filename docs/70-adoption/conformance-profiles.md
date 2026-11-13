# Conformance profiles

Status: Draft

## 1. Purpose

An adopter needs a clear target and a claim they can defend with evidence.
This document defines the Minimal, Standard, and High-assurance profiles, the
conformance claim, and the selection rules.

## 2. Profiles

| Profile | Target level | Human role | Allowed risk |
| --- | --- | --- | --- |
| Minimal | L1 | Merges every change | R0-R2 with review |
| Standard | L2 | Accepts by sampling | R0-R2; R3/R4 human |
| High-assurance | L3-L4 | Policy, high risk, audit | R0-R2 unattended; R3/R4 human |

A profile inherits the profiles before it.

## 3. Profile requirements

### Minimal

Required controls at 2 or higher:

- `CTL-01` to `CTL-04`
- `CTL-07`, `CTL-08`
- `CTL-10` to `CTL-14`

The repository has a work item, a role contract, a policy, an evidence
manifest, and terminal states. A human runs the checks and merges.

### Standard

Minimal plus these controls at 2 or higher:

- `CTL-05`, `CTL-06`, `CTL-09`
- `CTL-15` to `CTL-17`
- `CTL-19`, `CTL-21`

The repository has a sandbox, an independent reviewer, acceptance sampling, a
trace, a merge queue, and a tested rollback. A human accepts by sampling.

### High-assurance

Standard plus these controls at 3 or higher:

- `CTL-20`, `CTL-22`, `CTL-23`, `CTL-24`

For L4, `CTL-15`, `CTL-16`, `CTL-17`, `CTL-23`, and `CTL-24` must be at 3 or
higher, and the incident and concurrency drills must pass.

The repository has mutation testing, provenance, incident drills, and an
evaluation suite. A human owns policy, high risk, and audit.

## 4. Conformance claim

A claim names:

- the profile and level
- the commit assessed
- the readiness report
- the evidence sampled
- the deviations and exceptions
- the date

Example:

> Conformant to Mycelia Standard at L2, assessed at commit `abc123`, report
> `RPT-001`, on 2026-11-13. No active exceptions.

A claim is invalid when:

- the report is expired
- a blocker is open
- a control lacks evidence
- the repository changed materially since the assessment

## 5. Selection, upgrade, and downgrade

- Start at Minimal.
- Move to Standard after an L2 assessment.
- Move to High-assurance before targeting L3 or L4.
- A repository may run below its profile; it may not run above it.
- Downgrade after an incident, a failed assessment, or a policy change.
- Record the change in the readiness report and the release notes.

## 6. Profile matrix

| Capability | Minimal | Standard | High-assurance |
| --- | --- | --- | --- |
| Work item and evidence | Yes | Yes | Yes |
| Role and policy | Yes | Yes | Yes |
| Sandbox | Recommended | Required | Required |
| Independent review | Recommended | Required | Required |
| Acceptance sampling | No | Required | Required |
| Trace | Basic | Required | Required |
| Merge queue | No | Required | Required |
| Mutation testing | No | Recommended | Required |
| Provenance | No | Recommended | Required |
| Incident drills | No | Recommended | Required |
| Evaluations | No | Recommended | Required |
| Autonomy ceiling | L1 | L2 | L3-L4 |

## 7. Inheritance

A profile inherits every requirement of the profiles before it. A higher
profile cannot waive a lower-profile requirement; it can only add controls.

## 8. Assessment mapping

The readiness assessment produces the score and the ceiling. The profile is
the target; the ceiling is the safe maximum. The claim is valid only when the
ceiling is at or above the profile's target level.

## 9. Anti-patterns

- Claiming High-assurance without the evidence.
- Using a profile as a badge.
- Skipping Minimal and Standard.
- Mixing profiles per work item without a rule.
- Claiming conformance for another harness.
- A claim with an expired report.
- A profile with no owner.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels
- [readiness-assessment.md](readiness-assessment.md) — assessment
- [template-and-adoption.md](../60-evolution/template-and-adoption.md) — boundary
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [decision-rights.md](../20-control/decision-rights.md) — human role
- `adoption-guide.md` — guide (planned)
- `worked-example.md` — example (planned)
- [docs/README.md](../README.md) — documentation map
