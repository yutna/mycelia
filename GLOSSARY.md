# Glossary

The shared vocabulary for Mycelia. New terms are added here before they are
used in a normative document.

| Term | Definition |
| --- | --- |
| **Acceptance harness** | The structured flow in which a human accepts or rejects a change using an evidence packet, a risk tier, and a rollback plan. |
| **Acceptance packet** | The summary a human receives to accept a change: work item, diff, evidence, review, risk, rollback, cost, and open questions. |
| **Adoption boundary** | The line between the shared Mycelia core and the adopter's local configuration. |
| **Agent** | An OpenCode agent configuration with a system prompt, model, step limit, and permission rules. Agents are either primary or subagent. |
| **AI-BOM** | An AI bill of materials: the inventory of models, providers, MCP servers, plugins, skills, packages, actions, and base images, with versions, hashes, licenses, and owners. |
| **Ambiguity** | A condition where the goal, acceptance criteria, risk tier, data class, or approval is unclear. It ends in `blocked`, never in a guess. |
| **Approval fatigue** | The loss of attention when a human approves too many changes; it turns oversight into a rubber stamp. |
| **Attestation** | A signed statement about how an artifact was built or how a decision was made. |
| **Assurance case** | A claim, the arguments that support it, and the evidence that backs the arguments. |
| **Audit log** | The append-only record of decisions and approvals, separate from the detailed trace. |
| **Agent harness** | The runtime loop that wraps a model: context assembly, tool calls, permissions, state, and evidence. In Mycelia this is the OpenCode server and CLI. |
| **Autonomy ceiling** | The highest autonomy level a repository can safely run at, given its weakest blocking control. |
| **Autonomy level** | One of L0 manual, L1 assisted, L2 supervised, L3 autonomous, or L4 unattended. L4 still requires humans for policy, high-risk decisions, and incident command. |
| **Blocked-only preflight** | The check, before a work cycle starts any run, that finds eligible work items but none runnable; the cycle then starts no run and sends at most one summary notification (`MYC-EXE-016`). |
| **Base delta** | The paths changed on the default branch since the merge base a change's evidence was produced on. |
| **Break-glass** | Emergency access for an incident or critical fix. It is time-bound, owned, recorded, and cannot disable the trace. |
| **Brownfield** | An existing repository with legacy code, checks, and ownership that must be adopted incrementally. |
| **Budget** | A limit on tokens, cost, time, steps, tool calls, CI minutes, concurrency, or storage for a run, role, or repository. |
| **Bypass corpus** | The fixtures, per guard rule, that each try a known bypass form and must be caught (`MYC-CTL-003`). |
| **Canary** | A limited release to a small audience or traffic share before a full rollout. Not a guard canary. |
| **Capacity planning** | Sizing concurrency, review, and incident capacity to the expected demand. |
| **Chaos engineering** | Deliberately injecting failures to test whether the system contains them and recovers. |
| **Change request** | A pull request or equivalent proposal to change the repository, linked to a work item. |
| **Chargeback** | Allocating cost to the team or work item that incurred it. |
| **Claim** | A statement in an assurance case that must be supported by an argument and evidence. |
| **Conformance claim** | A statement that a repository meets a profile at a level, backed by a readiness report and evidence. |
| **Conformance fixture** | One conformance kit scenario as YAML data: requirements, profiles, and cases with input, steps, and expected outcome. |
| **Conformance kit** | The command, fixtures, and result contract that show a runtime conforms (`MYC-CORE-013`); executed by an implementation of the contract. |
| **Conformance result** | The record of one kit run against a runtime and profile; valid for a claim only under `MYC-ADP-001`. |
| **Checkpoint** | A durable record of the run state at a transition: state, commit, role, budget, evidence, and trace. |
| **CLI contract** | The commands, flags, exit codes, and output formats an implementation must provide. |
| **Containment** | Stopping the spread of an incident: kill switch, credential revocation, component quarantine, or rollback. |
| **Cost per accepted change** | Total cost divided by the number of accepted changes. |
| **Crosswalk** | A mapping from a concern or framework to the document that owns it. |
| **Concern radar** | A living catalog of industry concerns with a status of adopted, adapted, watch, or out of scope, plus an owner and a review cadence. |
| **Durable trace sink** | The store a conformant runtime writes every received OpenCode event to, so the trace survives disconnects and restarts (`MYC-EXE-012`). |
| **Evidence** | An artifact that proves a requirement was met: a test log, mutation score, trace, review, screenshot, or sign-off. |
| **Deprecation** | The state of a rule that is still enforced but scheduled for removal, with a replacement or reason. |
| **Determinism** | The property that a check produces the same result on the same inputs and environment. |
| **Developer experience (DevEx)** | The feedback loops, cognitive load, and flow a developer experiences in the system. |
| **DORA metrics** | Lead time, deployment frequency, change failure rate, and failed deployment recovery time. |
| **Durable execution** | A run that survives a restart by checkpointing state and resuming from the last valid transition. |
| **Egress** | Outbound network traffic from the sandbox. It is denied by default and allowed only through an allowlist. |
| **Eligible work item** | An open work item that the runtime may run at its autonomy level, that no other run holds a lease on, and that no human has paused; it is runnable when it has no open question. |
| **Error budget** | The allowed amount of failure before an SLO is violated; burning it triggers action. |
| **Evaluation suite** | A set of tasks and metrics used to compare a change against a baseline. |
| **Exception** | A time-bound, owned deviation from a rule, with a compensating control and an expiry. |
| **Exit code** | The numeric result of a command: 0 success, 1 policy or kill-switch stop, 2 input, 3 blocked, 4 budget, 5 internal, 6 conformance, 7 rejected. |
| **Fast gate** | The pull request gate that runs the required layers over the checks a change affects, within a time target (`MYC-ASR-001`). |
| **Feature flag** | A runtime switch that enables or disables behavior without a new release. It needs an owner and an expiry. |
| **File format** | The serialization and layout of an artifact: YAML, JSON, JSONL, Markdown, or Git. |
| **Escalation** | Moving a blocked decision to an owner with a precise question, options, consequences, and the evidence already collected. |
| **Evidence manifest** | A machine-readable definition of done: required evidence, thresholds, producers, verifiers, and freshness rules. |
| **Failure taxonomy** | The classification of failures and the allowed response, retry limit, and terminal state for each class. |
| **Finding** | A review observation with a severity, a summary, and an optional file and line reference. |
| **Full gate** | The gate that runs every required layer over the whole repository, on a schedule, on releases, and on triggers (`MYC-ASR-002`). |
| **Game day** | A scheduled exercise that injects a failure and measures the human and system response. |
| **Gap register** | The list of unmet controls with severity, finding, remediation, owner, and effort. |
| **GSN** | Goal Structuring Notation: a way to draw claims, arguments, and evidence for an assurance case. |
| **Golden path** | The supported sequence for adopting and operating the profile. |
| **Greenfield** | A new repository that can start from the template with no legacy constraints. |
| **Golden task** | A representative work item with a fixed input, expected outcome, and scoring method. |
| **Flake** | A check that produces different results on the same input and environment; it is a defect, not a pass. |
| **Factory** | The whole system: repository, agents, policies, CI, evidence, humans, and traces. |
| **Gate** | A check that must pass before a state transition such as merge, release, or autonomy promotion. |
| **Guard** | An automated rule that blocks or flags an action or a change: a lint rule, CI check, policy, permission rule, or plugin guard. |
| **Guard canary** | A guard fixture with a known input and an exact expected offense count, findings status, and rule name (`MYC-CTL-004`). Not a release canary. |
| **Handoff** | An artifact-mediated transfer of work between roles, with inputs, outputs, evidence, and open questions. |
| **Headless run** | A run with no person at the OpenCode client, such as a run started by the scheduler or by an operator command that does not stay attached. Not the same as L4 unattended. |
| **Heartbeat** | A timestamp an active run writes to its run state at a configured interval, so the runtime can tell a live run from a stale one. |
| **Human in command (HIC)** | A human owns policy, accountability, and incident command at every autonomy level. |
| **Human in the loop (HITL)** | A human approves a specific action before it happens. |
| **Human on the loop (HOTL)** | A human monitors sampling and can intervene without approving every action. |
| **Idempotency** | The property that repeating an action with the same key has the same effect as doing it once. |
| **Idempotency key** | The key on an external side effect, made of the work item, the commit, and the action, that makes a repeat return the original result instead of a second effect. |
| **Implementation choice** | A choice the work item leaves open that is not a question about goal, criteria, scope, risk, data class, approval, or source of truth, such as an internal structure or a name that follows an existing convention. The only decision class an agent may decide (`MYC-EXE-019`). |
| **Incident commander** | The human who owns an incident response and its decisions. |
| **Kill switch** | A control that stops a run or a repository, revokes credentials, disables a component, and preserves the trace. |
| **Lease** | The exclusive claim a run holds on its work item, so only one run is active per work item (`MYC-EXE-004`). |
| **Merge queue** | A serialized integration path that runs CI on the merged result before the change reaches `main`. |
| **Meta-check** | A check over a guard that fails when a rule in the effective rule set has no canary or bypass corpus (`MYC-CTL-005`). |
| **Migration (dependency)** | A dependency update that crosses a major version or cannot be read as semantic versioning; its own work item with a plan and rollback (`MYC-CTL-007`). |
| **Model routing** | Choosing a model or provider by risk tier, cost, capability, or availability. |
| **Mutation testing** | A technique that introduces small faults into the code and checks whether the tests fail; the mutation score measures test strength. |
| **Notification adapter** | The runtime component that tells the owner a work item is `blocked`, records delivery and acknowledgement, and escalates on expiry (`MYC-EXE-009`). |
| **OpenTelemetry (OTel)** | An open standard for traces, metrics, and logs; the optional export format for the Mycelia trace. |
| **pass@k** | The probability that at least one of k attempts succeeds on a task. |
| **Postmortem** | A blameless review of an incident: timeline, impact, causes, response, and actions. |
| **Profile** | A named control set: minimal, standard, or high-assurance. |
| **Progress** | A merged change, or a work item that ends `accepted` or `rejected`. Reports, comments, status updates, heartbeats, and notifications are not progress (`MYC-EXE-015`). |
| **Mycelia** | The specification and OpenCode profile in this repository. |
| **No silent success** | The invariant that a work item cannot reach `accepted` without satisfying its evidence manifest. |
| **Open question** | A question recorded by a `blocked` work item that has no recorded owner answer. |
| **OpenCode profile** | The repository configuration in `opencode.json` plus the agents, commands, and skills under `.opencode/`. |
| **Owner answer** | The reply to an open question from a person with the decision right, recorded in the trace and the work item; an acknowledgement is not an answer (`MYC-EXE-017`). |
| **Patch identity** | `git patch-id --stable` of the diff from the merge base to the branch head; equal identities mean the same change (`MYC-EXE-021`). |
| **Policy-as-code** | Machine-enforced rules that a prompt cannot override. In OpenCode these are `policies`, which are stricter than `permissions`. |
| **Provenance** | The record of which agent, model, prompt, policy, and rule version produced an artifact. |
| **Readiness assessment** | An evidence-based evaluation of a repository against the controls. It outputs a gap report and an autonomy ceiling. |
| **Recorded decision** | An implementation choice an agent made at R0-R2 and recorded with its evidence under `MYC-EXE-019`; it is not an open question. |
| **Risk tier** | One of R0 documentation, R1 tests and tooling, R2 normal feature or fix, R3 sensitive area such as auth, payments, schema, or infrastructure, or R4 critical or security-sensitive. |
| **ROI** | Return on investment: value delivered divided by total cost, including human time and incidents. |
| **Review rubric** | The dimensions and blocking thresholds used to judge a change consistently. |
| **Reward hacking** | Satisfying a metric or check without satisfying its intent, for example weakening a test to make it pass. |
| **Rule lifecycle** | The states of a rule (draft, active, deprecated, retired) and the process that moves it between them. |
| **Red teaming** | Adversarial testing that attempts to bypass policy, exfiltrate data, or abuse a tool. |
| **Release gate** | The set of evidence, security, provenance, and rollback checks that must pass before a release. |
| **Release record** | The auditable record of a release: version, commit, gates, rollback, decision, and timestamp. |
| **Rollback** | The tested path back to the previous state: revert, feature flag off, previous artifact, or data restore. |
| **Run state** | The durable record of a run: current state, attempt, commit, budget, checkpoints, and terminal state. |
| **Runtime contract** | The capabilities Mycelia requires from OpenCode, how each maps to a primitive, and what must be built around it. |
| **Sampling** | Reviewing a random, risk-weighted subset of changes instead of every change. |
| **Sandbox** | An isolated environment that contains the filesystem, network, process, and credentials available to a run. |
| **Schema** | A JSON Schema 2020-12 data contract for a Mycelia record or configuration. |
| **Selection map** | The versioned mapping from changed paths to the checks they affect, used by the fast gate. |
| **Secretless** | A design in which the agent never holds a long-lived secret; credentials are brokered per tool and expire quickly. |
| **Severity** | The review classification of a finding: blocker, major, minor, or nit. |
| **Sign-off** | The recorded human decision to accept a change, including what was reviewed and any conditions. |
| **Skip rule** | A named, configured rule that lets a required layer not run for a change and names its replacement evidence (`MYC-ASR-005`). |
| **SLI** | A service level indicator: a measured signal such as success rate or latency. |
| **SLO** | A service level objective: a target range for an SLI. |
| **SPACE** | A developer productivity framework: satisfaction, performance, activity, communication, and efficiency. |
| **Span** | A named interval in a trace, with a parent and correlation IDs. |
| **SLSA** | Supply-chain levels for software artifacts: source integrity, build provenance, and dependency verification. |
| **Stale base** | A branch base that the default branch has moved past in a way that matters to the change: a selected input, a release tag, or the age limit (`MYC-EXE-020`). |
| **Stale run** | An active run whose last heartbeat is older than the configured threshold. |
| **Supervisor** | The automated responder that answers permission requests in a headless run with deny or an escalation (`MYC-EXE-010`). |
| **Supply chain** | The models, providers, MCP servers, plugins, skills, packages, actions, and images that the factory depends on. |
| **Tag identity** | The rule that a release tag names one commit and is never moved or reused (`MYC-ASR-006`). |
| **Tamper-evident** | A property of a log where any modification or gap can be detected, for example with a hash chain. |
| **Task DAG** | A directed acyclic graph of tasks and dependencies used to partition concurrent work. |
| **Template** | The copyable Mycelia core: specs, schemas, profile, commands, and assessment. |
| **Test integrity** | The property that tests still fail when the behavior is wrong; it is protected by a test-diff guard, mutation testing, and review. |
| **Role contract** | The purpose, allowed actions, denied actions, tools, data classes, and escalation path of a role. |
| **Terminal state** | One of `accepted`, `rejected`, `blocked`, or `aborted`. Every work item ends in exactly one. |
| **Trace** | An append-only event record of actions, tool calls, decisions, evidence, and cost. |
| **Unit economics** | The cost and value of one unit of delivery, usually one accepted change. |
| **Verification stack** | The layered checks (static, unit, integration, end-to-end, mutation, security, performance, migration, docs, schema) that produce evidence. |
| **WIP limit** | A cap on the number of concurrent work items or runs, used to bound queue time and review load. |
| **Work cycle** | One pass of the runtime over its work items, started by the scheduler or an operator; it has an outcome record but no terminal state. |
| **Work item** | The unit of work: goal, acceptance criteria, non-goals, constraints, risk tier, and required evidence. |
| **Worktree** | An isolated Git working tree used to run concurrent work without collisions. |
