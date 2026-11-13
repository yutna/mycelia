---
name: Mycelia spec writing
description: Write and update Mycelia specifications with requirement IDs, evidence, and verification.
---

# Mycelia spec writing

Use this skill when adding or changing a normative document.

## Template

1. Purpose
2. Scope and non-goals
3. Definitions
4. Requirements
5. Data contracts
6. Control flow or lifecycle
7. Evidence and verification
8. Failure modes and escalation
9. Observability and audit
10. Adoption and conformance
11. Anti-patterns and threat considerations
12. Open questions
13. References

## Requirement format

Each requirement has an ID (`MYC-<AREA>-###`), an RFC 2119 statement, the
autonomy levels and risk tiers it applies to, the evidence it produces, the
verification method, and the failure mode when it is unmet.

## Checks

- Run `mise run lint`.
- Add the requirement to the traceability matrix.
- Update the glossary when a term is new.
