# Conformance statement — v2.0.0

Status: Released

## 1. Purpose

This statement records what Mycelia v2.0.0 includes, what an adopter can claim,
the evidence behind the claim, and the limitations. It is a specification
release, not a certification.

## 2. What v2.0.0 includes

- The normative specification, from principles to interface contracts.
- 50 requirement IDs: `MYC-CORE-001` to `MYC-CORE-013`, `MYC-EXE-001` to
  `MYC-EXE-021`, `MYC-CTL-001` to `MYC-CTL-007`, `MYC-ASR-001` to
  `MYC-ASR-006`, `MYC-INT-001`, `MYC-ADP-001`, and `MYC-ADP-002`.
- The normative [runtime contract](docs/30-execution/opencode-runtime-contract.md)
  that a conformant runtime implements.
- The [conformance kit contract](docs/70-adoption/conformance-kit.md) and 25
  fixtures as YAML data in `conformance/fixtures/`.
- Two architecture decisions: the scope boundary
  ([ADR-0001](docs/00-foundations/decisions/0001-scope-boundary.md)) and the
  runtime stack ([ADR-0002](docs/00-foundations/decisions/0002-runtime-stack.md)).
- 24 readiness controls across 8 domains.
- Three conformance profiles: Minimal, Standard, High-assurance.
- 35 JSON Schemas with validated examples.
- The OpenCode profile: permissions, policies, agents, commands, and skills.
- The readiness assessment and the autonomy ceiling.
- The adoption guide and a worked example with records that validate.
- The coverage crosswalk, assurance case, audit, and traceability matrix.
- The release notes in [CHANGELOG.md](CHANGELOG.md), with the migration from
  `v1.0.0`.

## 3. What an adopter can claim

An adopter may claim:

- conformance to the Minimal profile; Standard and High-assurance target L2
  and higher, so they need a conformance result (below)
- an autonomy ceiling at L0 or L1
- the evidence and the exceptions behind the claim

From L2, `MYC-CORE-013` requires a conformant runtime and a passing
conformance kit result for the declared profile. `v2.0.0` ships the kit
contract and fixtures but no kit implementation, so no repository can show this
evidence yet. Under `v2.0.0` the highest claimable level is L1; L2 to L4 claims
become possible when a kit implementation exists (planned for `v2.1.0`).

An adopter may not claim:

- certification or accreditation by Mycelia
- a level above its assessed ceiling
- L2 or higher without a passing conformance kit result
- a control it has not evidenced
- conformance for a harness other than OpenCode

## 4. Evidence

The release is backed by:

- the CI checks: markdownlint, link check, actionlint, schema validation,
  OpenCode config validation, the fixture-name meta-check
  (`scripts/check-fixture-names.sh`), and the worked-example check
  (`scripts/check-worked-example.sh`)
- the 35 schemas and their examples
- the 25 conformance fixtures
- the coverage crosswalk
- the assurance case
- the audit and its dispositions
- the traceability matrix
- the release tag `v2.0.0`, the GitHub Release, and the release notes

## 5. Limitations

- No reference runtime and no executable conformance kit are included; both
  are planned in `runtime/` from `v2.1.0`. Until then the ceiling is L1.
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
Profile: <minimal> (standard and high-assurance need a conformance result)
Level: <L0|L1> (L2-L4 need a conformance result)
Conformance result: <id or none>
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

Mycelia uses Semantic Versioning. `v1.0.0` was the first stable specification
release. `v2.0.0` is a major release because it changes conformance claims:
the scope boundary, the runtime requirement from L2, and the raised OpenCode
floor (`OC-01`). A change that invalidates a conformance claim requires a major
version. See [CHANGELOG.md](CHANGELOG.md).

## 9. Related documents

- [README.md](README.md) — project identity and map
- [CHANGELOG.md](CHANGELOG.md) — release notes and migration
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [AUDIT.md](AUDIT.md) — audit and self-assessment
- [TRACEABILITY.md](TRACEABILITY.md) — requirements, controls, schemas
- [coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md) — coverage
- [assurance-case.md](docs/70-adoption/assurance-case.md) — claims and evidence
- [conformance-profiles.md](docs/70-adoption/conformance-profiles.md) — profiles
- [readiness-assessment.md](docs/70-adoption/readiness-assessment.md) — assessment
- [docs/README.md](docs/README.md) — documentation map
