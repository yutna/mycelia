# Concern radar

The radar is the living catalog of industry concerns that affect Mycelia. It
exists so the specification does not depend on what the author remembered.

## Status

| Status | Meaning |
| --- | --- |
| **Adopted** | A normative document owns the concern and defines requirements and evidence. |
| **Adapted** | The concern is adopted with an OpenCode-specific interpretation, recorded in the owning document. |
| **Watch** | The concern is tracked but has no normative document yet. Review before `v1.0.0`. |
| **Out of scope** | The concern is explicitly excluded. Revisit only if the scope changes. |

## Tier 1 — architecture, security, and acceptance

| Concern | Status | Where it lands | Owner |
| --- | --- | --- | --- |
| Context engineering | Adopted | `docs/10-context/context-engineering.md` | Maintainer |
| Prompt injection and indirect injection | Adopted | `docs/00-foundations/threat-model.md` and `docs/40-assurance/adversarial-and-resilience.md` | Security owner |
| Sandboxing and isolation | Adopted | `docs/20-control/sandbox-and-isolation.md` | Security owner |
| Agent supply chain: MCP, plugins, skills | Adopted | `docs/20-control/supply-chain.md` | Security owner |
| Evaluations and eval-driven development | Adopted | `docs/60-evolution/evaluation-and-model-change.md` | Maintainer |
| Reward hacking and specification gaming | Adopted | `docs/40-assurance/test-integrity.md` | Maintainer |
| Observability and OTel GenAI | Adapted | `docs/50-observability/trace-and-audit.md` | Maintainer |
| Durable execution and idempotency | Adapted | `docs/30-execution/autonomous-loop.md` | Maintainer |
| Non-human identity and secrets | Adopted | `docs/20-control/roles-and-permissions.md` | Security owner |
| Progressive delivery and rollback | Adopted | `docs/40-assurance/release-and-rollback.md` | Maintainer |
| Assurance case and AI governance | Adopted | `docs/70-adoption/assurance-case.md` | Maintainer |

## Tier 2 — adoption and operations

| Concern | Status | Where it lands | Owner |
| --- | --- | --- | --- |
| Merge queue, trunk-based development, WIP limits | Adapted | `docs/30-execution/multi-agent-concurrency.md` | Maintainer |
| Cost and FinOps for AI | Adopted | `docs/60-evolution/economics.md` | Maintainer |
| DORA, SPACE, and developer experience | Adapted | `docs/50-observability/metrics-and-health.md` | Maintainer |
| Platform engineering, golden path, scorecards | Adopted | `docs/60-evolution/template-and-adoption.md` | Maintainer |
| Spec-driven development, BDD, Gherkin | Adapted | `docs/10-context/work-intake.md` | Maintainer |
| Chaos engineering and game days | Adopted | `docs/40-assurance/adversarial-and-resilience.md` | Maintainer |
| AI-BOM and SLSA | Adapted | `docs/20-control/supply-chain.md` and `docs/50-observability/provenance.md` | Security owner |
| Data governance, PII, and licensing | Adopted | `docs/20-control/policy-as-code.md` | Security owner |

## Tier 3 — watch and out of scope

| Concern | Status | Reason | Owner |
| --- | --- | --- | --- |
| A2A and AG-UI protocols | Out of scope | Mycelia targets OpenCode only; ACP is the editor integration. Revisit if multi-harness becomes a requirement. | Maintainer |
| Formal methods and design by contract | Watch | Only relevant to the high-assurance profile; no normative document yet. | Maintainer |
| Fine-tuning, distillation, LoRA | Watch | Model changes are controlled by evaluations; training is out of scope. | Maintainer |
| Model gateway and routing | Watch | Provider routing is an implementation choice; may be added for centralized cost or policy. | Maintainer |
| Agent identity standards: OIDC, SPIFFE | Watch | Use a dedicated bot account until the standards mature. | Security owner |

## OpenCode-specific concerns

| Concern | Status | Where it lands | Owner |
| --- | --- | --- | --- |
| Agent harness semantics | Adapted | `docs/30-execution/opencode-runtime-contract.md` | Maintainer |
| Permissions versus policies | Adopted | `docs/30-execution/opencode-runtime-contract.md` | Security owner |
| Subagents, worktrees, and merge queues | Adopted | `docs/30-execution/multi-agent-concurrency.md` | Maintainer |
| Snapshots, revert, and compaction | Adopted | `docs/30-execution/autonomous-loop.md` | Maintainer |
| Provider and model routing | Adapted | `docs/60-evolution/evaluation-and-model-change.md` | Maintainer |
| OpenCode version drift | Watch | `docs/70-adoption/opencode-conformance.md` | Maintainer |

## Adding a concern

1. Add one row with a status and an owner.
2. Point to the owning document, or use a code span while the document is
   planned.
3. If the status is adopted, add requirement IDs, evidence, and verification
   to the owning document.
4. If the status is out of scope, record the reason and the condition that
   would reopen it.
5. Update the review date in the pull request.

## Review cadence

- Quarterly, with the specification review.
- After an incident or a near miss.
- After a model, provider, or policy change.
- After a major OpenCode release.
- Before raising a repository's autonomy level.
- Before the `v1.0.0` freeze.

## Open questions

- Which Tier 3 concerns must become adopted before `v1.0.0`?
- How should supply-chain assurance be measured for MCP servers?
- Should OTel GenAI be mandatory for the Standard profile or only the
  high-assurance profile?

## Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [GLOSSARY.md](../../GLOSSARY.md) — terminology
- [docs/README.md](../README.md) — documentation map
