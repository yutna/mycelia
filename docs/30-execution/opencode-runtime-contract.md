# OpenCode runtime contract

Status: Draft

Runtime: OpenCode V2, version 2.4.0 or newer; last tested with 2.2.6, 2.4.x test
pending ([ADR-0002](../00-foundations/decisions/0002-runtime-stack.md))

## 1. Purpose

Mycelia is OpenCode-specific. This document defines the capabilities the
factory requires from the runtime, how each maps to an OpenCode primitive, what
is native, what needs a plugin or a process wrapper, and what remains a gap.

Sections 6 and 7 are normative. A conformant runtime (`MYC-CORE-013`) provides
every required wrapper and meets every `MYC-EXE-*` requirement. The other
sections are informative unless they say otherwise.

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
| Policy enforcement | A rule cannot be overridden by a prompt | `permissions`, `policies` | Native plus process |
| Durable state | A run can checkpoint and resume | Sessions, server API, run state file | Native plus process |
| Sandbox | The runtime is contained | Container or VM around OpenCode | Process only |
| Budget and stop | A run can be bounded and stopped | Agent `steps`, usage limits, `session.interrupt`, runner timeout | Native plus process |
| Evidence emission | Tool calls and results can become evidence | Event stream, session export, VCS diff, shell output, plugin hooks | Native plus plugin |
| Trace and audit | Events are durable and auditable | Event stream, session log, API | Native plus export |
| Human handoff | A human can approve or answer | Permission prompts, `question` tool, forms, API | Native plus process |
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
create, prompt, interrupt, and context. It has no wait call; a client learns
that a session finished from the `session.idle` and `session.execution.*`
events. The contract requires a run state store with checkpoints outside the
session, because a session is not a workflow engine (`MYC-EXE-001`).

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
path, but each waits for a connected client. In an unattended run the contract
requires a blocked state with a precise question, options, owner, and evidence,
delivered through a notification adapter (`MYC-EXE-009`, `MYC-EXE-010`).

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

## 6. Required wrappers

This table is normative. OpenCode does not provide these capabilities natively,
so a conformant runtime MUST provide each wrapper. The "OpenCode mechanism"
column is informative: it records what the
[reference notes](opencode-reference-notes.md) found, and the mechanisms may
change between OpenCode versions.

| Need | OpenCode mechanism (informative) | Required wrapper | Requirement |
| --- | --- | --- | --- |
| Durable run state | Sessions hold history; no workflow engine | Run state store with checkpoints outside the session | `MYC-EXE-001`, `MYC-EXE-002` |
| Exactly-once side effects | None for external effects | Idempotency keys | `MYC-EXE-003` |
| One run per work item | Sessions and worktrees; no lock | Exclusive lease and one worktree per run | `MYC-EXE-004` |
| Scheduling and liveness | No stable scheduler | Scheduler, heartbeat, stale-run detection | `MYC-EXE-005`, `MYC-EXE-006` |
| Budget and stop | Agent `steps`, `session.interrupt`, usage limits | Durable budget ledger and kill switch | `MYC-EXE-007`, `MYC-EXE-008` |
| Human handoff | `ask` and the `question` tool wait for a connected client | Notification adapter; no waiting approvals | `MYC-EXE-009`, `MYC-EXE-010` |
| Evidence | Event stream, session diff, session export | Evidence collector | `MYC-EXE-011` |
| Trace | Event stream is live-only | Durable trace sink | `MYC-EXE-012` |
| Policy red lines | `policies` hard-deny; invalid statements are dropped with a log warning | Placement in a scope the repository cannot loosen; load check | `MYC-EXE-013` |
| Host isolation | `OPENCODE_DISABLE_CLAUDE_CODE=1`; global config and plugins load by default | Dedicated configuration directory and user | `MYC-EXE-014` |
| Sandbox | None; shell has host authority | Container, microVM, or remote sandbox | [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) §5 |
| Identity | Session ID is not authentication | Dedicated bot account and credential broker | [roles-and-permissions.md](../20-control/roles-and-permissions.md) |
| Supply chain | MCP servers and plugins are code | Allowlist, pin, review | [supply-chain.md](../20-control/supply-chain.md) |
| Model change | No evaluation suite | Golden task suite | `evaluation-and-model-change.md` |
| Readiness | No assessment | Mycelia assessor | [readiness-assessment.md](../70-adoption/readiness-assessment.md) |
| Provider data | Data leaves the machine | Classification and provider review | [policy-as-code.md](../20-control/policy-as-code.md) |

## 7. Runtime requirements

These requirements bind every conformant runtime, the reference runtime
included. They apply from L2, because `MYC-CORE-013` requires a conformant
runtime from L2. Each requirement uses the fields in
[SPEC.md](../../SPEC.md) §5.

Values such as the heartbeat interval, the stale-run threshold, and the
acknowledgement expiry are not fixed by this document. The repository MUST
configure them; the `mycelia.yaml` runtime section is added in
[#109](https://github.com/yutna/mycelia/issues/109). Fields that a requirement
records and that the schemas do not have yet are marked
"(field added in #109)". The conformance fixtures named under "Verification" are defined by the
conformance kit contract in [#108](https://github.com/yutna/mycelia/issues/108).

### `MYC-EXE-001` Durable run state and checkpoints

- **Statement:** The runtime MUST keep the run state in a store outside the
  OpenCode session, and MUST write a checkpoint, as listed in
  [autonomous-loop.md](autonomous-loop.md) §6, on every state transition before
  the next side effect.
- **Rationale:** A session is history, not a workflow engine. A crash between a
  side effect and its record loses work or repeats it.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Run state record with its checkpoints; matching trace events.
- **Verification:** Fixture `resume`; audit sample of run state against trace.
- **Failure mode:** Ceiling lowered to L1 by the assessor.

### `MYC-EXE-002` Resume from checkpoint

- **Statement:** After a restart or a crash, the runtime MUST resume a run from
  its last checkpoint by the procedure in [autonomous-loop.md](autonomous-loop.md)
  §7, and MUST NOT resume from session history alone. If the commit or the
  policy version changed, the runtime MUST apply the rules in that section
  before it continues.
- **Rationale:** Session history does not show which gates passed, which
  evidence is still fresh, or which side effects happened.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Trace of the resumed run linking to the checkpoint it resumed
  from.
- **Verification:** Fixture `resume`: stop the run at each state and resume it.
- **Failure mode:** The run is `blocked` when the checkpoint is missing or does
  not match the branch; ceiling lowered to L1 when resume is not implemented.

### `MYC-EXE-003` Idempotency keys

- **Statement:** Every external side effect (branch, pull request, comment,
  label, merge, release, notification) MUST carry an idempotency key made of
  the work item, the commit, and the action, as in
  [autonomous-loop.md](autonomous-loop.md) §8. A repeat with the same key MUST
  return the original result and MUST NOT repeat the effect.
- **Rationale:** Execution is at least once. Without keys, a retry creates
  duplicate pull requests, comments, or releases.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Side-effect records with their keys (field added in #109).
- **Verification:** Fixture `resume` and `retry-limit`: replay a step and check
  that no duplicate effect exists.
- **Failure mode:** The run is `aborted` on a detected duplicate; ceiling
  lowered to L1 when keys are absent.

### `MYC-EXE-004` One active run per work item

- **Statement:** The runtime MUST hold an exclusive lease for each work item
  while a run is active and MUST refuse to start a second run for the same work
  item. Each run MUST work in its own worktree or branch.
- **Rationale:** Two runs on one work item race on the branch, the evidence,
  and the pull request.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Lease record in the run state (field added in #109); worktree
  record ([multi-agent-concurrency.md](multi-agent-concurrency.md) §4).
- **Verification:** Start two runs for one work item; the second is refused and
  the refusal is traced.
- **Failure mode:** The second run is `blocked` with the lease holder named.

### `MYC-EXE-005` Scheduler and heartbeat

- **Statement:** A scheduler outside the OpenCode session MUST start runs. An
  active run MUST write a heartbeat to the run state at the configured
  interval.
- **Rationale:** A loop that only runs while a person watches is not L2. A run
  that stops writing heartbeats cannot be told apart from a slow one without a
  heartbeat.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Scheduler configuration; heartbeat timestamps in the run state
  (field added in #109).
- **Verification:** Audit sample of heartbeat gaps against the configured
  interval.
- **Failure mode:** Ceiling lowered to L1.

### `MYC-EXE-006` Stale-run detection and restart

- **Statement:** The runtime MUST treat a run whose last heartbeat is older than
  the configured threshold as stale. For a stale run it MUST interrupt any
  session that still runs, record the event, and then either resume from the
  last checkpoint (`MYC-EXE-002`) or end the run `aborted`. It MUST NOT release
  the lease before the record is written.
- **Rationale:** A crashed run that keeps its lease blocks the work item. A run
  that loses its lease while still running creates two active runs.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Stale-run trace event with the decision taken.
- **Verification:** Kill the runner mid-run; check detection, record, and the
  decision.
- **Failure mode:** The run is `aborted` when it cannot be resumed.

### `MYC-EXE-007` Budget across restarts

- **Statement:** The runtime MUST record budget consumption durably and count it
  across restarts, resumes, and retries. A restart MUST NOT reset a budget.
  Where a provider allowance is not counted by the workspace budget, the runtime
  MUST read that allowance itself before each step.
- **Rationale:** A budget kept in process memory resets on every crash, so a
  crash loop spends without limit. The notes record that Console budgets do not
  count OpenCode Go in-plan usage.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Budget ledger in the run state (field added in #109); trace of
  usage events.
- **Verification:** Fixture `aborted`: exhaust a budget across a restart; the
  run ends `aborted` with exit code `4`
  ([cli-contract.md](../80-interface/cli-contract.md)).
- **Failure mode:** The run is `aborted` on exhaustion; ceiling lowered to L1
  when the ledger does not survive a restart.

### `MYC-EXE-008` Kill switch

- **Statement:** The runtime MUST provide a kill switch that is reachable
  without a deployment, that no agent can disable, and that the runtime checks
  before each step and each side effect. Engaging it MUST interrupt active
  sessions. It MUST stay engaged across restarts until a human releases it.
- **Rationale:** A kill switch that a restart clears, or that is checked only at
  start, does not stop a runaway loop.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Kill-switch drill record and trace
  ([budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) §8,
  §10).
- **Verification:** Fixture `kill-switch`: engage mid-run, restart the runtime,
  and check that no run starts.
- **Failure mode:** Active runs are `aborted`; ceiling lowered to L1 when the
  drill fails.

### `MYC-EXE-009` Notification and escalation adapter

- **Statement:** When a run ends `blocked`, the runtime MUST send a notification
  to the owner through a configured adapter (for example a GitHub issue or
  comment, email, or webhook), record the delivery, and wait for an
  acknowledgement. When the acknowledgement does not arrive before the
  configured expiry, the runtime MUST escalate to the next target in
  [failure-and-ambiguity.md](failure-and-ambiguity.md) §6.
- **Rationale:** A `blocked` state that nobody sees stops the loop silently.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Notification record with delivery, acknowledgement, and expiry
  (field added in #109).
- **Verification:** Fixture `notification`: block a run, withhold the
  acknowledgement, and check the escalation.
- **Failure mode:** The work item stays `blocked`; ceiling lowered to L1 when no
  adapter is configured. How the owner's answer is recorded and how the run
  resumes is defined in [#104](https://github.com/yutna/mycelia/issues/104).

### `MYC-EXE-010` No waiting approvals in unattended runs

- **Statement:** In a run without a person at the client, no permission rule
  may resolve to `ask` unless a supervisor answers each request with `deny` or an
  escalation within a configured timeout. The `question` tool MUST be denied in
  such runs.
- **Rationale:** `ask` and `question` wait for a connected client. In a
  headless run they stall until a timeout or forever.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Effective permission set for each unattended role; supervisor
  decisions in the trace.
- **Verification:** Trigger an `ask` path in an unattended run; check that it is
  denied or escalated within the timeout.
- **Failure mode:** The run is `blocked` with the pending request as the
  question.

### `MYC-EXE-011` Evidence collector

- **Statement:** The runtime MUST collect required evidence from runtime outputs
  (tool results, command exit codes, diffs, reports), not from the agent's own
  summary. It MUST hash each item and link it to the commit it was produced
  for.
- **Rationale:** Self-reported evidence is not evidence
  ([SPEC.md](../../SPEC.md) §9, no silent success).
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Evidence records with hash and commit
  ([evidence-manifest.md](../20-control/evidence-manifest.md)).
- **Verification:** Fixture `stale-evidence`: change the commit after
  collection; the gate must fail.
- **Failure mode:** The work item is `rejected` or `blocked` for missing or
  stale evidence, never `accepted`.

### `MYC-EXE-012` Durable trace sink

- **Statement:** The runtime MUST subscribe to the OpenCode event stream before
  it sends the first prompt of a run, and MUST write every event to a durable
  sink. It MUST detect and record a gap in the received events and reconcile the
  gap from the session export before the run can reach `accepted`.
- **Rationale:** The event stream is live-only. Events sent before the
  subscription or during a disconnect are lost unless the runtime recovers them.
  Replay support on the target version is not yet verified.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Durable trace ([trace-and-audit.md](../50-observability/trace-and-audit.md));
  gap records.
- **Verification:** Drop the event connection mid-run; check that the gap is
  recorded and reconciled.
- **Failure mode:** The work item is `blocked` until the gap is reconciled.

### `MYC-EXE-013` Policy placement and load check

- **Statement:** Red-line policies MUST live in a configuration scope that the
  repository cannot loosen (global or system scope). At start, the runtime MUST
  check that every red-line policy was loaded and denies its action. How the
  check is built (canaries, exact counts) is defined in
  [#105](https://github.com/yutna/mycelia/issues/105).
- **Rationale:** A policy in the repository can be edited by the agent it
  binds. OpenCode drops an invalid policy statement with only a log warning, so
  a typo removes a red line silently.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Load-check result for each run; policy source paths.
- **Verification:** Break one policy statement; the runtime must refuse to
  start.
- **Failure mode:** The run is `aborted` before the first prompt.

### `MYC-EXE-014` Host isolation

- **Statement:** The runtime MUST run OpenCode with a dedicated configuration
  directory and user, so that the host's global configuration, plugins,
  instructions, and skills do not load. It MUST disable loading of other agent
  tools' instruction and skill files (on OpenCode, `OPENCODE_DISABLE_CLAUDE_CODE=1`).
- **Rationale:** Global configuration on a shared host changes the agent's
  instructions, tools, and permissions without any repository change.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Runtime environment record; loaded agents, skills, and plugins
  listed in the trace.
- **Verification:** Place a marker skill in the host's global configuration;
  it must not appear in the run.
- **Failure mode:** The run is `aborted`; ceiling lowered to L1.

## 8. Conformance tests

- `opencode --version` reports 2.4.0 or newer.
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

## 9. Out of scope

- Harnesses other than OpenCode.
- OpenCode internals and release engineering.
- Model provider internals.
- Client UI features that do not affect the contract.
- A hosted Mycelia service.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [reference-architecture.md](../00-foundations/reference-architecture.md) — layers and components
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — sandbox
- [autonomous-loop.md](autonomous-loop.md) — loop and checkpoints
- [opencode-reference-notes.md](opencode-reference-notes.md) — OpenCode V2 docs findings (non-normative)
- `trace-and-audit.md` — durable trace (planned)
- `evaluation-and-model-change.md` — evaluations (planned)
- [docs/README.md](../README.md) — documentation map
