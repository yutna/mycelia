# Principles

The principles explain the values behind the requirements. They are normative
guidance; the specific obligations live in the specification documents.

Each principle has four parts: the statement, the rationale, the implications,
and the anti-pattern it prevents.

## P1. No silent success

**Statement.** A work item MUST NOT reach `accepted` unless its evidence
manifest is satisfied.

**Rationale.** The most dangerous failure is a green check that does not mean
what it claims. Silent success destroys trust faster than a visible failure.

**Implications.** Every terminal state carries evidence and a trace. Missing,
stale, or self-certified evidence is a failure.

**Anti-pattern.** Marking a pull request ready because the agent says it is
done, without checking the evidence.

## P2. Evidence over claims

**Statement.** A claim without evidence is not done.

**Rationale.** Agents and humans can both be confident and wrong. Evidence is
the only thing a reviewer can inspect later.

**Implications.** Every requirement names the artifact that proves it and the
method that verifies it. The producer of evidence is not the only verifier.

**Anti-pattern.** A checklist that asks "did you test this?" instead of linking
the test result.

## P3. Least authority

**Statement.** Every role gets the smallest set of permissions that lets it do
its job.

**Rationale.** The blast radius of a mistake is proportional to the authority
of the actor.

**Implications.** Deny by default. Allow specific actions and resources. Use
OpenCode `policies` for red lines that a prompt cannot override.

**Anti-pattern.** Giving every agent `shell: *` and relying on the system
prompt to keep it safe.

## P4. Separation of duties

**Statement.** The actor that produces a change MUST NOT be the only actor that
verifies it when the risk tier requires independence.

**Rationale.** Correlated errors are the dominant failure mode when the same
model, context, and assumptions review their own work.

**Implications.** Use a different context, and for R3 and R4 a different model
or a human. The reviewer sees the evidence, not the author's reasoning.

**Anti-pattern.** The implementer marks its own pull request as reviewed.

## P5. Bounded autonomy

**Statement.** Every run has a step limit, a time limit, a cost budget, and a
stop condition.

**Rationale.** Unbounded loops turn a small mistake into a large bill or a
large blast radius.

**Implications.** The loop stops on ambiguity, policy conflict, repeated
failure, or budget exhaustion. A stop is a terminal state, not a retry.

**Anti-pattern.** "Keep going until it works" with no cost ceiling.

## P6. Artifact-mediated handoff

**Statement.** Roles hand off work through artifacts, not through a chain of
prompts.

**Rationale.** A prompt chain loses context, hides assumptions, and makes the
final decision impossible to audit.

**Implications.** Every handoff names its inputs, outputs, evidence, and open
questions. The work item, manifest, and trace are the shared memory.

**Anti-pattern.** Passing the previous agent's chat transcript to the next
agent and calling it coordination.

## P7. Reversibility

**Statement.** Every change has a rollback path before it is accepted.

**Rationale.** Autonomy without a way back is a one-way bet.

**Implications.** Use small changes, feature flags, canary releases, Git
revert, and OpenCode snapshots where appropriate. Record the rollback plan in
the acceptance packet.

**Anti-pattern.** A destructive migration with no dry run and no backup.

## P8. Observable by default

**Statement.** Every action that can change state emits a trace event.

**Rationale.** If it is not observed, it cannot be audited, debugged, or
improved.

**Implications.** Record the actor, role, model, prompt version, policy
version, tool call, input hash, output hash, cost, and parent event.

**Anti-pattern.** Logs only at the end of a run, with no tool-level detail.

## P9. Policy is code

**Statement.** A rule that matters is enforced by the runtime, not only written
in a document.

**Rationale.** A prompt can be ignored or overridden by untrusted content. A
runtime policy cannot.

**Implications.** Red lines live in OpenCode `policies`. Role rules live in
agent permissions. The readiness assessment checks that both are effective.

**Anti-pattern.** A `SECURITY.md` that says "do not push to main" while the
agent has an unrestricted shell.

## P10. Human oversight by risk

**Statement.** Human attention is allocated by risk tier, not by habit.

**Rationale.** Reviewing everything creates approval fatigue; reviewing nothing
creates unmanaged risk.

**Implications.** R0 and R1 can be sampled. R2 needs independent review. R3 and
R4 need human acceptance or sign-off. L4 still has human policy ownership.

**Anti-pattern.** A 100 percent manual review queue that everyone rubber-stamps.

## P11. Reproducibility

**Statement.** Given the same inputs and environment, the factory produces the
same evidence, or records why it could not.

**Rationale.** Evidence that cannot be reproduced is an anecdote.

**Implications.** Pin the runtime, model, prompt, policy, and dependencies.
Record environment hashes and variance. Flaky checks are defects.

**Anti-pattern.** "It passed on my machine" with no environment record.

## P12. Evolve through evidence

**Statement.** A rule, prompt, or model change is accepted only after an
evaluation shows it is safe.

**Rationale.** Intuition is not a regression test for an autonomous system.

**Implications.** Maintain a golden task suite. Run it before changing a model,
prompt, or policy. Feed incidents and escaped defects back into the suite.

**Anti-pattern.** Swapping the model because it feels better and hoping the
quality holds.

## P13. Use the runtime first

**Statement.** Build on the capabilities of OpenCode before adding a new
component.

**Rationale.** Every new component is another thing to secure, observe, and
maintain. OpenCode already provides agents, permissions, policies, sessions,
subagents, worktrees, snapshots, compaction, events, and an API.

**Implications.** Start with configuration, commands, and skills. Add a plugin
only for a capability the runtime does not provide. Keep the specification
OpenCode-specific.

**Anti-pattern.** Rebuilding an agent runtime, policy engine, or workflow engine
because it feels more controllable.

## P14. The repository is part of the system

**Statement.** A repository that the agent cannot understand is not ready for
autonomy.

**Rationale.** Most agent failures are context failures: missing commands,
hidden conventions, flaky tests, and undocumented ownership.

**Implications.** The readiness assessment scores repository legibility before
it scores the agent. The specification requires a repository map, a runnable
check command, and an ownership record.

**Anti-pattern.** Buying a better model to compensate for a repository with no
documentation and a slow, flaky test suite.
