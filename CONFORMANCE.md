# Conformance statement — v1.0.0

Status: Released

## 1. Purpose

This statement records what Mycelia v1.0.0 includes, what an adopter can claim,
the evidence behind the claim, and the limitations. It is a specification
release, not a certification.

## 2. What v1.0.0 includes

- The normative specification, from principles to interface contracts.
- 24 readiness controls across 8 domains.
- Three conformance profiles: Minimal, Standard, High-assurance.
- 17 JSON Schemas with validated examples.
- The OpenCode profile: permissions, policies, agents, commands, and skills.
- The readiness assessment and the autonomy ceiling.
- The adoption guide and a worked example.
- The coverage crosswalk, assurance case, audit, and traceability matrix.

## 3. What an adopter can claim

An adopter may claim:

- conformance to the Minimal, Standard, or High-assurance profile
- an autonomy ceiling at a specific level
- the evidence and the exceptions behind the claim

An adopter may not claim:

- certification or accreditation by Mycelia
- a level above its assessed ceiling
- a control it has not evidenced
- conformance for a harness other than OpenCode

## 4. Evidence

The release is backed by:

- the CI checks: markdownlint, link check, actionlint, schema validation,
  OpenCode config validation
- the 17 schemas and their examples
- the coverage crosswalk
- the assurance case
- the audit and its dispositions
- the traceability matrix
- the release tag `v1.0.0` and the GitHub Release

## 5. Limitations

- No reference implementation is included.
- No external human review has been completed.
- No production evidence exists.
- No legal review has been completed.
- The specification targets OpenCode V2 only.
- The external framework mapping is informative.
- A low-severity dev dependency advisory remains open.
- The model provider is outside the factory's control.
- No formal proof is claimed.
- The self-assessment is not independent.

## 6. Self-assessment of this repository

The specification repository is assessed at **L0** by its own model. It is a
specification, not a running factory; the runtime controls are defined but not
exercised here. See [AUDIT.md](AUDIT.md).

This is intentional: the model is honest about the difference between a
documented control and an operating control.

## 7. Claim template

An adopter can use this template:

```text
Repository: <owner/repo>
Profile: <minimal|standard|high-assurance>
Level: <L1|L2|L3|L4>
Assessed commit: <sha>
Readiness report: <RPT-id>
Evidence sampled: <list>
Exceptions: <list or none>
Assessor: <name or role>
Date: <YYYY-MM-DD>
```

A claim is invalid when the report is expired, a blocker is open, a control
lacks evidence, or the repository changed materially since the assessment.

## 8. Versioning

Mycelia uses Semantic Versioning. `v1.0.0` is the first stable specification
release. A change that invalidates a conformance claim requires a major
version.

## 9. Related documents

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [AUDIT.md](AUDIT.md) — audit and self-assessment
- [TRACEABILITY.md](TRACEABILITY.md) — requirements, controls, schemas
- [coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md) — coverage
- [assurance-case.md](docs/70-adoption/assurance-case.md) — claims and evidence
- [conformance-profiles.md](docs/70-adoption/conformance-profiles.md) — profiles
- [readiness-assessment.md](docs/70-adoption/readiness-assessment.md) — assessment
- [docs/README.md](docs/README.md) — documentation map
