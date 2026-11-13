# Reference architecture

Status: Draft

Runtime: OpenCode V2, tested with version 2.2.6 or newer

## 1. Purpose

This document is the map of the factory. It shows the layers, the components
that implement each layer, the data that flows between them, and the OpenCode
primitive behind each control.

## 2. Design stance

- **Contract-level topology-agnostic.** The specification defines roles,
  permissions, evidence, and state. It does not require a specific number of
  agents or models.
- **Crew is the reference topology.** Planner, implementer, verifier, reviewer,
  and integrator run as separate roles, which makes separation of duties
  testable.
- **Swarm is an extension.** Many workers on a task DAG are allowed when the
  concurrency controls and merge queue are in place.
- **Singleton is the starting point.** One agent may run several roles in fresh
  contexts, but R3 and R4 still need independent verification.
- **OpenCode is the runtime.** Mycelia configures and constrains OpenCode; it
  does not reimplement the agent loop, the tool gateway, or the policy engine.

## 3. Planes

| Plane | Responsibility | Primary artifacts |
| --- | --- | --- |
| Context | Supply the right repository, task, and reference material | Work item, repository map, references, skills |
| Control | Decide who may do what and what proves completion | Role contract, policy decision, evidence manifest |
| Execution | Move work through a bounded, resumable loop | State record, handoff, change request |
| Assurance | Prove the change is correct and acceptable | Test evidence, mutation score, review, sign-off |
| Observability | Record what happened and why | Trace, provenance, metrics |
| Evolution | Improve the system without losing quality | Evaluation result, rule change, readiness report |

## 4. Components and OpenCode mapping

### 4.1 Context plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Repository instructions | `AGENTS.md`, `instructions` | `docs/10-context/repository-legibility.md` |
| External references | `references` | `docs/10-context/context-engineering.md` |
| Procedural knowledge | `skills` | `docs/10-context/context-engineering.md` |
| Long-session memory | Sessions, compaction | `docs/30-execution/autonomous-loop.md` |
| Work item | Issue plus `mycelia.yaml` | `docs/10-context/work-intake.md` |

### 4.2 Control plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Role contract | Agent config, per-agent `permissions`, `steps` | `docs/20-control/roles-and-permissions.md` |
| Policy | Top-level `policies` (hard deny) | `docs/20-control/policy-as-code.md` |
| Evidence manifest | Schema plus CI checks | `docs/20-control/evidence-manifest.md` |
| Decision rights | Agent modes, human approval, policies | `docs/20-control/decision-rights.md` |
| Sandbox and secrets | Container or VM around OpenCode | `docs/20-control/sandbox-and-isolation.md` |
| Supply chain | `mcp.use`, `plugin.use`, `skill.use` policies | `docs/20-control/supply-chain.md` |

### 4.3 Execution plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Loop and state | Sessions, `opencode run`, server API | `docs/30-execution/autonomous-loop.md` |
| Failure handling | Prompt hooks, permissions, blocked state | `docs/30-execution/failure-and-ambiguity.md` |
| Concurrency | Subagents, worktrees, merge queue | `docs/30-execution/multi-agent-concurrency.md` |
| Change lifecycle | Branch, pull request, CI, merge | `docs/30-execution/change-lifecycle.md` |
| Runtime contract | OpenCode server, plugin hooks, events | `docs/30-execution/opencode-runtime-contract.md` |

### 4.4 Assurance plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Verification | Verifier subagent, shell allowlist, CI | `docs/40-assurance/verification-stack.md` |
| Test integrity | Mutation and test-diff checks in CI | `docs/40-assurance/test-integrity.md` |
| Review | Reviewer subagent, rubric | `docs/40-assurance/review-rubric.md` |
| Acceptance | Permission prompts, forms, acceptance packet | `docs/40-assurance/human-acceptance.md` |
| Release and rollback | CI, tags, snapshots, revert | `docs/40-assurance/release-and-rollback.md` |
| Adversarial testing | Red-team and chaos checks | `docs/40-assurance/adversarial-and-resilience.md` |

### 4.5 Observability plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Trace | Event stream, session log, server API | `docs/50-observability/trace-and-audit.md` |
| Provenance | Session export, config pins, model variants | `docs/50-observability/provenance.md` |
| Metrics | Usage events, CI results, cost records | `docs/50-observability/metrics-and-health.md` |

### 4.6 Evolution plane

| Component | OpenCode primitive | Specification |
| --- | --- | --- |
| Evaluations | Golden tasks run through `opencode run` | `docs/60-evolution/evaluation-and-model-change.md` |
| Rule lifecycle | Config and policy versioning | `docs/60-evolution/rule-lifecycle.md` |
| Adoption | Template plus readiness report | `docs/60-evolution/template-and-adoption.md` |
| Incidents | Kill switch, session interrupt, revert | `docs/60-evolution/incident-response.md` |
| Economics | Usage events, budgets, model routing | `docs/60-evolution/economics.md` |

## 5. Data flows

### 5.1 Work intake

```text
issue -> work item -> risk tier -> required evidence -> role assignment
```

The work item is the only input the loop may act on. A missing acceptance
criterion is a `blocked` state, not a guess.

### 5.2 Execution

```text
work item -> planner -> implementer -> tool calls -> change -> evidence
```

Every tool call is permission-checked and traced. The loop stops on ambiguity,
policy conflict, repeated failure, or budget exhaustion.

### 5.3 Verification and acceptance

```text
change -> evidence manifest -> verifier -> reviewer -> acceptance packet
       -> human decision -> merge
```

The verifier and reviewer are independent of the implementer. The acceptance
packet is the human-facing summary of the evidence.

### 5.4 Assessment

```text
repository snapshot -> assessor -> readiness report -> gap register
                   -> autonomy ceiling -> remediation plan
```

The report is evidence-based. A control without evidence is unproven.

## 6. Deployment models

| Model | OpenCode surface | Use | Key constraint |
| --- | --- | --- | --- |
| Local | TUI or `opencode run` on a developer machine | Development, exploration, small changes | Shell has host authority; use a container for untrusted work |
| CI | `opencode run --format json` on an ephemeral runner | Automated implementation and verification | No interactive approvals; explicit deny and allow rules |
| Server | `opencode serve` with the HTTP API | Shared runtime, dashboards, multiple clients | Authentication, isolation, and managed policies |
| Desktop or web | Client connected to a server | Human review and acceptance | Same trust boundary as the server |

## 7. Control placement

| Control | Plane | OpenCode mechanism | Specification |
| --- | --- | --- | --- |
| Role scope | Control | Agent permissions and `steps` | `roles-and-permissions.md` |
| Red line | Control | `policies` | `policy-as-code.md` |
| Definition of done | Control | Evidence manifest and CI gates | `evidence-manifest.md` |
| Work item scope | Context | Issue template and work item schema | `work-intake.md` |
| Loop bound | Execution | Session, step limit, budget | `autonomous-loop.md` |
| Concurrency | Execution | Worktrees and merge queue | `multi-agent-concurrency.md` |
| Independent check | Assurance | Verifier and reviewer subagents | `verification-stack.md` |
| Human decision | Assurance | Permission prompts, forms, packet | `human-acceptance.md` |
| Audit | Observability | Event stream and export | `trace-and-audit.md` |
| Improvement | Evolution | Golden tasks and readiness report | `evaluation-and-model-change.md` |

## 8. Failure containment

- **Sandbox.** Run untrusted work in a container or VM. OpenCode shell has host
  authority by default.
- **Budgets.** Set step, time, token, and cost limits per run.
- **Snapshots.** Use OpenCode snapshots and Git to make work reversible.
- **Kill switch.** Interrupt the session and revoke credentials.
- **Quarantine.** Disable a compromised MCP server, plugin, or skill.
- **Rollback.** Revert the change, the release, or the policy.

## 9. What is not in this architecture

- Product code, a runtime, or a hosted service.
- A generic workflow engine. OpenCode sessions and CI provide the loop.
- A vector database. Repository search and references are the starting point.
- A replacement for the Git provider, CI, or secret manager.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](principles.md) — design principles
- [threat-model.md](threat-model.md) — threats and controls
- [system-context.md](system-context.md) — actors, systems, boundaries
- [docs/README.md](../README.md) — documentation map
