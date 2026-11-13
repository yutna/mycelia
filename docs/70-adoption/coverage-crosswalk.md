# Coverage crosswalk

Status: Draft

## 1. Purpose

The audit must show that nothing from the original list, the industry
keywords, or the external frameworks was dropped. This crosswalk maps each
concern to the document that owns it.

## 2. The 12 original areas

| # | Area | Owning document |
| --- | --- | --- |
| 1 | Machine-readable rule and evidence manifest | [evidence-manifest.md](../20-control/evidence-manifest.md) |
| 2 | Agent role and permission contract | [roles-and-permissions.md](../20-control/roles-and-permissions.md) |
| 3 | Autonomous loop and state machine | [autonomous-loop.md](../30-execution/autonomous-loop.md) |
| 4 | Policy as code | [policy-as-code.md](../20-control/policy-as-code.md) |
| 5 | Test integrity and mutation testing | [test-integrity.md](../40-assurance/test-integrity.md) |
| 6 | Human acceptance harness | [human-acceptance.md](../40-assurance/human-acceptance.md) |
| 7 | Review rubric | [review-rubric.md](../40-assurance/review-rubric.md) |
| 8 | Decision rights matrix | [decision-rights.md](../20-control/decision-rights.md) |
| 9 | Failure and ambiguity protocol | [failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) |
| 10 | Agent observability and audit | [trace-and-audit.md](../50-observability/trace-and-audit.md) |
| 11 | Multi-agent concurrency | [multi-agent-concurrency.md](../30-execution/multi-agent-concurrency.md) |
| 12 | Template and adoption boundary | [template-and-adoption.md](../60-evolution/template-and-adoption.md) |

## 3. Tier 1 keywords

| Keyword | Owning document |
| --- | --- |
| Context engineering | [context-engineering.md](../10-context/context-engineering.md) |
| Prompt injection | [threat-model.md](../00-foundations/threat-model.md), [adversarial-and-resilience.md](../40-assurance/adversarial-and-resilience.md) |
| Sandboxing | [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) |
| Agent supply chain | [supply-chain.md](../20-control/supply-chain.md) |
| Evaluations | [evaluation-and-model-change.md](../60-evolution/evaluation-and-model-change.md) |
| Reward hacking | [test-integrity.md](../40-assurance/test-integrity.md) |
| Observability and OTel | [trace-and-audit.md](../50-observability/trace-and-audit.md) |
| Durable execution | [autonomous-loop.md](../30-execution/autonomous-loop.md) |
| Non-human identity and secrets | [roles-and-permissions.md](../20-control/roles-and-permissions.md) |
| Progressive delivery and rollback | [release-and-rollback.md](../40-assurance/release-and-rollback.md) |
| Assurance case and AI governance | [assurance-case.md](assurance-case.md) |

## 4. Tier 2 keywords

| Keyword | Owning document |
| --- | --- |
| Merge queue, trunk-based, WIP limits | [multi-agent-concurrency.md](../30-execution/multi-agent-concurrency.md) |
| Cost and FinOps | [economics.md](../60-evolution/economics.md) |
| DORA, SPACE, DevEx | [metrics-and-health.md](../50-observability/metrics-and-health.md) |
| Platform engineering and golden path | [template-and-adoption.md](../60-evolution/template-and-adoption.md) |
| Spec-driven development and BDD | [work-intake.md](../10-context/work-intake.md) |
| Chaos engineering and game days | [adversarial-and-resilience.md](../40-assurance/adversarial-and-resilience.md) |
| AI-BOM and SLSA | [supply-chain.md](../20-control/supply-chain.md), [provenance.md](../50-observability/provenance.md) |
| Data governance, PII, licensing | [policy-as-code.md](../20-control/policy-as-code.md) |

## 5. Tier 3 and out of scope

| Concern | Status | Reason |
| --- | --- | --- |
| A2A and AG-UI | Out of scope | OpenCode-only; revisit if multi-harness becomes a requirement |
| Formal methods | Watch | High-assurance only |
| Fine-tuning and distillation | Watch | Training is out of scope |
| Model gateway and routing | Watch | Implementation choice |
| Agent identity standards | Watch | Use a dedicated bot account until standards mature |

## 6. External frameworks

The mapping is informative, not a certification.

| Framework | Concern | Owning document |
| --- | --- | --- |
| NIST AI RMF | Govern, map, measure, manage | [GOVERNANCE.md](../../GOVERNANCE.md), [metrics-and-health.md](../50-observability/metrics-and-health.md), [incident-response.md](../60-evolution/incident-response.md) |
| ISO/IEC 42001 | AI policy, roles, risk, operation, evaluation, improvement | [SPEC.md](../../SPEC.md), [GOVERNANCE.md](../../GOVERNANCE.md), [rule-lifecycle.md](../60-evolution/rule-lifecycle.md) |
| ISO/IEC 12207 | Lifecycle, verification, validation, configuration, quality | [change-lifecycle.md](../30-execution/change-lifecycle.md), [verification-stack.md](../40-assurance/verification-stack.md) |
| SLSA | Source, build, provenance, dependencies | [supply-chain.md](../20-control/supply-chain.md), [provenance.md](../50-observability/provenance.md) |
| OWASP LLM Top 10 | Prompt injection, disclosure, supply chain, excessive agency, consumption | [threat-model.md](../00-foundations/threat-model.md), [policy-as-code.md](../20-control/policy-as-code.md) |
| OWASP ASVS | Access control, validation, cryptography, data protection | [roles-and-permissions.md](../20-control/roles-and-permissions.md), [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) |
| OpenSSF Scorecard | Branch protection, review, CI tests, dependency updates, security policy | [change-lifecycle.md](../30-execution/change-lifecycle.md), [supply-chain.md](../20-control/supply-chain.md) |
| EU AI Act | Risk management, data governance, documentation, record-keeping, oversight, robustness | [assurance-case.md](assurance-case.md), [trace-and-audit.md](../50-observability/trace-and-audit.md) |

## 7. Gaps and limitations

- The crosswalk is not a certification.
- The EU AI Act mapping is informative and not legal advice.
- Framework versions change; the crosswalk is reviewed quarterly.
- Some controls depend on the implementation, not only the specification.
- The mapping is not exhaustive; a gap can be added as a concern.

## 8. Maintenance

- Add a row when a new document or concern is added.
- Update the framework version when it changes.
- Review the crosswalk with the concern radar.
- Record the review in the governance record.

## 9. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [concern-radar.md](../00-foundations/concern-radar.md) — concerns
- [assurance-case.md](assurance-case.md) — claims and evidence
- [readiness-assessment.md](readiness-assessment.md) — assessment
- [docs/README.md](../README.md) — documentation map
