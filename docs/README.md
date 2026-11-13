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

## Control

- [roles-and-permissions.md](20-control/roles-and-permissions.md) — role catalog, permissions, identity
- [policy-as-code.md](20-control/policy-as-code.md) — policy model, precedence, decisions, exceptions
- [evidence-manifest.md](20-control/evidence-manifest.md) — definition of done, evidence, gates
- [decision-rights.md](20-control/decision-rights.md) — decision matrix, oversight, break-glass
- [sandbox-and-isolation.md](20-control/sandbox-and-isolation.md) — isolation levels, sandbox contract
- [supply-chain.md](20-control/supply-chain.md) — inventory, trust levels, AI-BOM, SLSA
- [budgets-and-kill-switch.md](20-control/budgets-and-kill-switch.md) — limits, cost, stop

## Execution

- [autonomous-loop.md](30-execution/autonomous-loop.md) — state machine, checkpoints, resume
- [failure-and-ambiguity.md](30-execution/failure-and-ambiguity.md) — failure classes, retries, escalation
- [multi-agent-concurrency.md](30-execution/multi-agent-concurrency.md) — worktrees, merge queue, handoffs
- [change-lifecycle.md](30-execution/change-lifecycle.md) — branch, draft PR, CI, merge, release
- [opencode-runtime-contract.md](30-execution/opencode-runtime-contract.md) — capabilities, gaps, conformance

## Assurance

- [verification-stack.md](40-assurance/verification-stack.md) — layers, determinism, flake policy
- [test-integrity.md](40-assurance/test-integrity.md) — test-diff guard, mutation, reward hacking
- [review-rubric.md](40-assurance/review-rubric.md) — independence, dimensions, severity, LLM-as-judge
- [human-acceptance.md](40-assurance/human-acceptance.md) — packet, sampling, sign-off, rework
- [release-and-rollback.md](40-assurance/release-and-rollback.md) — release gates, canary, rollback
- [adversarial-and-resilience.md](40-assurance/adversarial-and-resilience.md) — red team, chaos, game days

## Observability

- [trace-and-audit.md](50-observability/trace-and-audit.md) — events, correlation, retention, audit queries
- [provenance.md](50-observability/provenance.md) — source, builder, model, AI-BOM, SLSA
- [metrics-and-health.md](50-observability/metrics-and-health.md) — DORA, SPACE, SLI/SLO, health

## Evolution

- [evaluation-and-model-change.md](60-evolution/evaluation-and-model-change.md) — suite, baseline, canary, rollback
- [rule-lifecycle.md](60-evolution/rule-lifecycle.md) — draft, active, deprecated, retired
- [incident-response.md](60-evolution/incident-response.md) — severity, playbooks, postmortem
- [economics.md](60-evolution/economics.md) — cost model, unit economics, ROI, capacity
- [template-and-adoption.md](60-evolution/template-and-adoption.md) — core, profile, local, upgrade

## Adoption

- [readiness-assessment.md](70-adoption/readiness-assessment.md) — 24 controls, gates, ceiling, gaps
- [conformance-profiles.md](70-adoption/conformance-profiles.md) — Minimal, Standard, High-assurance
- [adoption-guide.md](70-adoption/adoption-guide.md) — greenfield, brownfield, phases
- [worked-example.md](70-adoption/worked-example.md) — baseline, gaps, reassessment
- [opencode-conformance.md](70-adoption/opencode-conformance.md) — runtime checklist
- [coverage-crosswalk.md](70-adoption/coverage-crosswalk.md) — 12 areas, keywords, frameworks
- [assurance-case.md](70-adoption/assurance-case.md) — claims, arguments, evidence

## Interface

- [cli-contract.md](80-interface/cli-contract.md) — commands, flags, exit codes, output
- [file-formats.md](80-interface/file-formats.md) — layout, formats, committed artifacts
- [schemas/README.md](../schemas/README.md) — schema index and validation

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
- [AUDIT](../AUDIT.md) — audit method, findings, and limitations
- [TRACEABILITY](../TRACEABILITY.md) — requirements, controls, schemas
- [AGENTS](../AGENTS.md) — operating contract for agents
- [CONTRIBUTING](../CONTRIBUTING.md) — human contribution guide
