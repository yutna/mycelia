# Supply chain

Status: Draft

## 1. Purpose

The agent's dependencies are code and instructions. An unmanaged dependency is
an unmanaged agent. This document defines the inventory, trust levels, and
controls for MCP servers, plugins, skills, models, providers, packages, actions,
and base images.

## 2. Threat context

The primary threats are in
[threat-model.md](../00-foundations/threat-model.md):

- T4 supply chain: a malicious or compromised component
- T2 indirect prompt injection through tool descriptions or skill text
- T6 data exfiltration through a tool or server
- T14 sandbox escape through a plugin or local MCP command

## 3. Inventory

| Component | Examples | Risk |
| --- | --- | --- |
| MCP server | Local stdio server, remote HTTP server | Tools, resources, prompts, network |
| Plugin | Server plugin, TUI plugin, GUI plugin | Code execution in the server or client |
| Skill | Local `SKILL.md`, HTTP catalog | Instructions that can steer the model |
| Model and provider | Hosted API, local model | Data retention, drift, cost |
| Package dependency | npm, pip, gem, cargo | Code execution at install or runtime |
| GitHub Action | CI step | CI credentials and repository access |
| Base image | Container or devcontainer | Kernel and runtime surface |
| Prompt and command | `.opencode/commands/` | Behavior changes without code |

Every component in the inventory has an owner, a version, and a trust level.

## 4. Trust levels

| Level | Name | Meaning | Allowed |
| --- | --- | --- | --- |
| T0 | Internal | First-party, reviewed, pinned | All risk tiers |
| T1 | Reviewed | Third-party, reviewed, pinned | R0-R3 with policy |
| T2 | Community | Unreviewed or weakly reviewed | Sandbox only, no secrets, R0-R1 |
| T3 | Blocked | Known bad or unverifiable | Never |

A higher risk tier requires a higher trust level. R3 and R4 require T0 or a T1
component with a current security review.

## 5. Controls

### Allowlist

- Deny `mcp.use`, `plugin.use`, and `skill.use` by default.
- Allow only the named components in the inventory.
- A new component is a policy change, not an incidental install.

### Pin

- Pin the version, git commit, or container digest.
- Pin the model and provider.
- Pin the package lockfile.
- Pin the base image by digest.
- Do not use `latest` or an unpinned `npx -y` in a trusted path.

### Review

Review the source, permissions, network access, data access, and update diff.
For a skill, review the instructions as untrusted input. For a plugin, review
the hooks and the tools it registers.

### Least privilege

- Grant only the tools and resources the role needs.
- Limit OAuth scopes for remote MCP servers.
- Do not pass secrets in environment variables when a broker can inject them.
- Run local MCP servers and plugins inside the sandbox.

### Sandbox

The component runs inside the same isolation as the agent. A local MCP server
or plugin must not receive host credentials or the Docker socket.

### Provenance

Record the component in the AI-BOM with its source, hash, license, owner, and
review date. Prefer signed artifacts where the ecosystem supports them.

### Update

An update is a reviewed change. Diff the version, run the evaluation suite, and
canary it on low-risk work before a broad rollout.

### Revoke

A compromised or untrusted component is disabled, removed from the allowlist,
and its credentials are rotated. The incident is recorded.

## 6. AI-BOM

The AI bill of materials records every component:

| Field | Example |
| --- | --- |
| `type` | `mcp`, `plugin`, `skill`, `model`, `provider`, `package`, `action`, `image` |
| `name` | `github`, `mycelia-audit`, `opencode`, `node` |
| `version` | `1.4.2`, git SHA, or image digest |
| `source` | Registry, repository, or URL |
| `hash` | SHA-256 or image digest |
| `license` | SPDX identifier |
| `owner` | Maintainer or team |
| `trustLevel` | T0-T3 |
| `dataAccess` | Data classes the component can read |
| `reviewedAt` | Last review date |
| `status` | `active`, `deprecated`, `revoked` |

The planned location is `ai-bom.yaml` at the repository root. Until the schema
exists, the inventory is a table in the readiness report.

## 7. SLSA mapping

| SLSA concern | Mycelia control |
| --- | --- |
| Source integrity | Protected branches, signed commits or tags, review |
| Build provenance | CI-generated attestation for release artifacts |
| Dependency verification | Lockfiles, hashes, allowlist, review |
| Artifact integrity | Immutable releases and hashes in evidence |

The target level depends on the risk tier. R3 and R4 aim for SLSA Build L2 or
higher. The specification does not claim a level without evidence.

## 8. MCP risks

- **Tool poisoning.** A tool description contains instructions.
- **Rug pull.** A server changes behavior after approval.
- **Cross-server shadowing.** Two servers expose the same tool name.
- **Instruction injection.** Server instructions enter the system prompt.
- **Resource injection.** A resource contains untrusted instructions.
- **OAuth scope creep.** A server requests more access than it needs.
- **Local command execution.** A local server runs a command with host access.

Controls: pin, review, allowlist tools, deny by default, sandbox the server,
monitor changes, use unique names, request minimal OAuth scopes, and never pass
secrets in environment variables.

## 9. Plugin and skill risks

- A plugin runs code in the OpenCode server.
- A TUI or GUI plugin runs in the client.
- A skill is an instruction, not code, but it can steer the model.
- A transitive dependency can compromise a plugin.
- A remote skill catalog can change after review.

Controls: review the source, pin the version, deny by default, sandbox the
server, allowlist the skill ID, and treat skill text as untrusted input.

## 10. Model and provider risks

- Data retention and training policy.
- Model version drift.
- Data residency.
- Terms of service.
- Cost and rate limits.

Controls: a provider policy, data classification before the call, pinned model
versions, evaluation before a change, contract review, and a fallback provider.

## 11. Update and revocation

1. Open an issue with the new version and the reason.
2. Review the diff and the permissions.
3. Run the evaluation suite.
4. Canary on low-risk work.
5. Update the AI-BOM and the pin.
6. Keep the previous version for rollback.

Revocation is immediate: disable the component, remove it from the allowlist,
rotate credentials, and record the incident.

## 12. Dependency updates

A dependency update is a change like any other, but its risk does not follow
from the size of its diff: a one-line lockfile bump can change an API. This
section sets the minimum risk tier of a dependency update from data the
runtime can read. A human may raise the tier, never lower it below the
minimum.

Defaults (fields added in #109):

| Setting | Default |
| --- | --- |
| Test-only packages (R1 updates) | None |
| R3 packages | A repository list of package names or patterns, seeded from these categories: authentication, cryptography, payments, database drivers, infrastructure |

### `MYC-CTL-007` Dependency update risk tier

- **Statement:** The runtime MUST propose the minimum risk tier of a dependency
  update from the version change and the repository's lists:
  1. A patch or minor update of a package on the repository's test-only list:
     R1.
  2. Any other patch or minor update: R2.
  3. A major update, any update of a pre-1.0 package other than a patch, a
     version change that does not parse as semantic versioning (calendar
     versions, commit references), or a lockfile change with no manifest
     change that moves a package across a major version: a **migration**, at
     least R2, in its own work item with a migration plan and its rollback.
  4. A new direct dependency: at least R2, and the package passes the
     allowlist review (§5).
  5. A package on the repository's R3 list: at least R3, which a human
     confirms ([decision-rights.md](decision-rights.md) §2).

  Adding a package to the test-only list or removing one from the R3 list
  lowers a tier: it is a guard loosening
  ([guard-design.md](guard-design.md) `MYC-CTL-006`, human approval) and MUST
  NOT apply in the pull request that makes it.

  When a dependency update whose change patch touches only dependency
  manifests and lockfiles fails a compile, type, or test check after the flake
  check of [verification-stack.md](../40-assurance/verification-stack.md) §4,
  the update MUST NOT be retried as a product failure: it ends `rejected` and
  the runtime proposes a migration work item
  ([failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) §2).
  Updates opened by a bot follow the same rules.
- **Rationale:** A major upgrade that needed an API migration was treated as a
  safe bump and failed; a bump that changes code shipped in the artifact is a
  normal change, not a test-only one.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** The proposed tier with the version change and the list entries
  it used; the migration work item for a failed update.
- **Verification:** Fixture `dependency-tier` (proposed for #108): one update
  per rule above; check the proposed tier and, for a failing major update, the
  `rejected` outcome and the proposed migration.
- **Failure mode:** The work item is `blocked` until a human confirms an R3
  tier; ceiling lowered to L1 when dependency updates bypass the rules.

## 13. Verification

- The inventory is complete.
- Every pin matches its lockfile or digest.
- The allowlist is enforced by policy.
- The review date is current.
- No unapproved network destination is reachable.
- The AI-BOM is updated.
- R3 and R4 releases have the required provenance attestation.

## 14. Anti-patterns

- `npx -y` with an unpinned package in a trusted path.
- A plugin from an unknown source.
- A skill loaded from a URL without review.
- `mcp.use * allow`.
- Secrets in MCP environment variables.
- Auto-update without review.
- No inventory.
- Trusting a component because it is popular.
- A model upgrade with no evaluation.

## 15. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- [policy-as-code.md](policy-as-code.md) — allowlist and red lines
- [sandbox-and-isolation.md](sandbox-and-isolation.md) — isolation
- [evidence-manifest.md](evidence-manifest.md) — evidence
- `provenance.md` — provenance and AI-BOM (planned)
- `incident-response.md` — containment (planned)
- [docs/README.md](../README.md) — documentation map
