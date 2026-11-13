# Glossary

The shared vocabulary for Mycelia. New terms are added here before they are
used in a normative document.

| Term | Definition |
| --- | --- |
| **Acceptance harness** | The structured flow in which a human accepts or rejects a change using an evidence packet, a risk tier, and a rollback plan. |
| **Agent** | An OpenCode agent configuration with a system prompt, model, step limit, and permission rules. Agents are either primary or subagent. |
| **Agent harness** | The runtime loop that wraps a model: context assembly, tool calls, permissions, state, and evidence. In Mycelia this is the OpenCode server and CLI. |
| **Autonomy ceiling** | The highest autonomy level a repository can safely run at, given its weakest blocking control. |
| **Autonomy level** | One of L0 manual, L1 assisted, L2 supervised, L3 autonomous, or L4 unattended. L4 still requires humans for policy, high-risk decisions, and incident command. |
| **Concern radar** | A living catalog of industry concerns with a status of adopted, adapted, watch, or out of scope, plus an owner and a review cadence. |
| **Evidence** | An artifact that proves a requirement was met: a test log, mutation score, trace, review, screenshot, or sign-off. |
| **Evidence manifest** | A machine-readable definition of done: required evidence, thresholds, producers, verifiers, and freshness rules. |
| **Factory** | The whole system: repository, agents, policies, CI, evidence, humans, and traces. |
| **Gate** | A check that must pass before a state transition such as merge, release, or autonomy promotion. |
| **Handoff** | An artifact-mediated transfer of work between roles, with inputs, outputs, evidence, and open questions. |
| **Mycelia** | The specification and OpenCode profile in this repository. |
| **No silent success** | The invariant that a work item cannot reach `accepted` without satisfying its evidence manifest. |
| **OpenCode profile** | The repository configuration in `opencode.json` plus the agents, commands, and skills under `.opencode/`. |
| **Policy-as-code** | Machine-enforced rules that a prompt cannot override. In OpenCode these are `policies`, which are stricter than `permissions`. |
| **Provenance** | The record of which agent, model, prompt, policy, and rule version produced an artifact. |
| **Readiness assessment** | An evidence-based evaluation of a repository against the controls. It outputs a gap report and an autonomy ceiling. |
| **Risk tier** | One of R0 documentation, R1 tests and tooling, R2 normal feature or fix, R3 sensitive area such as auth, payments, schema, or infrastructure, or R4 critical or security-sensitive. |
| **Role contract** | The purpose, allowed actions, denied actions, tools, data classes, and escalation path of a role. |
| **Terminal state** | One of `accepted`, `rejected`, `blocked`, or `aborted`. Every work item ends in exactly one. |
| **Trace** | An append-only event record of actions, tool calls, decisions, evidence, and cost. |
| **Work item** | The unit of work: goal, acceptance criteria, non-goals, constraints, risk tier, and required evidence. |
| **Worktree** | An isolated Git working tree used to run concurrent work without collisions. |
