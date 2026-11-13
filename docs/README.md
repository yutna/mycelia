# Documentation

This directory holds the normative specification. The root files are the entry
points; the numbered directories are the layers.

## Reading paths

| If you want to... | Read |
| --- | --- |
| Understand the project | [README](../README.md), [SCOPE](../SCOPE.md) |
| Adopt the profile | [AGENTS](../AGENTS.md), [CONTRIBUTING](../CONTRIBUTING.md), `docs/70-adoption/` |
| Understand the model | `docs/00-foundations/` then `docs/20-control/` |
| Audit a change | `docs/40-assurance/` and `docs/50-observability/` |
| Build an integration | `docs/80-interface/` |

## Section map

```text
docs/
  00-foundations/   principles, threat model, architecture, autonomy levels
  10-context/       repository legibility, work intake, context engineering
  20-control/       roles, policy, evidence, decision rights, sandbox, supply chain
  30-execution/     loop, failure, concurrency, change lifecycle, OpenCode contract
  40-assurance/     verification, test integrity, review, acceptance, release
  50-observability/ trace, provenance, metrics
  60-evolution/     evaluations, rule lifecycle, adoption, incidents, economics
  70-adoption/      readiness, profiles, adoption guide, conformance, audit
  80-interface/     CLI contract, file formats
```

## Foundations

- [principles.md](00-foundations/principles.md) — design principles
- [threat-model.md](00-foundations/threat-model.md) — assets, boundaries, threats
- [reference-architecture.md](00-foundations/reference-architecture.md) — layers and components
- [system-context.md](00-foundations/system-context.md) — actors, systems, boundaries
- [autonomy-levels.md](00-foundations/autonomy-levels.md) — L0-L4, R0-R4, ceiling, promotion
- [concern-radar.md](00-foundations/concern-radar.md) — adopted, adapted, watch, and out-of-scope concerns

## Context

- [repository-legibility.md](10-context/repository-legibility.md) — what a repository must expose
- [work-intake.md](10-context/work-intake.md) — work item contract and definition of ready
- [context-engineering.md](10-context/context-engineering.md) — sources, memory, compaction, freshness

## Status

`v0.1.0` establishes the identity, the OpenCode profile, and the operating
contract. The normative documents are added in later milestones. Until a
document exists, treat its section as planned, not normative.

## Root documents

- [README](../README.md) — project identity and map
- [SCOPE](../SCOPE.md) — boundaries, claims, and limitations
- [GLOSSARY](../GLOSSARY.md) — shared terminology
- [AGENTS](../AGENTS.md) — operating contract for agents
- [CONTRIBUTING](../CONTRIBUTING.md) — human contribution guide
