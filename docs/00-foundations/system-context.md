# System context

Status: Draft

## 1. Purpose

This document defines what is inside the factory, what is an external system,
who the actors are, and where the trust boundaries sit. It complements the
[reference architecture](reference-architecture.md).

## 2. Actors

| Actor | Goal | Authority |
| --- | --- | --- |
| Human owner | Keep the system safe and aligned | Sets policy, accepts R3 and R4, commands incidents |
| Maintainer | Keep the specification coherent | Merges normative changes after review |
| Contributor | Propose a change | Opens issues and draft pull requests |
| Reviewer | Independently judge a change | Blocks a change on evidence |
| Auditor | Reconstruct and check decisions | Reads traces and evidence; no write access |
| Security owner | Own security requirements | Blocks security-relevant changes |
| Platform engineer | Build the runtime and CI | Configures the sandbox, CI, and observability |
| Planner agent | Decompose the work item | Read-only |
| Implementer agent | Make the change | Write access limited to the workspace |
| Verifier agent | Run the evidence manifest | Read-only plus test commands |
| Reviewer agent | Review independently | Read-only, no shell |
| Integrator agent | Prepare the change request | Git and GitHub allowlist; no merge by default |
| Assessor agent | Score readiness | Read-only |

## 3. External systems

| System | Role | Data exchanged | Trust |
| --- | --- | --- | --- |
| Git provider | Source of truth for code, issues, pull requests | Code, metadata, comments | Trusted for integrity; content is untrusted input |
| CI runner | Executes checks and gates | Code, logs, artifacts | Trusted if pinned and isolated |
| Model provider | Produces model output | Prompts, code context, tool results | External; assume data leaves the machine |
| MCP servers | Add tools, resources, prompts | Tool inputs and outputs, instructions | Untrusted until reviewed and pinned |
| Package registries | Supply dependencies and plugins | Packages, metadata | Untrusted until verified |
| Secret manager | Issues short-lived credentials | Tokens, keys | Trusted; never expose to prompts |
| Observability backend | Stores traces and metrics | Events, logs, costs | Trusted for storage; access-controlled |
| Artifact store | Stores evidence and release artifacts | Logs, reports, binaries | Trusted for integrity; content-addressed |
| Issue tracker | Holds work items and decisions | Goals, acceptance criteria | Trusted for workflow; content is untrusted input |

## 4. Trust boundaries

| Boundary | What crosses | Stance |
| --- | --- | --- |
| Human to OpenCode | Instructions, approvals, forms | Human is trusted; high-risk actions need explicit confirmation |
| OpenCode to model provider | Prompts and context | External; classify data before sending |
| OpenCode to MCP, plugins, skills | Tool calls, instructions, code | Untrusted; allowlist and pin |
| Repository to agent | Code, issues, docs | Untrusted data; never instructions |
| Web to agent | Pages and search results | Untrusted; allowlist and sandbox |
| Agent to agent | Handoffs and reports | Artifact-mediated; verify |
| CI to repository | Tokens and releases | Least privilege and short-lived credentials |
| Evidence to verifier | Claims and artifacts | Reproducible and independently checked |
| Human to evidence | Acceptance decisions | Risk-based sampling and audit |

## 5. Integration points

| Point | Protocol or format | Contract | Owner |
| --- | --- | --- | --- |
| Runtime configuration | `opencode.json` | OpenCode config schema | Platform engineer |
| Agent definitions | `.opencode/agents/*.md` | Agent frontmatter | Maintainer |
| Commands | `.opencode/commands/*.md` | Command frontmatter | Maintainer |
| Skills | `.opencode/skills/*/SKILL.md` | Skill frontmatter | Maintainer |
| Factory configuration | `mycelia.yaml` | `mycelia.schema.json` | Maintainer |
| Work item | Issue plus work item schema | `work-item.schema.json` | Maintainer |
| Evidence | Files plus manifest | `evidence-manifest.schema.json` | Verifier |
| Trace | JSONL or event stream | `trace-event.schema.json` | Platform engineer |
| Readiness report | YAML | `readiness-report.schema.json` | Assessor |
| Git and pull requests | HTTPS or SSH, GitHub API | Repository rules | Platform engineer |
| CI | GitHub Actions | Workflow files | Platform engineer |
| Model providers | Provider APIs | Provider configuration | Platform engineer |
| MCP | Model Context Protocol | Server configuration | Security owner |
| Observability | OpenTelemetry or event export | Trace schema | Platform engineer |

## 6. Data classification

| Class | Examples | Model provider | Storage |
| --- | --- | --- | --- |
| Public | Published specifications, public docs | Allowed | Public repository |
| Internal | Private code, issues, CI logs | Allowed with policy | Private repository and trace store |
| Confidential | Customer data, non-public designs | Approval required | Encrypted, access-controlled |
| Secret | Tokens, keys, `.env` | Never | Secret manager only |

A work item that needs confidential data MUST name the data class and the
approval before the run starts. A secret MUST NOT enter a prompt, a log, or a
trace.

## 7. Deployment contexts

| Context | Runtime | Isolation | Interactive approvals |
| --- | --- | --- | --- |
| Local | OpenCode TUI or CLI | Developer machine or container | Yes |
| CI | `opencode run --format json` | Ephemeral runner or container | No; explicit deny and allow |
| Server | `opencode serve` | Dedicated host or container | Yes, through a client |
| Desktop or web | Client connected to a server | Same as the server | Yes |

## 8. Assumptions and constraints

- OpenCode is pinned and patched.
- The model provider is an external service with its own data policy.
- MCP servers, plugins, and skills are untrusted until reviewed.
- The host is not already compromised.
- The repository is the source of truth; local state is not authoritative.
- Human attention is finite; the system must minimize routine intervention.

## 9. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [reference-architecture.md](reference-architecture.md) — layers and components
- [threat-model.md](threat-model.md) — threats and controls
- [GLOSSARY.md](../../GLOSSARY.md) — terminology
- [docs/README.md](../README.md) — documentation map
