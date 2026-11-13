# OpenCode conformance checklist

Status: Draft

## 1. Purpose

The runtime contract needs a runnable checklist so an adopter can verify the
OpenCode setup instead of assuming it. This checklist is the practical form of
[opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md).

## 2. How to use

Run the checks in a disposable clone or a sandbox. Record the version, the
commit, and the result. A failed check is a gap, not a warning.

## 3. Checklist

| ID | Check | Method | Pass criterion |
| --- | --- | --- | --- |
| `OC-01` | Version | `opencode --version` | 2.2.6 or newer |
| `OC-02` | Config schema | Validate `opencode.json` | Schema validation passes |
| `OC-03` | Default agent | Read `default_agent` | The agent exists and is primary |
| `OC-04` | Custom agents | `opencode api get /api/agent` | Every role is listed |
| `OC-05` | Commands and skills | `opencode api get /api/command` and `/api/skill` | Every command and skill is listed |
| `OC-06` | Base permissions | Read the effective permissions | No broad `* allow` remains |
| `OC-07` | Red lines | Read the effective policies | Destructive actions are denied |
| `OC-08` | Denied action | Attempt a denied shell command | Blocked by policy |
| `OC-09` | Allowed action | Attempt an allowed command | Proceeds |
| `OC-10` | Secrets | Attempt to read `.env` | Denied |
| `OC-11` | External directory | Attempt to read outside the workspace | Denied |
| `OC-12` | Supply chain | Attempt an unapproved MCP, plugin, or skill | Denied |
| `OC-13` | Instructions | Read the instruction entries | `AGENTS.md` is loaded |
| `OC-14` | References | Read the reference list | All references are pinned |
| `OC-15` | Compaction | Read the compaction config | Enabled with a keep budget |
| `OC-16` | Sessions and worktrees | Create and remove a worktree | Both succeed |
| `OC-17` | Trace | Run a tool call and read the event stream | A tool event is emitted |
| `OC-18` | Stop | Interrupt a running session | The session stops |
| `OC-19` | Evidence | Produce and hash an evidence item | The hash is recorded |
| `OC-20` | Human handoff | Ask a question and answer it | The decision is recorded |
| `OC-21` | Model route | Run with a selected model | The route is in the trace |
| `OC-22` | Kill switch | Run the kill-switch drill | The run stops and credentials are revoked |
| `OC-23` | Version drift | Review the version and the changelog | The review is recorded |

## 4. Evidence

Record:

- the OpenCode version
- the commit and branch
- the command and output for each check
- the failures and the disposition
- the date and the assessor

A checklist without evidence is an opinion.

## 5. Result

A repository is OpenCode-conformant when every check passes or has a recorded,
time-bound exception. The result feeds the readiness assessment and the
conformance claim.

## 6. Anti-patterns

- Running the checklist against a different version than the one in use.
- Checking the config file without checking the effective permissions.
- Treating a `deny` policy as enough without a negative test.
- Testing in a sandbox that does not match the real deployment.
- A checklist with no evidence.
- A failed check marked as a warning.

## 7. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — runtime contract
- [roles-and-permissions.md](../20-control/roles-and-permissions.md) — roles
- [policy-as-code.md](../20-control/policy-as-code.md) — policy
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — sandbox
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- [readiness-assessment.md](readiness-assessment.md) — assessment
- [conformance-profiles.md](conformance-profiles.md) — profiles
- [docs/README.md](../README.md) — documentation map
