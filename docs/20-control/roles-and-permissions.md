# Roles, permissions, and agent identity

Status: Draft

## 1. Purpose

A role is a named bundle of purpose, authority, and limits. The role contract
makes the bundle explicit so the runtime can enforce it and the readiness
assessment can check it.

This document defines the role catalog, the permission model, the identity
model, and the rules for secrets and escalation.

## 2. Role catalog

| Role | Kind | Mode | Purpose | Independence |
| --- | --- | --- | --- | --- |
| Human owner | Human | n/a | Policy, R3/R4 acceptance, incidents | Accountable |
| Security owner | Human | n/a | Security requirements and R4 review | Independent |
| Planner | Agent | Primary | Decompose the work item | None required |
| Implementer | Agent | Primary | Make the change | None required |
| Verifier | Agent | Subagent | Run the evidence manifest | Independent context |
| Reviewer | Agent | Subagent | Review the change | Independent context; R3+ different model or human |
| Integrator | Agent | Primary | Prepare the change request and gates | Independent context |
| Assessor | Agent | Subagent | Score readiness and report gaps | Independent context |
| Auditor | Human or agent | Read-only | Reconstruct and check decisions | Independent |

A single agent may hold more than one role only when the independence rule of
the risk tier is still satisfied.

## 3. Role details

### Human owner

- **Allowed.** Set policy, approve R3 and R4, promote or demote autonomy,
  command incidents, grant time-bound exceptions.
- **Denied.** Bypass evidence silently; a bypass must be recorded as an
  exception.
- **Escalation.** The owner is the final escalation point.

### Security owner

- **Allowed.** Define security requirements, review R4 changes, block a change
  on a security finding, command a security incident.
- **Denied.** Waive a security requirement without a recorded exception.
- **Escalation.** The human owner.

### Planner

- **Allowed.** Read, glob, grep, launch `explore` and `assessor` subagents.
- **Denied.** Edit, shell, push, merge, MCP, plugins.
- **Output.** A plan with steps, files, checks, risks, and open questions.
- **Escalation.** Ambiguous goal, conflicting criteria, unknown risk tier.

### Implementer

- **Allowed.** Edit inside the workspace; run test, lint, build, `git add`, and
  `git commit`; launch the `verifier` subagent.
- **Denied.** Push, merge, change policy or configuration, read or edit
  `.env`, edit `.git` or `node_modules`, access external directories, use MCP
  or plugins.
- **Output.** The change and local evidence.
- **Escalation.** Repeated failure, policy conflict, ambiguity, budget
  exhaustion.

### Verifier

- **Allowed.** Read, run test and lint commands, inspect `git status`, `git
  diff`, and `git log`.
- **Denied.** Edit, push, merge, launch subagents, ask questions.
- **Output.** Evidence manifest results with commands and exit status.
- **Escalation.** Flaky check, missing environment, unverifiable claim.

### Reviewer

- **Allowed.** Read, glob, grep.
- **Denied.** Edit, shell, subagents, questions.
- **Output.** Findings by severity with file and line references, and the
  evidence relied on.
- **Escalation.** The reviewer reports a blocking finding; it does not fix it.

### Integrator

- **Allowed.** Read; `git status`, `diff`, `log`, `fetch`, `switch`,
  `checkout`, `add`, `commit`; push a feature branch; create issues and pull
  requests; mark ready; read checks; launch the `assessor` subagent.
- **Denied.** Edit, merge, push to `main`, force push, delete protected
  branches.
- **Output.** A draft pull request with evidence and an acceptance packet.
- **Escalation.** Missing approval, failing gate, ambiguous risk tier.

### Assessor

- **Allowed.** Read, glob, grep.
- **Denied.** Edit, shell, subagents, questions.
- **Output.** A readiness report, gap register, and autonomy ceiling.
- **Escalation.** Missing evidence is reported as unproven, not guessed.

### Auditor

- **Allowed.** Read traces, evidence, and decisions; run audit queries.
- **Denied.** Edit, execute, merge.
- **Output.** An audit finding with a disposition.

## 4. Role contract fields

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | Yes | Stable role identifier |
| `name` | Yes | Human-readable name |
| `kind` | Yes | `human` or `agent` |
| `mode` | Yes | `primary`, `subagent`, or `human` |
| `purpose` | Yes | What the role exists to do |
| `allowedActions` | Yes | Actions the role may perform |
| `deniedActions` | Yes | Actions the role must not perform |
| `tools` | No | Tools or tool groups the role may use |
| `dataClasses` | Yes | Data classes the role may touch |
| `escalation` | Yes | Where the role sends a blocked decision |
| `independence` | No | `none`, `independent-context`, `independent-model`, or `human` |
| `maxSteps` | No | Maximum model steps for an agent role |

## 5. Permission model

OpenCode has two layers:

- **Permissions** are per-agent ordered rules with `allow`, `ask`, or `deny`.
  The last matching rule wins.
- **Policies** are hard-deny statements that never prompt and override
  permissions and saved approvals. A policy can tighten access; it cannot grant
  it.

The rules:

1. Default deny. Start with `* deny` and allow specific actions.
2. Put broad rules first and exceptions after them.
3. Deny `.env` reads and edits at both the permission and policy layers.
4. Deny `external_directory` unless the work item requires a named reference.
5. Deny `mcp.use`, `plugin.use`, and `skill.use` by default; allow named
   components only.
6. Treat shell as host authority. Prefer a container for untrusted work.
7. Review saved approvals; they are durable project-scoped allow rules.
8. A child session inherits the rules in effect when it is created.
9. A session can replace its permission rules; the replacement is evaluated
   after the agent rules.

## 6. Permission matrix

| Role | Edit | Shell | Subagent | Web | MCP | Skill |
| --- | --- | --- | --- | --- | --- | --- |
| Planner | Deny | Deny | explore, assessor | Allowlist | Deny | `mycelia-*` |
| Implementer | Workspace | Test, lint, build, add, commit | verifier | Allowlist | Deny | `mycelia-*` |
| Verifier | Deny | Test and lint | Deny | Deny | Deny | `mycelia-*` |
| Reviewer | Deny | Deny | Deny | Deny | Deny | `mycelia-*` |
| Integrator | Deny | Git and GitHub allowlist | assessor | Deny | Deny | `mycelia-*` |
| Assessor | Deny | Deny | Deny | Deny | Deny | `mycelia-*` |

The repository's `opencode.json` and `.opencode/agents/` are the executable
version of this matrix.

## 7. Agent identity

An agent identity is a composite, not a single token:

| Part | Example | Purpose |
| --- | --- | --- |
| Role | `reviewer` | What the actor may do |
| Session | `ses_...` | Correlation across events |
| Account | Dedicated bot account or GitHub App | Attribution and least privilege |
| Model | `provider/model#variant` | Reproducibility |
| Policy version | Hash or release | Audit |

Rules:

- The session ID is a correlation value, not an authentication credential.
- Use a dedicated bot account or app for automation. Do not reuse a human's
  personal token.
- Give the account the minimum repository and organization permissions.
- Use short-lived credentials where the provider supports them.
- Record the composite identity in every trace event.
- If one agent plays several roles, record each role transition and use a
  fresh context for the independent role.

## 8. Secrets

- Never put a secret in a prompt, a log, or a trace.
- Deny `.env` reads and edits at both layers.
- Keep secrets in a secret manager; inject them as short-lived environment
  values only for the tool that needs them.
- Keep the `secret` data class out of model providers.
- Redact secret-like values before exporting a trace.
- Rotate a secret immediately after a suspected exposure and record the
  incident.

## 9. Independence

| Risk | Minimum independence |
| --- | --- |
| R0 | CI |
| R1 | CI and review |
| R2 | Independent context |
| R3 | Independent context and a different model or a human |
| R4 | Human and security review |

The reviewer sees the diff, the work item, and the evidence, not the author's
private reasoning. The author cannot approve its own change.

## 10. Escalation

A blocked role reports:

- the precise question
- the options and their consequences
- the owner who can answer
- the blocking condition
- the work already completed

The agent cannot approve its own escalation. The human answer is recorded in
the trace and becomes part of the work item.

## 11. Anti-patterns

- Giving every agent `* allow`.
- Sharing one token across roles and humans.
- Letting the implementer review its own change.
- Leaving `.env` readable because "the agent needs it".
- A role with no escalation path.
- Enforcing a rule only in the prompt.
- Letting an agent change its own permissions, policy, or autonomy level.
- Treating a session ID as authentication.

## 12. Data contract

- Schema: [schemas/role-contract.schema.json](../../schemas/role-contract.schema.json)
- Example: [examples/role-contract.example.yaml](../../examples/role-contract.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- `policy-as-code.md` — policy model (planned)
- `evidence-manifest.md` — definition of done (planned)
- `sandbox-and-isolation.md` — isolation (planned)
- [docs/README.md](../README.md) — documentation map
