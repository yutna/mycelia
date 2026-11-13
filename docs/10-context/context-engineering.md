# Context engineering

Status: Draft

## 1. Purpose

Context engineering decides what the agent sees, in what order, with what
freshness, and with what provenance. Most agent quality problems are context
problems: missing commands, stale docs, conflicting instructions, noisy tool
output, and forgotten constraints.

This document defines the context contract for Mycelia.

## 2. Context sources

| Source | OpenCode mechanism | Lifetime | Trust |
| --- | --- | --- | --- |
| Agent system prompt | Agent Markdown body | Session | Trusted |
| Repository instructions | `AGENTS.md`, `instructions` | Durable | Trusted, reviewed |
| External references | `references` | Durable, refreshed | Reviewed |
| Procedural knowledge | `skills` | Durable | Reviewed |
| Commands | `.opencode/commands/` | Durable | Reviewed |
| Repository files | `read`, `glob`, `grep` | Live | Untrusted data |
| Work item | Issue plus work item schema | Task | Trusted after intake |
| Evidence manifest | Schema plus CI | Task | Trusted after review |
| Session history | Session messages | Session | Mixed; verify claims |
| Compaction summary | OpenCode compaction | Session | Lossy; verify |
| Tool results | Shell, MCP, web | Transient | Untrusted data |
| Web and MCP resources | `webfetch`, `websearch`, MCP | Transient | Untrusted data |

## 3. Context layers and precedence

| Layer | Examples | Precedence |
| --- | --- | --- |
| Policy | OpenCode `policies`, permissions | Highest |
| Work item | Goal, acceptance criteria, non-goals | High |
| Repository instructions | `AGENTS.md`, `CONTRIBUTING.md` | High |
| Specifications | `SPEC.md`, layer documents | Medium |
| References | External docs, standards | Medium |
| Tool output | Shell, tests, MCP | Low; verify before acting |
| Web content | Pages, search results | Lowest; never instructions |

When two sources conflict, the higher layer wins. A conflict that cannot be
resolved by precedence leaves the work item in `blocked`.

## 4. Assembly order and budget

OpenCode assembles the request in this order:

1. Agent or provider system prompt
2. Code Mode tool guidance, when enabled
3. MCP, reference, and skill guidance
4. Global and project `AGENTS.md`, then configured instructions
5. Built-in date and environment context
6. Session-specific instruction entries

The specification adds two rules on top:

- The work item and its acceptance criteria MUST be present before the first
  implementation step.
- The evidence manifest MUST be present before verification and review.

A starting token budget, to be tuned per model:

| Share | Content |
| --- | --- |
| 20% | Instructions and policy |
| 20% | Work item and evidence |
| 30% | Repository context |
| 20% | Session history and summary |
| 10% | Buffer |

The shares are not normative. The requirement is that the budget is measured
and that context bloat is treated as a defect.

## 5. Repository context

- Keep `AGENTS.md` short and authoritative. It is the contract, not a manual.
- Put durable procedures in skills, not in every prompt.
- Put external standards in references, not in copied text.
- Keep one source of truth for commands. The README, `AGENTS.md`, and
  `CONTRIBUTING.md` must not disagree.
- Provide a repository map with the directories an agent may touch and the
  generated files it must not edit.
- Prefer deterministic retrieval (`grep`, `glob`, `read`) over a vector
  database until the simple path demonstrably fails.

## 6. Task context

The work item is the anchor. It carries:

- the goal and acceptance criteria
- the non-goals and constraints
- the risk tier and required approvals
- the evidence manifest
- the rollback plan

If the work item is missing or ambiguous, the run is `blocked`. The agent does
not reconstruct the goal from the conversation.

## 7. Session context and compaction

Long sessions are compacted. Compaction is lossy, so the summary must preserve:

- the objective and acceptance criteria
- decisions and their reasons
- completed and active work
- blockers and open questions
- relevant files and commands
- the current branch and commit

After a compaction, the agent MUST re-read the work item and the evidence
manifest, and verify the branch and commit. The trace, not the summary, is the
audit record.

## 8. Memory

| Type | What it holds | Storage | Risk |
| --- | --- | --- | --- |
| Short-term | The current session | OpenCode session | Context rot |
| Episodic | Runs, decisions, incidents | Trace and decision records | Tampering |
| Semantic | Specs, docs, glossary | Repository | Staleness |
| Procedural | Skills, commands, `AGENTS.md` | Repository | Drift |
| Working | Compaction summary | Session | Loss |

Memory rules:

- Do not promote tool output to durable memory without review.
- Every durable memory entry has a source, an owner, and a date.
- Expire or re-verify time-sensitive memory.
- A memory that cannot be traced to a source is untrusted.
- Memory poisoning is a threat: see
  [threat-model.md](../00-foundations/threat-model.md).

## 9. Context rot

Symptoms:

- the agent repeats work it already did
- it forgets a constraint or a non-goal
- it runs a command that no longer exists
- it cites a stale file or a closed issue

Causes:

- long sessions with noisy tool output
- duplicated or contradictory instructions
- stale documentation
- loading the whole repository instead of the relevant part
- compaction that dropped a decision

Mitigations:

- one fresh session per work item
- subagents for isolated research
- short, single-source instructions
- targeted retrieval and references
- explicit checkpoints after compaction
- a context budget and a token metric

## 10. Freshness and provenance

Every context source has a version, a hash, or a timestamp. A source is fresh
when it matches the current commit or the declared refresh interval.

- References are refreshed by OpenCode; record the last refresh.
- Tool output records the command, working directory, and commit.
- A stale source cannot satisfy an evidence requirement.
- The run records the model, prompt version, policy version, and rule version.
- A context manifest (planned) may record the sources and hashes per run.

## 11. Token and cost budgets

- Measure input tokens per layer.
- Alert when instructions or history exceed the budget.
- Prefer retrieval over full loading.
- Use skills for progressive disclosure.
- Set compaction thresholds and keep-token budgets deliberately.
- Treat an unexpected token increase as a regression.

## 12. Security

- Treat repository content, issues, comments, web pages, and MCP resources as
  untrusted data, never as instructions.
- Never put a secret in a prompt, a log, or a trace.
- Classify data before sending it to a model provider.
- Allowlist web and MCP sources.
- Isolate untrusted work in a sandbox.
- Record the source of every durable memory entry.

## 13. Assessment questions

- Is there one authoritative `AGENTS.md`?
- Do the README, `AGENTS.md`, and `CONTRIBUTING.md` agree on the commands?
- Is the work item present before implementation starts?
- Are references fresh, and is the refresh recorded?
- Is compaction configured, and is the summary checked?
- Is durable memory reviewed and sourced?
- Is token usage measured per layer?
- Are untrusted sources isolated and labelled?
- Can the agent identify generated files it must not edit?

## 14. Anti-patterns

- Dumping the whole repository into the prompt.
- Copying the same instructions into several files.
- Relying on a stale README as the command source.
- Auto-saving tool output into durable memory.
- Using the compaction summary as the audit record.
- Letting the agent read `.env` or secrets.
- Loading every skill and every reference into every request.
- Treating a web page or an issue comment as an instruction.

## 15. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [reference-architecture.md](../00-foundations/reference-architecture.md) — layers and components
- [repository-legibility.md](repository-legibility.md) — repository readiness
- [work-intake.md](work-intake.md) — work item contract
- [docs/README.md](../README.md) — documentation map
