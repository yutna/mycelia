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

This section is informative. Where it says "the contract requires", the
binding rule is the matching `MYC-EXE-*` requirement in §7 or the owning
document named in §6.

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
path, but each waits for a connected client. In a headless run the contract
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
so a conformant runtime MUST provide each wrapper in it. The "OpenCode mechanism"
column is informative: it records what the
[reference notes](opencode-reference-notes.md) found, and the mechanisms may
change between OpenCode versions.

| Need | OpenCode mechanism (informative) | Required wrapper | Requirement |
| --- | --- | --- | --- |
| Durable run state | Sessions hold history; no workflow engine | Run state store with checkpoints outside the session | `MYC-EXE-001`, `MYC-EXE-002` |
| Exactly-once side effects | None for external effects | Idempotency keys | `MYC-EXE-003` |
| One run per work item | Sessions and worktrees; no lock | Exclusive lease and one worktree per run | `MYC-EXE-004` |
| Scheduling and liveness | No stable scheduler | Scheduler (L3-L4), heartbeat, stale-run detection | `MYC-EXE-005`, `MYC-EXE-006` |
| Budget and stop | Agent `steps`, `session.interrupt`, usage limits | Durable budget ledger and kill switch | `MYC-EXE-007`, `MYC-EXE-008` |
| Human handoff | `ask` and the `question` tool wait for a connected client | Notification adapter; no waiting approvals | `MYC-EXE-009`, `MYC-EXE-010` |
| Evidence | Event stream, session diff, session export | Evidence collector | `MYC-EXE-011` |
| Trace | Event stream is live-only | Durable trace sink | `MYC-EXE-012` |
| Policy red lines | `policies` hard-deny; invalid statements are dropped with a log warning | Placement in a scope the repository cannot loosen; load check | `MYC-EXE-013` |
| Host isolation | `OPENCODE_DISABLE_CLAUDE_CODE=1`; global config and plugins load by default | Dedicated configuration directory and user | `MYC-EXE-014` |

Controls owned by other documents (informative here). These gaps also need a
wrapper, but the owning document and the profile decide when it is required:

| Need | OpenCode gap | Wrapper | Owning document |
| --- | --- | --- | --- |
| Sandbox | None; shell has host authority | Container, microVM, or remote sandbox | [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) §5 |
| Identity | Session ID is not authentication | Dedicated bot account and credential broker | [roles-and-permissions.md](../20-control/roles-and-permissions.md) |
| Supply chain | MCP servers and plugins are code | Allowlist, pin, review | [supply-chain.md](../20-control/supply-chain.md) |
| Model change | No evaluation suite | Golden task suite | [evaluation-and-model-change.md](../60-evolution/evaluation-and-model-change.md) |
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
conformance kit contract in [#108](https://github.com/yutna/mycelia/issues/108);
a verification without a fixture name is an assessor check.

Terms used in this section:

- A **step** is a loop state transition or a prompt sent to OpenCode. A runtime
  MAY also check at each tool call, but no requirement depends on a per-tool
  hook.
- A **headless run** is a run with no person at the OpenCode client: any run
  started by the scheduler (`MYC-EXE-005`), by an operator command that does not
  stay attached to the client, or by another process.
- A **lease** is the exclusive claim a run holds on its work item.

The risk tiers a runtime runs are bounded by the autonomy matrix in
[autonomy-levels.md](../00-foundations/autonomy-levels.md) §4. "All risk tiers
the runtime runs" in the requirements below does not widen that matrix: at L2,
for example, the runtime runs R0-R2 only, and R3 and R4 stay with humans.

### `MYC-EXE-001` Durable run state and checkpoints

- **Statement:** The runtime MUST keep the run state in a store outside the
  OpenCode session, and MUST write a checkpoint, as listed in
  [autonomous-loop.md](autonomous-loop.md) §6, on every state transition before
  the next side effect.
- **Rationale:** A session is history, not a workflow engine. A crash between a
  side effect and its record loses work or repeats it.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
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
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Trace of the resumed run linking to the checkpoint it resumed
  from.
- **Verification:** Fixture `resume`: stop the run at each state and resume it.
- **Failure mode:** The work item is `blocked` when the checkpoint is missing or
  does not match the branch; ceiling lowered to L1 when resume is not
  implemented.

### `MYC-EXE-003` Idempotency keys

- **Statement:** Every external side effect (branch, pull request, comment,
  label, merge, release, notification) MUST carry an idempotency key made of
  the work item, the commit, and the action, as in
  [autonomous-loop.md](autonomous-loop.md) §8. When one action has several
  targets or rounds (for example each escalation step of `MYC-EXE-009`), the
  action part MUST name the target or round. A repeat with the same key MUST
  return the original result and MUST NOT repeat the effect. For an effect the
  target cannot deduplicate (for example email), the runtime MUST record the key
  before it sends and MUST NOT send when the record exists.
- **Rationale:** Execution is at least once. Without keys, a retry creates
  duplicate pull requests, comments, or releases.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Side-effect records with their keys (field added in #109).
- **Verification:** Fixtures `resume` and `retry-limit`: replay a step and check
  that no duplicate effect exists.
- **Failure mode:** The work item is `blocked` when a duplicate effect is
  detected; ceiling lowered to L1 when keys are absent.

### `MYC-EXE-004` One active run per work item

- **Statement:** The runtime MUST hold a lease for each work item while a run is
  active and MUST refuse to start a second run for the same work item. Each run
  MUST work in its own worktree
  ([multi-agent-concurrency.md](multi-agent-concurrency.md) §4).
- **Rationale:** Two runs on one work item race on the branch, the evidence,
  and the pull request.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Lease record in the run state (field added in #109); worktree
  record.
- **Verification:** Fixture `concurrent-run` (proposed for #108): start two runs
  for one work item; the second is refused, the refusal is traced, and the work
  item's state is unchanged.
- **Failure mode:** Ceiling lowered to L1 when the lease is not enforced.

### `MYC-EXE-005` Run start and heartbeat

- **Statement:** At L3 and L4, a scheduler outside the OpenCode session MUST
  start runs. At L2, a run MAY instead be started by an operator command; once
  started, it MUST run the loop to a terminal state or a checkpoint without a
  person driving each prompt. At every level, an active run MUST write a
  heartbeat to the run state at the configured interval.
- **Rationale:** A run that stops writing heartbeats cannot be told apart from
  a slow one without a heartbeat. L2 keeps a human supervising, so one operator
  start per run is enough; L3 and L4 need runs to start without a person. A
  loop that only runs while a person drives each prompt is L1, not L2.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Scheduler configuration (L3-L4) or the operator start record in
  the trace (L2); heartbeat timestamps in the run state (field added in #109).
- **Verification:** Audit sample of run starts against the level; audit sample
  of heartbeat gaps against the configured interval.
- **Failure mode:** Ceiling lowered to L2 when runs at L3 or L4 are not started
  by a scheduler; ceiling lowered to L1 when heartbeats are missing or a person
  drives each prompt.

### `MYC-EXE-006` Stale-run detection and restart

- **Statement:** The runtime MUST treat a run whose last heartbeat is older than
  the configured threshold as stale. For a stale run it MUST interrupt any
  session that still runs and record the event. It MUST NOT release the lease
  until the record is written and the session is confirmed stopped (an idle or
  finished execution event, or its server process gone). It then either resumes
  from the last checkpoint (`MYC-EXE-002`) or ends the work item `blocked`.
- **Rationale:** A crashed run that keeps its lease blocks the work item. A run
  that loses its lease while its session still runs creates two active runs.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Stale-run trace event with the decision taken.
- **Verification:** Fixture `stale-run` (proposed for #108): kill the runner
  mid-run; check detection, record, lease release, and the decision.
- **Failure mode:** Ceiling lowered to L1 when stale runs are not detected.

### `MYC-EXE-007` Budget across restarts

- **Statement:** The runtime MUST record budget consumption durably and count it
  across restarts, resumes, and retries. A restart MUST NOT reset a budget.
  Where a provider allowance is not counted by the workspace budget, the runtime
  MUST read that allowance before each step; when it cannot read it, the run
  MUST stop as budget exhausted.
- **Rationale:** A budget kept in process memory resets on every crash, so a
  crash loop spends without limit. The reference notes record that workspace
  budgets do not count some plan allowances.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Budget ledger in the run state (the schema has `budget`; the
  ledger fields are added in #109); trace of usage events.
- **Verification:** Fixture `budget-exhausted` (proposed for #108): exhaust a
  budget across a restart; the run ends `aborted` with exit code `4`
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
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Kill-switch drill record and trace
  ([budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) §8,
  §10).
- **Verification:** Fixture `kill-switch`: engage mid-run, restart the runtime,
  and check that no run starts.
- **Failure mode:** Active runs are `aborted`; ceiling lowered to L1 when the
  drill fails.

### `MYC-EXE-009` Notification and escalation adapter

- **Statement:** When a work item becomes `blocked`, the runtime MUST send a
  notification to the owner through a configured adapter (for example a GitHub
  issue or comment, email, or webhook), record the delivery, and wait for an
  acknowledgement. When the acknowledgement does not arrive before the
  configured expiry, the runtime MUST notify the next target in the configured
  escalation chain. The targets in
  [failure-and-ambiguity.md](failure-and-ambiguity.md) §6 are the default
  first targets.
- **Rationale:** A `blocked` state that nobody sees stops the loop silently.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Notification record with delivery, acknowledgement, expiry, and
  escalation step (field added in #109).
- **Verification:** Fixture `notification`: block a run, withhold the
  acknowledgement, and check the escalation.
- **Failure mode:** Ceiling lowered to L1 when no adapter is configured. How the
  owner's answer is recorded and how the run resumes is defined in
  [#104](https://github.com/yutna/mycelia/issues/104).

### `MYC-EXE-010` No waiting approvals in headless runs

- **Statement:** In a headless run, a permission evaluation MUST NOT wait for
  a person: every evaluation that resolves to `ask`, including defaults and the
  built-in base rules, MUST be answered by a supervisor with `deny` or an
  escalation within a configured timeout. The `question` tool MUST be denied in
  headless runs.
- **Rationale:** `ask` and `question` wait for a connected client. In a
  headless run they stall until a timeout or forever.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Effective permission set for each headless role; supervisor
  decisions in the trace.
- **Verification:** Fixture `headless-ask` (proposed for #108): trigger an `ask`
  path in a headless run; check that it is denied or escalated within the
  timeout.
- **Failure mode:** The work item is `blocked` with the pending request as the
  question; ceiling lowered to L1 when no supervisor exists and `ask` paths
  remain.

### `MYC-EXE-011` Evidence collector

- **Statement:** The runtime MUST collect required evidence from runtime outputs
  (tool results, command exit codes, diffs, reports), not from the agent's own
  summary. It MUST hash each item and link it to the commit it was produced
  for.
- **Rationale:** Self-reported evidence is not evidence
  ([SPEC.md](../../SPEC.md) §9, no silent success).
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Evidence records with hash and commit
  ([evidence-manifest.md](../20-control/evidence-manifest.md)).
- **Verification:** Fixture `stale-evidence`: change the commit after
  collection; the gate must fail.
- **Failure mode:** The work item is `blocked` for missing or stale evidence,
  never `accepted`; ceiling lowered to L1 when evidence is self-reported.

### `MYC-EXE-012` Durable trace sink

- **Statement:** The runtime MUST subscribe to the OpenCode event stream before
  it sends the first prompt of a run, and MUST write every received event to a
  durable sink. It MUST detect gaps, at least on every disconnect and also by
  sequence number where the runtime exposes one, and MUST try to reconcile each
  gap from the session export or the server API. A gap that cannot be
  reconciled marks the trace unproven.
- **Rationale:** The event stream is live-only. Events sent before the
  subscription or during a disconnect are lost unless the runtime recovers them.
  Replay support on the target version is not yet verified.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Durable trace ([trace-and-audit.md](../50-observability/trace-and-audit.md));
  gap records (field added in #109).
- **Verification:** Fixture `trace-gap` (proposed for #108): drop the event
  connection mid-run; check that the gap is recorded and reconciled or marked
  unproven.
- **Failure mode:** A work item with an unproven trace cannot reach `accepted`
  and is `blocked`; ceiling lowered to L1 when no durable sink exists. This
  tightens [trace-and-audit.md](../50-observability/trace-and-audit.md) §11 for
  runs on a conformant runtime.

### `MYC-EXE-013` Policy placement and load check

- **Statement:** Red-line policies MUST live in a configuration scope that the
  repository cannot loosen (managed scope, system scope, or the global scope of
  the runtime's dedicated user from `MYC-EXE-014`), in files the agent cannot
  write (for example a read-only mount or files owned by another user). At
  start, the runtime MUST check that every red-line policy was loaded and denies
  its action. How the check is built is defined in
  [#105](https://github.com/yutna/mycelia/issues/105).
- **Rationale:** A policy the agent can edit does not bind it. OpenCode drops an
  invalid policy statement with only a log warning, so a typo removes a red line
  silently.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Load-check result for each run; policy source paths and their
  write permissions.
- **Verification:** Fixture `policy-load` (proposed for #108): break one policy
  statement; the runtime must refuse to start.
- **Failure mode:** The run is `aborted` by policy before the first prompt;
  ceiling lowered to L1 when the check does not exist.

### `MYC-EXE-014` Host isolation

- **Statement:** The runtime MUST run OpenCode with a dedicated configuration
  directory and user, and with a system configuration scope that the factory
  controls (for example inside the sandbox), so that the host's configuration,
  plugins, instructions, and skills do not load. It MUST disable loading of
  other agent tools' instruction and skill files (on OpenCode,
  `OPENCODE_DISABLE_CLAUDE_CODE=1`).
- **Rationale:** Configuration on a shared host changes the agent's
  instructions, tools, and permissions without any repository change.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Runtime environment record; loaded agents, skills, and plugins
  listed in the trace.
- **Verification:** Fixture `host-isolation` (proposed for #108): place marker
  skills in the host's global OpenCode configuration and in `~/.claude`; neither
  may appear in the run.
- **Failure mode:** The run is `aborted` by policy; ceiling lowered to L1.

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
- A blocked notification, acknowledgement, and answer round-trip completes
  (`MYC-EXE-009`).
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
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — durable trace
- [evaluation-and-model-change.md](../60-evolution/evaluation-and-model-change.md) — evaluations
- [docs/README.md](../README.md) — documentation map
