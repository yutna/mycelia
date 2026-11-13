# Glossary

The shared vocabulary for Mycelia. New terms are added here before they are
used in a normative document.

| Term | Definition |
| --- | --- |
| **Acceptance harness** | The structured flow in which a human accepts or rejects a change using an evidence packet, a risk tier, and a rollback plan. |
| **Acceptance packet** | The summary a human receives to accept a change: work item, diff, evidence, review, risk, rollback, cost, and open questions. |
| **Agent** | An OpenCode agent configuration with a system prompt, model, step limit, and permission rules. Agents are either primary or subagent. |
| **AI-BOM** | An AI bill of materials: the inventory of models, providers, MCP servers, plugins, skills, packages, actions, and base images, with versions, hashes, licenses, and owners. |
| **Ambiguity** | A condition where the goal, acceptance criteria, risk tier, data class, or approval is unclear. It ends in `blocked`, never in a guess. |
| **Approval fatigue** | The loss of attention when a human approves too many changes; it turns oversight into a rubber stamp. |
| **Attestation** | A signed statement about how an artifact was built or how a decision was made. |
| **Audit log** | The append-only record of decisions and approvals, separate from the detailed trace. |
| **Agent harness** | The runtime loop that wraps a model: context assembly, tool calls, permissions, state, and evidence. In Mycelia this is the OpenCode server and CLI. |
| **Autonomy ceiling** | The highest autonomy level a repository can safely run at, given its weakest blocking control. |
| **Autonomy level** | One of L0 manual, L1 assisted, L2 supervised, L3 autonomous, or L4 unattended. L4 still requires humans for policy, high-risk decisions, and incident command. |
| **Break-glass** | Emergency access for an incident or critical fix. It is time-bound, owned, recorded, and cannot disable the trace. |
| **Budget** | A limit on tokens, cost, time, steps, tool calls, CI minutes, concurrency, or storage for a run, role, or repository. |
| **Canary** | A limited release to a small audience or traffic share before a full rollout. |
| **Chaos engineering** | Deliberately injecting failures to test whether the system contains them and recovers. |
| **Change request** | A pull request or equivalent proposal to change the repository, linked to a work item. |
| **Checkpoint** | A durable record of the run state at a transition: state, commit, role, budget, evidence, and trace. |
| **Concern radar** | A living catalog of industry concerns with a status of adopted, adapted, watch, or out of scope, plus an owner and a review cadence. |
| **Evidence** | An artifact that proves a requirement was met: a test log, mutation score, trace, review, screenshot, or sign-off. |
| **Determinism** | The property that a check produces the same result on the same inputs and environment. |
| **Developer experience (DevEx)** | The feedback loops, cognitive load, and flow a developer experiences in the system. |
| **DORA metrics** | Lead time, deployment frequency, change failure rate, and failed deployment recovery time. |
| **Durable execution** | A run that survives a restart by checkpointing state and resuming from the last valid transition. |
| **Egress** | Outbound network traffic from the sandbox. It is denied by default and allowed only through an allowlist. |
| **Error budget** | The allowed amount of failure before an SLO is violated; burning it triggers action. |
| **Feature flag** | A runtime switch that enables or disables behavior without a new release. It needs an owner and an expiry. |
| **Escalation** | Moving a blocked decision to an owner with a precise question, options, consequences, and the evidence already collected. |
| **Evidence manifest** | A machine-readable definition of done: required evidence, thresholds, producers, verifiers, and freshness rules. |
| **Failure taxonomy** | The classification of failures and the allowed response, retry limit, and terminal state for each class. |
| **Finding** | A review observation with a severity, a summary, and an optional file and line reference. |
| **Game day** | A scheduled exercise that injects a failure and measures the human and system response. |
| **Flake** | A check that produces different results on the same input and environment; it is a defect, not a pass. |
| **Factory** | The whole system: repository, agents, policies, CI, evidence, humans, and traces. |
| **Gate** | A check that must pass before a state transition such as merge, release, or autonomy promotion. |
| **Handoff** | An artifact-mediated transfer of work between roles, with inputs, outputs, evidence, and open questions. |
| **Human in command (HIC)** | A human owns policy, accountability, and incident command at every autonomy level. |
| **Human in the loop (HITL)** | A human approves a specific action before it happens. |
| **Human on the loop (HOTL)** | A human monitors sampling and can intervene without approving every action. |
| **Idempotency** | The property that repeating an action with the same key has the same effect as doing it once. |
| **Kill switch** | A control that stops a run or a repository, revokes credentials, disables a component, and preserves the trace. |
| **Merge queue** | A serialized integration path that runs CI on the merged result before the change reaches `main`. |
| **Mutation testing** | A technique that introduces small faults into the code and checks whether the tests fail; the mutation score measures test strength. |
| **OpenTelemetry (OTel)** | An open standard for traces, metrics, and logs; the optional export format for the Mycelia trace. |
| **Mycelia** | The specification and OpenCode profile in this repository. |
| **No silent success** | The invariant that a work item cannot reach `accepted` without satisfying its evidence manifest. |
| **OpenCode profile** | The repository configuration in `opencode.json` plus the agents, commands, and skills under `.opencode/`. |
| **Policy-as-code** | Machine-enforced rules that a prompt cannot override. In OpenCode these are `policies`, which are stricter than `permissions`. |
| **Provenance** | The record of which agent, model, prompt, policy, and rule version produced an artifact. |
| **Readiness assessment** | An evidence-based evaluation of a repository against the controls. It outputs a gap report and an autonomy ceiling. |
| **Risk tier** | One of R0 documentation, R1 tests and tooling, R2 normal feature or fix, R3 sensitive area such as auth, payments, schema, or infrastructure, or R4 critical or security-sensitive. |
| **Review rubric** | The dimensions and blocking thresholds used to judge a change consistently. |
| **Reward hacking** | Satisfying a metric or check without satisfying its intent, for example weakening a test to make it pass. |
| **Red teaming** | Adversarial testing that attempts to bypass policy, exfiltrate data, or abuse a tool. |
| **Release gate** | The set of evidence, security, provenance, and rollback checks that must pass before a release. |
| **Release record** | The auditable record of a release: version, commit, gates, rollback, decision, and timestamp. |
| **Rollback** | The tested path back to the previous state: revert, feature flag off, previous artifact, or data restore. |
| **Run state** | The durable record of a run: current state, attempt, commit, budget, checkpoints, and terminal state. |
| **Runtime contract** | The capabilities Mycelia requires from OpenCode, how each maps to a primitive, and what must be built around it. |
| **Sampling** | Reviewing a random, risk-weighted subset of changes instead of every change. |
| **Sandbox** | An isolated environment that contains the filesystem, network, process, and credentials available to a run. |
| **Secretless** | A design in which the agent never holds a long-lived secret; credentials are brokered per tool and expire quickly. |
| **Severity** | The review classification of a finding: blocker, major, minor, or nit. |
| **Sign-off** | The recorded human decision to accept a change, including what was reviewed and any conditions. |
| **SLI** | A service level indicator: a measured signal such as success rate or latency. |
| **SLO** | A service level objective: a target range for an SLI. |
| **SPACE** | A developer productivity framework: satisfaction, performance, activity, communication, and efficiency. |
| **Span** | A named interval in a trace, with a parent and correlation IDs. |
| **SLSA** | Supply-chain levels for software artifacts: source integrity, build provenance, and dependency verification. |
| **Supply chain** | The models, providers, MCP servers, plugins, skills, packages, actions, and images that the factory depends on. |
| **Tamper-evident** | A property of a log where any modification or gap can be detected, for example with a hash chain. |
| **Task DAG** | A directed acyclic graph of tasks and dependencies used to partition concurrent work. |
| **Test integrity** | The property that tests still fail when the behavior is wrong; it is protected by a test-diff guard, mutation testing, and review. |
| **Role contract** | The purpose, allowed actions, denied actions, tools, data classes, and escalation path of a role. |
| **Terminal state** | One of `accepted`, `rejected`, `blocked`, or `aborted`. Every work item ends in exactly one. |
| **Trace** | An append-only event record of actions, tool calls, decisions, evidence, and cost. |
| **Verification stack** | The layered checks (static, unit, integration, end-to-end, mutation, security, performance, migration, docs, schema) that produce evidence. |
| **WIP limit** | A cap on the number of concurrent work items or runs, used to bound queue time and review load. |
| **Work item** | The unit of work: goal, acceptance criteria, non-goals, constraints, risk tier, and required evidence. |
| **Worktree** | An isolated Git working tree used to run concurrent work without collisions. |
