# Changelog

Release notes for Mycelia. Each release lists added, changed, deprecated, and
removed requirements ([GOVERNANCE.md](GOVERNANCE.md)), with specification
changes and runtime changes in separate sections
([ADR-0001](docs/00-foundations/decisions/0001-scope-boundary.md)). Releases
before `v2.0.0` have generated notes only, on the GitHub Releases page.

## v2.0.0

A major release. Mycelia becomes a control-plane specification with a reference
runtime planned from `v2.1.0`. The runtime contract is normative, a repository
at L2 or higher must run on a conformant runtime, and the conformance kit
contract and fixtures define how a runtime proves it. This release ships no
runtime code, so the highest claimable level is L1 until a kit implementation
exists.

OpenCode: the minimum is 2.4.0. This release was tested with OpenCode 2.4.2.

### Specification

#### Breaking changes

- Scope boundary: Mycelia is a control-plane specification plus a reference
  runtime in `runtime/` from `v2.1.0`
  ([ADR-0001](docs/00-foundations/decisions/0001-scope-boundary.md)).
- `MYC-CORE-013` (added): a repository that claims L2 or higher must run on a
  conformant runtime, shown by a passing conformance result. A repository that
  claimed L2 under `v1.0.0` without one now has a ceiling of L1.
- Conformance profiles: the Standard profile, and so High-assurance, now
  requires a conformant runtime with a passing conformance result
  (`MYC-CORE-013`), as does autonomy level L2.
- Readiness L2 gate: adds `MYC-CORE-013` evidence and "no unproven red-line
  rule" ([guard-design.md](docs/20-control/guard-design.md) §7).
- `OC-01`: the minimum OpenCode version rises from 2.2.6 to 2.4.0
  ([ADR-0002](docs/00-foundations/decisions/0002-runtime-stack.md)). A
  repository on OpenCode 2.2.x or 2.3.x must upgrade before it claims
  conformance.
- `MYC-CORE-008` (semantic change): an implementation choice recorded under
  `MYC-EXE-019` is not an ambiguity. Only that decision class may be decided
  by an agent, at R0-R2 and within the fences of `MYC-EXE-019`; every other
  ambiguity still ends in `blocked`.
- `RunState.spec.checkpoints[].workItemVersion` is required. It is a version of
  the work item's contract fields: goal, acceptance criteria, non-goals,
  constraints, risk tier, data class, and affected areas. Recording open
  questions and answers does not change it.
- `MyceliaConfig` with an autonomy ceiling of L2 to L4 must set
  `runtime.heartbeatInterval`, `staleRunThreshold`, `acknowledgementExpiry`,
  `supervisorTimeout`, `notificationAdapter`, `escalationChain`, and
  `noProgressLimit`.
- `Evidence.result` gains the value `skipped`. A consumer that switches on the
  old three values must handle it.
- CLI contract ([cli-contract.md](docs/80-interface/cli-contract.md)): new exit
  code `7` (rejected); code `1` widened to "policy violation, or a stop or
  refused start by the kill switch"; a no-progress guard stop, and a work
  cycle that ends blocked-only or newly blocked (`MYC-EXE-016`), exit `3`.

#### Added requirements

Runtime contract ([opencode-runtime-contract.md](docs/30-execution/opencode-runtime-contract.md)
§7), refining `MYC-CORE-013`:

- `MYC-EXE-001` Durable run state and checkpoints
- `MYC-EXE-002` Resume from checkpoint
- `MYC-EXE-003` Idempotency keys
- `MYC-EXE-004` One active run per work item
- `MYC-EXE-005` Run start and heartbeat
- `MYC-EXE-006` Stale-run detection and restart
- `MYC-EXE-007` Budget across restarts (a per-work-item budget ledger linked
  from the run state)
- `MYC-EXE-008` Kill switch
- `MYC-EXE-009` Notification and escalation adapter
- `MYC-EXE-010` No waiting approvals in headless runs
- `MYC-EXE-011` Evidence collector
- `MYC-EXE-012` Durable trace sink
- `MYC-EXE-013` Policy placement and load check
- `MYC-EXE-014` Host isolation

Blocked and report semantics
([failure-and-ambiguity.md](docs/30-execution/failure-and-ambiguity.md) §11),
also refining `MYC-CORE-008`:

- `MYC-EXE-015` Progress and the no-progress guard
- `MYC-EXE-016` Blocked-only preflight
- `MYC-EXE-017` Owner answer and resume
- `MYC-EXE-018` Guards override prompts
- `MYC-EXE-019` Recorded implementation choices

Base freshness ([change-lifecycle.md](docs/30-execution/change-lifecycle.md)
§8), also refining `MYC-CORE-005`:

- `MYC-EXE-020` Stale base
- `MYC-EXE-021` Evidence after a base update

Guard design ([guard-design.md](docs/20-control/guard-design.md) §5), refining
`MYC-CORE-003` and `MYC-CORE-009`:

- `MYC-CTL-001` Normalize before matching
- `MYC-CTL-002` Exact allow-lists
- `MYC-CTL-003` Bypass corpus per rule
- `MYC-CTL-004` Exact-count guard canaries
- `MYC-CTL-005` Meta-check
- `MYC-CTL-006` Loosening a guard

Supply chain ([supply-chain.md](docs/20-control/supply-chain.md) §12):

- `MYC-CTL-007` Dependency update risk tier

Verification tiers ([verification-stack.md](docs/40-assurance/verification-stack.md)
§12) and release:

- `MYC-ASR-001` Fast gate
- `MYC-ASR-002` Full gate
- `MYC-ASR-003` N-1 compatibility on release branches
- `MYC-ASR-004` Full-gate run budget
- `MYC-ASR-005` Skip rules and replacement evidence
- `MYC-ASR-006` Tag identity
  ([release-and-rollback.md](docs/40-assurance/release-and-rollback.md) §4)

Conformance kit ([conformance-kit.md](docs/70-adoption/conformance-kit.md)),
refining `MYC-CORE-013`:

- `MYC-INT-001` Conformance command (`mycelia conformance`)
- `MYC-ADP-001` Valid conformance result
- `MYC-ADP-002` Kit coverage (the meta-check also checks record kinds and case
  profiles)

#### Added (non-breaking)

- ADR-0001 (scope boundary) and ADR-0002 (runtime stack: TypeScript, vendored
  object-oriented design skills, client generated from the pinned OpenCode
  release).
- The guard-design standard, with the enforcer register.
- 25 conformance fixtures in `conformance/fixtures/`, with the
  `conformance-fixture` and `conformance-result` schemas.
- 16 record schemas: `IdempotencyRecord`, `BudgetLedger`, `KillSwitchRecord`,
  `NotificationRecord`, `OwnerAnswerRecord`, `ReplyRecord`, `WorkCycleRecord`,
  `RecordedDecision`, `ConfigurationDefect`, `GapRecord`, `LoadCheckRecord`,
  `RuntimeEnvironmentRecord`, `SelectionMapDefect`, `UpdateRecord`,
  `CarriedResult`, and `DependencyTierRecord`.
- `mycelia.yaml`: `verification`, `dependencies`, and `rules` sections.
- `Evidence.gate`; `RunState` `lease`, `heartbeat`, `startedBy`, and
  `budgetLedgerRef`.
- `WorkItem.spec.openQuestions`: the work item's home for the ambiguity
  protocol; each entry has a required `owner`.
- The `mycelia conformance` command in the CLI contract.
- Worked example §9: one work item from intake through `blocked` and an owner
  answer to `accepted`, with 26 records in `examples/worked-example/`,
  validated by `scripts/check-worked-example.sh`.
- The OpenCode reference notes (non-normative).
- Glossary terms for the new concepts.

#### Changed (non-breaking)

- Schema durations are ISO 8601 (`PT5M`, `P7D`).
- Fixture record kinds: `LeaseRecord` became `RunState`; `SkipRecord` became
  `Evidence`.

#### Deprecated and removed

None.

#### Deferred to v2.1.0

- Tighten the fixture `given` sub-objects with the reference runtime.
- Consider a dedicated `TraceEvent` type for notifications; today notify,
  reply, and answer are `state` events and the notification record is primary.

### Runtime

No runtime code in this release. The reference runtime and the executable
conformance kit start in `runtime/` in `v2.1.0`.

### Migration from v1.0.0

1. Upgrade OpenCode to 2.4.0 or newer and record the version (`OC-01`).
2. If you claim L2 or higher, or the Standard or High-assurance profile, lower
   the claim to L1 and the Minimal profile until you have a conformant runtime
   and a passing conformance result (`MYC-CORE-013`).
3. In `mycelia.yaml`, if the autonomy ceiling is L2 to L4, set the required
   `runtime` loop settings listed above.
4. In run-state records, add `workItemVersion` to every checkpoint.
5. In evidence consumers, handle `Evidence.result: skipped`; never treat it as
   `pass`.
6. In CLI wrappers, handle exit code `7` and the widened meaning of `1`; expect
   `3` for a no-progress guard stop and a blocked-only or newly blocked cycle.
7. Write durations in ISO 8601.
8. Move the rules registry into the `rules` section of `mycelia.yaml`, with an
   `enforcer` for each rule
   ([guard-design.md](docs/20-control/guard-design.md) §8).
9. Review your policies against the guard-design standard: an unproven
   red-line rule blocks the L2 gate.
10. Re-run the readiness assessment and issue a new conformance claim.
