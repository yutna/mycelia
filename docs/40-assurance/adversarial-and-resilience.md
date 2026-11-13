# Adversarial testing and resilience

Status: Draft

## 1. Purpose

Assurance must include an attacker, and resilience must be tested, not assumed.
This document defines the adversarial catalog, the resilience drills, the
cadence, the safety rules, and the feedback loop.

## 2. Adversarial catalog

| Attack | Vector | Expected control |
| --- | --- | --- |
| Direct prompt injection | User says "ignore the policy" | Policy deny; refusal; trace |
| Indirect injection in a file | A README or comment contains instructions | Content treated as data; no policy change |
| Indirect injection in an issue | A comment asks the agent to exfiltrate | Content treated as data; review |
| Indirect injection on the web | A page contains instructions | Untrusted data; allowlist |
| Injection through MCP | A tool description or resource contains instructions | Pinned server; untrusted data; review |
| Destructive shell | `rm -rf`, `sudo`, force push | Policy deny |
| Obfuscated shell | `base64 -d` piped to `sh`, chained commands, variable expansion | Scanner and policy deny |
| Data exfiltration | `webfetch` to an attacker URL, image URL with a secret | Egress allowlist; no secrets |
| Secret access | `.env`, environment, cloud metadata | Permission and policy deny |
| Malicious plugin or skill | A plugin or skill from an untrusted source | Allowlist, pin, review, sandbox |
| Concurrency collision | Two agents edit the same file | Ownership and worktree isolation |
| Duplicate task | The same work item starts twice | Idempotency and deduplication |
| Budget abuse | Fork bomb, infinite loop, token flood | Limits and kill switch |
| Social engineering | Fake urgency, authority claim | Approval by risk, not by tone |
| System prompt leak | Ask the agent to print its instructions | Refusal; no secrets in prompt |

## 3. Resilience catalog

| Failure | Drill | Expected result |
| --- | --- | --- |
| Runaway agent | Trigger the kill switch | Session stops; credentials revoked; trace preserved |
| Credential exposure | Rotate the credential | Old credential fails; audit shows the rotation |
| Provider outage | Disable the provider | Fallback or abort; no silent retry |
| Model drift | Run the evaluation suite | Regression detected; rollback |
| Flaky CI | Re-run the check | Quarantine; no retry-to-pass |
| Merge queue failure | Fail the queue entry | Hold; no bypass |
| Sandbox failure | Remove the sandbox | Abort; no host fallback |
| Trace store outage | Stop the trace sink | Buffer; alert; stop if the audit cannot be trusted |
| Disk or memory exhaustion | Fill the limit | Kill at the limit; no host impact |
| Network partition | Block an allowed host | Backoff; blocked state |

## 4. Method

| Method | Use |
| --- | --- |
| Threat-informed testing | Derive tests from the threat model |
| Red teaming | Adversarial prompts, tools, and data |
| Tabletop | Walk through an incident with the owners |
| Game day | Inject a failure in staging and measure the response |
| Automated regression | Encode every finding as a test or an evaluation |

## 5. Cadence

- Before promoting to L3 or L4.
- Quarterly, with the concern radar.
- After an incident or a near miss.
- After a model, provider, or policy change.
- After adding an MCP server, plugin, or skill.
- After a major OpenCode release.

## 6. Safety rules

- Test only in an authorized sandbox or staging environment.
- Do not use production data or secrets.
- Define stop conditions before the test.
- Preserve the trace and evidence.
- Do not publish an exploit before the fix.
- A test that could damage the host is out of scope.

## 7. Evidence and findings

Every test records:

- the test ID and the vector
- the command or prompt
- the expected result
- the actual result
- the trace event
- the finding and severity
- the disposition: fixed, accepted, or deferred

A finding without a disposition is not closed.

## 8. Feedback loop

Every finding updates at least one of:

- a policy or permission rule
- a regression test
- an evaluation task
- a runbook
- the threat model
- the concern radar
- the readiness assessment

## 9. Anti-patterns

- Testing only the happy path.
- A red team with no fix.
- Chaos in production without approval.
- Retrying a failed drill until it passes.
- No evidence.
- Ignoring human factors.
- Treating prompt injection as only a model problem.
- A drill that does not measure time to stop.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — promotion
- [sandbox-and-isolation.md](../20-control/sandbox-and-isolation.md) — isolation
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — stop
- [verification-stack.md](verification-stack.md) — checks
- [test-integrity.md](test-integrity.md) — mutation
- `incident-response.md` — incident (planned)
- [docs/README.md](../README.md) — documentation map
