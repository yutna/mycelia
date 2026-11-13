# Policy as code

Status: Draft

## 1. Purpose

Policy is the hard boundary of the factory. A permission can ask; a policy
cannot be talked out of a decision. This document defines the policy model,
precedence, decision points, outcomes, obligations, exceptions, and the policy
decision record.

## 2. Policy versus permission

| Aspect | Permission | Policy |
| --- | --- | --- |
| Scope | A specific agent | Managed, system, workspace, or repository |
| Effects | `allow`, `deny`, `ask` | `allow`, `deny` |
| Prompt | May ask the user | Never prompts |
| Precedence | Last matching rule wins | Broader configuration is evaluated later and overrides narrower configuration |
| Can grant access? | Yes | No; a policy only tightens or lifts a broader deny |
| Purpose | Day-to-day tool rules | Red lines and organizational constraints |

A policy is not a replacement for a permission. Use permissions for routine
role rules and policies for the actions that must never depend on a prompt.

## 3. Policy levels and precedence

OpenCode evaluates policies from the broadest authority to the narrowest:

1. Managed preferences
2. System configuration
3. Connected Console workspace
4. Global configuration
5. Direct project configuration, outer directories before inner
6. `.opencode` project configuration

Policies reverse the normal settings precedence: a broader authority is
evaluated later and overrides a narrower one. A repository cannot re-enable a
provider, tool, MCP server, plugin, or skill that a higher authority denied.

Within one file, statements keep their written order and the last match wins.

## 4. Policy statement model

A statement has three fields:

| Field | Meaning |
| --- | --- |
| `action` | `provider.use`, `tool.use`, `integration.connect`, `integration.use`, `mcp.use`, `skill.use`, `plugin.use`, or `websearch.use` |
| `resource` | A value or wildcard pattern; `tool.use` uses `<action>:<value>` |
| `effect` | `allow` or `deny` |

Rules:

- Put broad statements first and exceptions after them.
- Use `*` only at the level where a broad allow or deny is intended.
- A `tool.use` allow never grants access; it only lifts an earlier broader
  deny, after which the agent's permission rules decide.
- Validate every statement; an invalid statement is dropped with a warning, so
  check the server log after a policy change.

## 5. Decision points

| Point | Question | Example |
| --- | --- | --- |
| Intake | May this work item use this data class and provider? | Confidential data requires approval |
| Pre-tool | May this role call this tool on this resource? | Shell command allowlist |
| Pre-write | May this role edit this path? | Deny `.git`, `.env`, `node_modules` |
| Pre-merge | Are the required gates and approvals present? | Evidence, review, human acceptance |
| Pre-release | May this version be tagged and released? | Canary and rollback plan |
| Incident | May this session continue? | Kill switch and credential revocation |
| Supply chain | May this MCP server, plugin, or skill load? | Allowlist and pin |
| Provider | May this provider or model be used? | Data residency and cost policy |

## 6. Outcomes

| Outcome | Meaning | Implementation |
| --- | --- | --- |
| `allow` | Proceed | Permission allows the action |
| `deny` | Block | Policy statement with `deny`; no prompt |
| `escalate` | A human decision is required | Permission `ask` or a `blocked` work item |
| `allow-with-obligations` | Proceed only if the obligations are met | Permission plus CI gate, command, or reviewer |

An `allow-with-obligations` outcome is a deny until the obligations are
satisfied. The obligation and its verifier are recorded in the decision.

## 7. Obligations

An obligation is a condition attached to an allow:

- require a human approval
- require sandbox isolation
- require evidence from the manifest
- require redaction of a data class
- require a trace event
- require a specific model or provider
- require a rollback plan

Every obligation names its verifier and its evidence. An obligation without a
verifier is not enforceable and must not be used.

## 8. Policy categories

### Red lines

- `shell:git push origin main`
- `shell:git push * main`
- `shell:git push *:main`
- `shell:git push --force *`
- `shell:git push -f *`
- `shell:git push * --delete *`
- `shell:sudo *`
- `shell:rm -rf *`
- `shell:curl *`
- `shell:wget *`
- `shell:gh pr merge *`

### Secrets and data

- `read:*.env`, `read:*.env.*`
- `edit:*.env`, `edit:*.env.*`
- `external_directory:*`

### Supply chain

- `mcp.use: *` deny, then allow named servers
- `plugin.use: *` deny, then allow named plugins
- `skill.use: *` deny, then allow `mycelia-*`

### Providers and models

- allow only the providers approved for the data class
- deny a provider that cannot meet the residency or retention policy

### Web

- allow the documentation domains in the allowlist
- deny general browsing by default

## 9. Data governance

Every policy decision considers the data class:

| Class | Policy |
| --- | --- |
| Public | Allowed to a model provider |
| Internal | Allowed with the repository's provider policy |
| Confidential | Approval required; redaction and residency considered |
| Secret | Never sent to a model provider; never logged |

Additional rules:

- Minimize personal data in prompts and traces.
- Redact secrets and personal data before export.
- Scan dependencies for licenses and known vulnerabilities.
- Record the data class in the work item and the decision.
- Define a retention period for traces and evidence.

## 10. Exceptions

An exception is a time-bound, owned deviation:

- names the policy and the scope
- names the owner and the justification
- names the compensating control
- has an expiry date
- is visible in the trace and the readiness report
- cannot disable a red line; it can allow a specific action for a specific time

A permanent exception is not allowed. Change the policy instead.

## 11. Testing

- Every red line has a negative test: attempt the action, expect a deny.
- Every allow has a positive test: the action proceeds.
- Every obligation has a test that fails when the obligation is missing.
- Policy changes run the tests before merge.
- A dry run evaluates the proposed policy against historical decisions.
- The test output is evidence.

## 12. Lifecycle

A policy moves through draft, active, deprecated, and retired. Each state has
an owner, a version, an effective date, and a review date. A policy change
follows the same issue, draft pull request, review, and merge process as any
other normative change.

## 13. Policy decision record

Every decision that changes state records:

- the policy and its version
- the subject: role, session, actor
- the action and resource
- the effect
- the reason
- the obligations
- the timestamp

The record is append-only and part of the trace.

## 14. Anti-patterns

- A rule that exists only in a prompt.
- Allow by default, then a few denies.
- A broad `* allow` after a deny that accidentally re-enables it.
- An exception with no expiry.
- A red line with no negative test.
- A policy that a project can override.
- A secret stored in a policy file.
- An obligation with no verifier.

## 15. Data contract

- Schema: [schemas/policy-decision.schema.json](../../schemas/policy-decision.schema.json)
- Example: [examples/policy-decision.example.yaml](../../examples/policy-decision.example.yaml)

## 16. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- `evidence-manifest.md` — definition of done (planned)
- `sandbox-and-isolation.md` — isolation (planned)
- `supply-chain.md` — supply chain (planned)
- [docs/README.md](../README.md) — documentation map
