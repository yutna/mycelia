# OpenCode runtime contract

Status: Draft

Runtime: OpenCode V2, tested with version 2.2.6 or newer

## 1. Purpose

Mycelia is OpenCode-specific. This document defines the capabilities the
factory requires from the runtime, how each maps to an OpenCode primitive, what
is native, what needs a plugin or a process wrapper, and what remains a gap.

## 2. Scope

- Target: OpenCode V2 only.
- Other harnesses are out of scope. They need their own adapter and
  conformance profile.
- The contract covers the CLI, the server API, configuration, agents, commands,
  skills, plugins, MCP, worktrees, sessions, and events.
- It does not cover the internal implementation of OpenCode or of a model
  provider.

## 3. Capability matrix

| Capability | Requirement | OpenCode mechanism | Status |
| --- | --- | --- | --- |
| Context assembly | The agent sees the work item, instructions, references, and skills | `AGENTS.md`, `instructions`, `references`, `skills`, compaction | Native |
| Tool gateway | Tools are discoverable, permissioned, and traceable | Built-in tools, MCP, plugins, permissions | Native |
| Policy enforcement | A rule cannot be overridden by a prompt | `permissions`, `policies` | Native |
| Durable state | A run can checkpoint and resume | Sessions, server API, run state file | Native plus process |
| Sandbox | The runtime is contained | Container or VM around OpenCode | Process only |
| Budget and stop | A run can be bounded and stopped | Agent `steps`, usage limits, `session.interrupt`, runner timeout | Native plus process |
| Evidence emission | Tool calls and results can become evidence | Event stream, session export, VCS diff, shell output, plugin hooks | Native plus plugin |
| Trace and audit | Events are durable and auditable | Event stream, session log, API | Native plus export |
| Human handoff | A human can approve or answer | Permission prompts, `question` tool, forms, API | Native |
| Model routing | The model can be chosen and pinned | Providers, agents, model variants, policies | Native |

## 4. Capability details

### 4.1 Context assembly

OpenCode assembles the system prompt, `AGENTS.md`, configured instructions,
references, skills, and session history. The contract requires the work item
and evidence manifest to be present before implementation and verification.
Compaction is allowed but must be followed by a re-read of the work item and
manifest.

### 4.2 Tool gateway

OpenCode exposes built-in tools, MCP tools, and plugin tools. Every tool call
passes through the permission check. The contract requires a stable tool name,
a schema, a permission action, and a trace event.

### 4.3 Policy enforcement

`permissions` decide allow, deny, or ask. `policies` hard-deny and override
permissions and saved approvals. The contract requires every red line to be a
policy, not a prompt. The precedence is managed, system, Console, global,
project.

### 4.4 Durable state

Sessions provide history and a stable session ID. The server API supports
create, prompt, wait, interrupt, and context. The contract requires a run state
file with checkpoints outside the session, because a session is not a workflow
engine.

### 4.5 Sandbox

OpenCode shell runs with the host user's authority. The contract requires the
OpenCode process to run inside a container, a microVM, or an ephemeral remote
sandbox. Permissions are not a sandbox.

### 4.6 Budget and stop

Agent `steps` bounds model steps. Provider and workspace usage limits bound
tokens and cost. The runner bounds wall-clock time. `session.interrupt` stops a
session. The contract requires a kill switch reachable without a deployment.

### 4.7 Evidence emission

The event stream includes tool calls, usage, permissions, and session
lifecycle. Session export and VCS diff provide artifacts. A plugin can collect
and hash evidence. The contract requires every required evidence item to be
traceable to a commit.

### 4.8 Trace and audit

The event stream is rich but ephemeral. The contract requires a durable sink:
JSONL, an OTel exporter, or an external store. The trace includes the role,
session, model, policy version, tool call, input and output hash, cost, and
parent event.

### 4.9 Human handoff

The `question` tool, permission prompts, and forms provide a human decision
path. The contract requires a blocked state with a precise question, options,
owner, and evidence.

### 4.10 Model routing

Providers, agents, and model variants select a model. Policies restrict
providers. The contract requires pinned versions, an evaluation before a
change, and a fallback route.

## 5. Surface map

| Surface | Use |
| --- | --- |
| `opencode run` | Non-interactive execution, CI, evidence capture |
| `opencode serve` | Shared runtime and HTTP API |
| `opencode api` | Scripted access to the server |
| `opencode.json` | Runtime configuration, permissions, policies |
| `.opencode/agents/` | Role definitions |
| `.opencode/commands/` | Reusable prompt templates |
| `.opencode/skills/` | Procedural knowledge |
| `.opencode/plugins/` | Hooks, tools, evidence, trace |
| MCP servers | External tools and resources |
| Worktrees | Isolated concurrent work |
| Sessions and events | State, trace, and correlation |

## 6. Known gaps

| Gap | Impact | Required wrapper |
| --- | --- | --- |
| No native sandbox | Shell has host authority | Container, microVM, or remote sandbox |
| Permissive base permission | `* allow` by default | Hardened permissions and policies |
| `--auto` is broad | Auto-approves non-denied actions | Do not use with broad rules; deny first |
| Session ID is not auth | Cannot authenticate an actor | Dedicated bot account and credential broker |
| Events are not durable | Audit gaps | JSONL or OTel export |
| MCP and plugins are code | Supply-chain risk | Allowlist, pin, review, sandbox |
| No native eval suite | Model changes are blind | Golden task suite |
| No native readiness assessment | Cannot answer "what is missing" | Mycelia assessor |
| No native workflow engine | Resume needs a state file | Run state and checkpoint |
| Provider data policy | Data leaves the machine | Classification and provider review |

## 7. Conformance tests

- `opencode --version` reports 2.2.6 or newer.
- `opencode.json` validates against the published schema.
- The custom agents, commands, and skills are discovered.
- A policy-denied action is blocked with a policy error.
- An allowed action proceeds.
- A tool call emits a trace event.
- `session.interrupt` stops a running session.
- A worktree is created and removed.
- Evidence is hashed and linked to a commit.
- A human question or approval round-trip completes.
- A model route is recorded in the trace.
- The kill-switch drill succeeds.

## 8. Out of scope

- Harnesses other than OpenCode.
- OpenCode internals and release engineering.
- Model provider internals.
- Client UI features that do not affect the contract.
- A hosted Mycelia service.

## 9. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [reference-architecture.md](../00-foundations/reference-architecture.md) — layers and components
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — sandbox
- [autonomous-loop.md](autonomous-loop.md) — loop and checkpoints
- `trace-and-audit.md` — durable trace (planned)
- `evaluation-and-model-change.md` — evaluations (planned)
- [docs/README.md](../README.md) — documentation map
