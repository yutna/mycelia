# Test integrity and mutation testing

Status: Draft

## 1. Purpose

A green check is worthless if the test was weakened. This document defines the
controls that prevent an agent from making a check pass by changing the test,
and the evidence that proves the tests can still fail.

## 2. Why tests are the target

Tests are the feedback loop. An agent under pressure can satisfy the loop
instead of the intent:

- delete a failing test
- skip a test
- loosen an assertion
- update a snapshot without review
- mock the behavior under test
- add a test-only branch
- lower a threshold
- retry until green

This is reward hacking. The control is test integrity.

## 3. Test weakening patterns

| Pattern | Example | Control |
| --- | --- | --- |
| Deletion | Remove a failing test | Test-diff guard and justification |
| Skip | `test.skip`, `it.only` | Lint and review |
| Assertion weakening | `expect(x).toBeDefined()` replaces a value check | Review and mutation |
| Snapshot churn | Blindly update a snapshot | Snapshot review |
| Mock-only | Mock the function under test | Review and integration test |
| Coverage gaming | Call code without asserting | Mutation and review |
| Test-only branch | Add a branch only the test reaches | Review and coverage |
| Threshold change | Lower a coverage or mutation gate | Policy and review |
| Retry as pass | Retry a flaky test until green | Flake policy |
| Self-approval | The author approves the test change | Separation of duties |

## 4. Controls

### Test-diff guard

- Tests are protected files.
- A change that modifies a test requires a justification in the pull request.
- The author cannot approve its own test change.
- A deletion requires a replacement or a recorded reason.
- A snapshot update requires a review of the diff.
- The verifier confirms the test change is justified.
- The guard is enforced by policy or CI, not by convention alone.

### Mutation testing

- Run mutation testing on the changed lines, not the whole repository.
- Record the mutation score, killed mutants, survived mutants, and equivalent
  mutants.
- Review every surviving mutant that is not equivalent.
- Set the threshold in the evidence manifest.
- A failed mutation gate is a failure, not a warning.

Suggested thresholds:

| Risk | Mutation score on changed lines |
| --- | --- |
| R1 | 60 percent |
| R2 | 70 percent |
| R3 | 80 percent |
| R4 | 85 percent plus manual review |

The thresholds are configurable; the manifest records the actual value.

### Property-based testing

- Use property-based tests for parsers, serializers, state machines, and
  invariants.
- Record the seed.
- Let the framework shrink a failure to a minimal case.
- Keep the failing case as a regression test.
- Property-based tests complement examples; they do not replace them.

### Changed-line coverage

- Gate on coverage of the lines changed by the work item.
- Use branch coverage where the language supports it.
- Do not gate on global coverage.
- Treat coverage as a signal; mutation is the stronger check.

Suggested thresholds:

| Risk | Changed-line coverage |
| --- | --- |
| R1 | 70 percent |
| R2 | 80 percent |
| R3 | 85 percent |
| R4 | 90 percent |

### Test quality heuristics

- One behavior per test.
- Arrange, act, assert.
- A meaningful assertion, not a truthiness check.
- No sleeps; use deterministic waits.
- No shared mutable state.
- A test name that states the behavior.
- A failure message that identifies the cause.
- A test that fails when the behavior is wrong.

### Held-out checks

A small set of checks can be held out of the agent's workspace and run only in
CI. This reduces the chance that the agent optimizes for the visible test. It is
optional, and the held-out set must still be reviewable by a human.

## 5. Test changes

A test change is allowed when:

- it adds coverage for a new behavior
- it reproduces a bug before the fix
- it replaces a flaky test with a deterministic one
- it removes a test for removed behavior

A test change is not allowed when:

- it makes a failing test pass without changing the product
- it weakens an assertion to match a bug
- it deletes a test to avoid a fix
- it hides a flake behind a retry

Every test change records the reason and the reviewer.

## 6. Flake policy

- A flaky test is a defect.
- Re-run once for diagnosis; do not retry until green.
- Quarantine the test with an owner and an expiry.
- Report a quarantined test as `blocked`, not `pass`.
- Track the flake rate.
- A high flake rate lowers the autonomy ceiling.

## 7. Report

Every test-integrity check records:

- the commit
- the mutation score and counts
- the changed-line coverage and branch coverage
- whether tests changed, and the justification
- the approver for a test change
- the verdict
- the trace event

## 8. Anti-patterns

- Deleting a failing test.
- Skipping a test.
- Loosening an assertion.
- Updating a snapshot without review.
- Mocking the behavior under test.
- Covering a line without asserting.
- Adding a test-only branch.
- Lowering a threshold.
- Retrying a flake until green.
- Self-approving a test change.

## 9. Data contract

- Schema: [schemas/test-integrity-report.schema.json](../../schemas/test-integrity-report.schema.json)
- Example: [examples/test-integrity-report.example.yaml](../../examples/test-integrity-report.example.yaml)

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — reward hacking
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [verification-stack.md](verification-stack.md) — checks
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [review-rubric.md](review-rubric.md) — review (planned)
- [docs/README.md](../README.md) — documentation map
