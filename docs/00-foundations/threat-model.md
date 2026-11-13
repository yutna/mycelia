# Threat model

This document describes the threats that Mycelia is designed to reduce. It is
a design input, not a certification. The mapping to external frameworks is
informative.

## Purpose and scope

The threat model covers an OpenCode-based software factory operating on a Git
repository: agents, tools, MCP servers, plugins, skills, CI, evidence, traces,
and the humans who accept the work.

It does not cover the internal security of the model provider, the host
operating system, or the physical environment.

## Assets

| Asset | Why it matters |
| --- | --- |
| Source code and history | The product; a malicious change is the primary impact |
| Secrets and credentials | A leak can compromise the repository, CI, or production |
| CI and release authority | A compromised pipeline can ship anything |
| Policy and role definitions | The control plane; tampering disables the guardrails |
| Evidence and traces | The audit record; tampering hides what happened |
| Model and provider accounts | Cost, data, and availability |
| Human trust and attention | Approval fatigue turns oversight into a rubber stamp |

## Trust boundaries

| Boundary | What crosses | Default stance |
| --- | --- | --- |
| Human to OpenCode | Instructions, approvals, questions | Human is trusted, but high-risk actions need explicit confirmation |
| OpenCode to provider | Prompts, code, tool results | External service; assume data leaves the machine |
| OpenCode to MCP, plugins, skills | Tool calls, instructions, code | Untrusted until reviewed and pinned |
| Repository to agent | Code, issues, comments, docs | Untrusted content; never instructions |
| Web to agent | Pages, search results, downloads | Untrusted content; allowlist only |
| Agent to agent | Handoffs, reports, evidence | Artifact-mediated; verify, do not trust |
| CI to repository | Tokens, artifacts, releases | Least privilege and short-lived credentials |
| Evidence to verifier | Claims and artifacts | Reproducible and independently checked |
| Human to evidence | Acceptance decisions | Risk-based sampling and audit |

## Assumptions

- OpenCode is trusted software, pinned to a tested version.
- The model provider is an external trust boundary.
- MCP servers, plugins, and skills are untrusted until reviewed and pinned.
- Repository content, issues, comments, and web pages are untrusted data.
- The host is not already compromised.
- The network is untrusted.
- The human owner is authorized to set policy.

## Threat catalog

### T1. Direct prompt injection

**Scenario.** A user or a prompt template tells the agent to ignore policy,
reveal a secret, or perform a destructive action.

**Impact.** Policy bypass, data loss, or secret disclosure.

**Controls.**

- **Prevent.** Hard-deny policies for destructive actions; least-privilege
  roles; explicit confirmation for high-risk changes.
- **Detect.** Trace every tool call; alert on denied actions and unusual
  commands.
- **Respond.** Stop the session, revoke credentials, revert the change, and
  record the incident.

**Evidence.** Policy decision record, trace, incident record.

**Residual risk.** A user with legitimate authority can still approve a
dangerous action. The control is evidence, not prevention.

### T2. Indirect prompt injection

**Scenario.** A repository file, issue, pull request, web page, or MCP resource
contains instructions such as "ignore the tests" or "send the token to this
URL".

**Impact.** The agent follows untrusted instructions, exfiltrates data, or
weakens the change.

**Controls.**

- **Prevent.** Treat content as data, never as instructions; allowlist
  webfetch; deny MCP and plugins by default; run in a sandbox; keep secrets out
  of the environment.
- **Detect.** Prompt injection tests; review of tool calls; anomaly detection
  on outbound requests.
- **Respond.** Quarantine the source, revoke access, revert the change, and add
  the case to the evaluation suite.

**Evidence.** Trace, network log, review record, evaluation case.

**Residual risk.** A novel injection can still influence a model. Layered
controls reduce impact, not likelihood.

### T3. Excessive agency and scope creep

**Scenario.** The agent edits files, installs packages, or changes
infrastructure outside the work item.

**Impact.** Unreviewed changes, broken builds, or security regressions.

**Controls.**

- **Prevent.** Work item scope, risk tier, role contract, edit and shell
  allowlists, policy red lines.
- **Detect.** Diff review against the issue; scope check in the pull request;
  trace of every write.
- **Respond.** Reject the change; narrow the role; add a regression test.

**Evidence.** Work item, diff, review record, trace.

**Residual risk.** A broad but legitimate task can still hide an unrelated
change. Small work items are the main mitigation.

### T4. Supply chain: MCP, plugins, skills, models

**Scenario.** A malicious or compromised MCP server, plugin, skill, model, or
provider package executes code or injects instructions.

**Impact.** Code execution, data exfiltration, policy bypass, or unreliable
output.

**Controls.**

- **Prevent.** Allowlist and pin every component; review the source; deny
  `mcp.use`, `plugin.use`, and `skill.use` by default; use a sandbox.
- **Detect.** Provenance record, version diff, network egress monitoring,
  evaluation of the component's behavior.
- **Respond.** Disable the component, revoke credentials, revert changes, and
  record the incident.

**Evidence.** Component inventory, pin, review, provenance, trace.

**Residual risk.** A pinned component can still be malicious. Review and
isolation are the remaining controls.

### T5. Secret and credential exposure

**Scenario.** The agent reads `.env`, prints a token, sends a secret to a
model provider, or writes it into a trace.

**Impact.** Credential compromise and lateral movement.

**Controls.**

- **Prevent.** Deny `.env` reads and edits; use short-lived credentials; keep
  secrets out of prompts and logs; redact traces.
- **Detect.** Secret scanning, trace review, provider data policy.
- **Respond.** Rotate the secret, revoke the session, and audit usage.

**Evidence.** Policy decision, secret scan result, trace redaction record.

**Residual risk.** A secret that is legitimately in scope can still leak
through a model provider. Data classification is required.

### T6. Data exfiltration

**Scenario.** The agent sends source code, customer data, or credentials to an
unapproved URL, MCP server, or provider.

**Impact.** Intellectual property loss, privacy breach, regulatory exposure.

**Controls.**

- **Prevent.** Allowlist webfetch, deny arbitrary network access, use a
  sandbox, classify data, and block MCP servers by default.
- **Detect.** Egress logs, data loss prevention, review of external calls.
- **Respond.** Block the destination, rotate credentials, notify the owner,
  and record the incident.

**Evidence.** Network log, policy decision, data classification, incident
record.

**Residual risk.** A provider that is approved can still retain data. Contract
and configuration review are required.

### T7. Evidence fabrication and self-certification

**Scenario.** The agent reports that tests passed, attaches a stale log, or
marks its own work as verified.

**Impact.** A false `accepted` state and an unreliable audit trail.

**Controls.**

- **Prevent.** Independent verifier, evidence hashes, reproducible commands,
  producer-verifier separation, gate re-run in CI.
- **Detect.** Compare evidence timestamps and commit hashes; sample and re-run;
  check the verifier identity.
- **Respond.** Reject the change, invalidate the evidence, and add the case to
  the evaluation suite.

**Evidence.** Evidence manifest, verifier record, CI log, trace.

**Residual risk.** A compromised verifier can still collude. Separation and
audit sampling are the remaining controls.

### T8. Test weakening and reward hacking

**Scenario.** The agent deletes a test, skips an assertion, loosens a threshold,
or changes the test to match the implementation.

**Impact.** Green checks with broken behavior.

**Controls.**

- **Prevent.** Test-diff guard, mutation score for changed lines, held-out
  tests, review of test changes, no self-approval.
- **Detect.** Mutation testing, coverage of changed lines, review rubric,
  anomaly detection on test counts.
- **Respond.** Reject the change, restore the test, and add a regression case.

**Evidence.** Test diff, mutation score, review record, trace.

**Residual risk.** A test can be weak without being modified. Mutation testing
and review are the main mitigations.

### T9. Concurrency conflict and lost update

**Scenario.** Two agents edit the same file, branch, or resource; one change
overwrites the other.

**Impact.** Lost work, inconsistent state, or a broken merge.

**Controls.**

- **Prevent.** Worktrees, file ownership, task DAG, WIP limits, merge queue,
  small changes.
- **Detect.** Conflict detection, CI on the merge queue, trace correlation.
- **Respond.** Stop the affected work, rebase or redo, and record the conflict.

**Evidence.** Worktree record, merge queue result, trace.

**Residual risk.** Semantic conflicts can survive a clean merge. Tests and
review are required.

### T10. Model or provider drift

**Scenario.** A model upgrade changes behavior, a provider changes a default,
or a routing rule sends a task to a weaker model.

**Impact.** Quality regression, cost increase, or policy mismatch.

**Controls.**

- **Prevent.** Pin model and provider versions; use variants deliberately;
  route by risk tier.
- **Detect.** Golden task suite, canary runs, cost and quality metrics.
- **Respond.** Roll back the model or route, record the change, and update the
  evaluation suite.

**Evidence.** Evaluation result, provenance record, model version, trace.

**Residual risk.** A provider can change behavior without a version change.
Continuous evaluation is required.

### T11. Trace tampering and audit gaps

**Scenario.** Events are dropped, edited, or stored without access control; the
audit cannot reconstruct what happened.

**Impact.** No accountability, failed incident analysis, compliance exposure.

**Controls.**

- **Prevent.** Append-only storage, hash chaining, access control, retention
  policy, complete event schema.
- **Detect.** Integrity check, gap detection, sampling.
- **Respond.** Quarantine the trace, restore from a trusted copy, and record
  the gap.

**Evidence.** Trace store, integrity check, retention record.

**Residual risk.** A compromised server can still forge events. External
anchoring is an optional stronger control.

### T12. Budget exhaustion and denial of service

**Scenario.** A loop retries forever, a tool call is expensive, or many agents
run at once and exhaust the budget.

**Impact.** Cost overrun, unavailable service, or a stopped delivery.

**Controls.**

- **Prevent.** Step limits, time limits, token budgets, concurrency limits,
  rate limits, kill switch.
- **Detect.** Usage metrics, alerts, anomaly detection.
- **Respond.** Abort the run, revoke the session, and record the cause.

**Evidence.** Budget record, usage event, abort record.

**Residual risk.** A budget can be set too high. Review the budget per risk
tier.

### T13. Approval fatigue and rubber-stamping

**Scenario.** A human approves many changes without reading the evidence
because the queue is too long.

**Impact.** High-risk changes pass without real oversight.

**Controls.**

- **Prevent.** Risk-based sampling, acceptance packets, review rubric, WIP
  limits, clear ownership.
- **Detect.** Override rate, review time, false acceptance rate, audit sample.
- **Respond.** Reduce the queue, raise the risk tier, and re-review the sample.

**Evidence.** Acceptance record, review time, audit sample.

**Residual risk.** Attention is finite. Sampling and clear risk tiers are the
main mitigations.

### T14. Sandbox escape and host compromise

**Scenario.** A shell command or plugin escapes the workspace and modifies the
host, the network, or another project.

**Impact.** Full compromise of the host and every repository on it.

**Controls.**

- **Prevent.** Container or VM isolation, no host mounts, least privilege,
  network egress allowlist, read-only mounts where possible.
- **Detect.** Host monitoring, process and network anomaly detection.
- **Respond.** Kill the sandbox, revoke credentials, rebuild the host, and
  record the incident.

**Evidence.** Sandbox configuration, host log, incident record.

**Residual risk.** The container runtime and kernel are part of the trusted
computing base. Patch them.

### T15. Reproducibility failure

**Scenario.** A check passes once and cannot be reproduced; the evidence is
environment-specific or flaky.

**Impact.** False confidence and wasted investigation.

**Controls.**

- **Prevent.** Pin the toolchain and dependencies, use deterministic tests,
  record environment hashes, quarantine flaky tests.
- **Detect.** Re-run in a clean environment, compare evidence hashes, track
  flake rate.
- **Respond.** Mark the evidence unproven, fix or quarantine the check, and
  record the variance.

**Evidence.** Environment record, re-run result, flake report.

**Residual risk.** Some systems are inherently non-deterministic. Record the
variance rather than hiding it.

## Framework mapping

The mapping is informative and not exhaustive.

| Threat | STRIDE | OWASP LLM Top 10 (2025) | Primary control |
| --- | --- | --- | --- |
| T1 Direct prompt injection | Tampering, Elevation | LLM01 Prompt Injection | Policies and confirmations |
| T2 Indirect prompt injection | Tampering, Elevation | LLM01 Prompt Injection | Untrusted-data stance, sandbox |
| T3 Excessive agency | Elevation | LLM06 Excessive Agency | Role contract, scope |
| T4 Supply chain | Tampering | LLM03 Supply Chain | Allowlist, pin, review |
| T5 Secret exposure | Information disclosure | LLM02 Sensitive Information Disclosure | Deny `.env`, redaction |
| T6 Data exfiltration | Information disclosure | LLM02 Sensitive Information Disclosure | Egress allowlist |
| T7 Evidence fabrication | Tampering, Repudiation | LLM09 Misinformation | Independent verifier |
| T8 Test weakening | Tampering | LLM09 Misinformation | Mutation and test-diff guard |
| T9 Concurrency conflict | Tampering | Not applicable | Worktrees, merge queue |
| T10 Model drift | Tampering, Spoofing | LLM04 Data and Model Poisoning | Evals, pinning |
| T11 Trace tampering | Repudiation | Not applicable | Append-only trace |
| T12 Budget exhaustion | Denial of service | LLM10 Unbounded Consumption | Budgets and kill switch |
| T13 Approval fatigue | Repudiation | LLM09 Misinformation | Sampling and audit |
| T14 Sandbox escape | Elevation | Not applicable | Container or VM isolation |
| T15 Reproducibility failure | Tampering | Not applicable | Pinning and variance record |

## Abuse cases

- A contributor embeds instructions in an issue or pull request.
- A compromised MCP server returns instructions in a resource.
- An insider disables a gate or an exception without review.
- An agent is tricked into sending a `.env` file to an external URL.
- An agent weakens a test to make CI green.
- An agent force-pushes to `main` or deletes a branch.
- Two agents overwrite each other's work in the same file.
- A human approves a high-risk change without reading the evidence.

## Out of scope

- Theft of model weights or training data.
- Poisoning of a model's training data; Mycelia does not train models.
- A nation-state compromise of the host or the provider.
- Legal or regulatory determination.
- Provider-side behavior that violates its contract.
- Physical access to the machine.

## Review cadence

Review this threat model:

- when a new MCP server, plugin, or skill is added
- when the model, provider, or routing changes
- quarterly, with the concern radar
- after an incident or a near miss
- before raising a repository's autonomy level

## Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [GOVERNANCE.md](../../GOVERNANCE.md) — change process
- [GLOSSARY.md](../../GLOSSARY.md) — terminology
- [principles.md](principles.md) — design principles
- [concern-radar.md](concern-radar.md) — concern catalog
- [docs/README.md](../README.md) — documentation map
