# Sandbox and isolation

Status: Draft

## 1. Purpose

OpenCode permissions limit what an agent may do; they do not contain what a
compromised tool or shell command can do. OpenCode shell runs with the host
user's filesystem, process, and network authority. This document defines the
sandbox that contains that authority.

## 2. Why permissions are not a sandbox

A permission rule can deny a command. A sandbox limits the damage when the rule
is wrong, bypassed, or irrelevant because the tool itself is malicious.

- Permissions are policy. They decide whether to run a command.
- The sandbox is containment. It decides what the command can reach if it runs.
- A policy bypass without a sandbox is a host compromise.
- A sandbox without a policy is still a broad attack surface.

Both are required for L2 and above.

## 3. Isolation levels

| Level | Name | Mechanism | Use | Residual risk |
| --- | --- | --- | --- | --- |
| S0 | Host | None | L0 only, trusted documentation work | Full host authority; not acceptable for untrusted work |
| S1 | Container | Namespaces, cgroups, seccomp, read-only mounts | Default for L1 and L2 | Shared kernel; misconfiguration risk |
| S2 | MicroVM | Firecracker, gVisor, or Kata Containers | L3 and L4, untrusted code | Smaller surface; operational complexity |
| S3 | Ephemeral remote | Managed sandbox or per-run VM | CI, untrusted pull requests, burst work | Provider trust and data residency |

A lower level is not a substitute for a higher level. If the work item is R3 or
R4, use at least S2.

## 4. What must be isolated

### Filesystem

- Mount only the repository worktree.
- Do not mount the host home directory, SSH keys, cloud credentials, or the
  Docker socket.
- Mount the toolchain read-only where possible; keep the workspace writable.
- Do not mount other repositories or unrelated data.
- Destroy the sandbox after the run; do not reuse it across trust levels.

### Network

- Default deny egress.
- Allowlist the model provider, package registry, Git provider, and
  observability backend.
- Block the cloud metadata endpoint (`169.254.169.254`) and link-local
  addresses.
- Block localhost services that are not part of the sandbox.
- Route DNS through the approved resolver or proxy.

### Process

- Run as a non-root user.
- Set `no-new-privileges`.
- Apply a seccomp profile.
- Limit PIDs, CPU, memory, disk, and wall-clock time.
- Do not run privileged.

### Credentials

- Do not inherit the host environment.
- Inject a credential only into the tool that needs it, for the shortest
  possible time.
- Prefer short-lived tokens and workload identity.
- Never expose cloud metadata credentials.
- Redact secrets from logs and traces.

### Kernel and runtime

- Patch the container runtime and the host kernel.
- Prefer a microVM for untrusted code.
- Treat the container runtime and kernel as part of the trusted computing base.

## 5. Sandbox contract

| Property | Requirement |
| --- | --- |
| Entry | Worktree, minimal toolchain, work item, evidence manifest |
| Exit | Diff, evidence, trace; no host state |
| Network | Allowlist only |
| Secrets | Injected per tool, short-lived, never persisted |
| Lifecycle | One sandbox per run; destroyed after the run |
| Observability | Logs and traces exported; secrets redacted |
| Failure | Abort; never fall back to the host |
| Reuse | Forbidden across trust levels or work items |

## 6. OpenCode configuration

Run OpenCode itself inside the sandbox, not outside it.

- Set `external_directory` to `deny`.
- Deny `.env` reads and edits at the permission and policy layers.
- Use a shell allowlist per role.
- Set `worktree.directory` to a path inside the sandbox.
- Use `opencode run --format json` in CI.
- Do not use `--auto` with broad rules.
- Deny MCP servers, plugins, and skills by default; allow named components only.

The sandbox is not configured by `opencode.json`; it wraps the OpenCode process.

## 7. Deployment patterns

### Local development

- Use a devcontainer or a container with the repository mounted.
- Use an egress proxy with an allowlist.
- Do not mount the Docker socket.
- Destroy the container when the work item is done.

### CI

- Use an ephemeral runner or a container per job.
- Use OIDC or a short-lived token; no long-lived credentials.
- Upload evidence and traces, then destroy the runner.
- Run untrusted pull requests at S2 or S3.

### Remote sandbox

- Use a managed microVM or per-run VM.
- Upload only the worktree and the required artifacts.
- Enforce the same egress allowlist.
- Destroy the sandbox after the run.

### Desktop and web

The client is not the sandbox. The server and the tools run in the isolated
environment; the client only sends prompts and approvals.

## 8. Verification tests

| Test | Action | Expected |
| --- | --- | --- |
| Filesystem escape | Read `/etc/passwd`, the host home, or the Docker socket | Denied |
| Egress | Request an unapproved URL or the metadata endpoint | Denied |
| Secret read | Read `.env` or the inherited environment | Denied |
| Resource limit | Fork bomb, disk fill, or long-running command | Killed at the limit |
| Persistence | Inspect the host after the run | No state outside the worktree |
| Network allow | Request an approved provider or registry | Allowed |

Each test records the command, the result, and the trace event as evidence.

## 9. Failure handling

- Sandbox creation failure is an `abort`; never run on the host as a fallback.
- A denied network request is a `blocked` state; never bypass the proxy.
- A secret exposure is an incident: stop, rotate, and audit.
- A suspected escape is an incident: kill the sandbox, rebuild the host, and
  preserve the trace.

## 10. Anti-patterns

- Mounting the Docker socket into the sandbox.
- Running with `--privileged`.
- Mounting the host home directory.
- Allowing access to cloud metadata.
- Running as root.
- Reusing a sandbox across agents or trust levels.
- Disabling network isolation for convenience.
- Treating permission rules as a sandbox.
- Storing long-lived credentials in the sandbox.

## 11. Assessment questions

- Which isolation level is used for this risk tier?
- Is the host home directory mounted?
- Is egress allowlisted, including the metadata endpoint?
- Are secrets injected per tool and short-lived?
- Is the sandbox destroyed after the run?
- Are the escape, egress, secret, and resource tests run?
- Does a sandbox failure fall back to the host?
- Is OpenCode running inside the sandbox?

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [reference-architecture.md](../00-foundations/reference-architecture.md) — layers and components
- [system-context.md](../00-foundations/system-context.md) — trust boundaries
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- [policy-as-code.md](policy-as-code.md) — policy model
- [decision-rights.md](decision-rights.md) — oversight and break-glass
- `incident-response.md` — containment (planned)
- [docs/README.md](../README.md) — documentation map
