# Change lifecycle

Status: Draft

## 1. Purpose

This document defines how a change moves from an idea to a released artifact:
branch, commit, draft pull request, CI, review, acceptance, merge, release, and
observation. It also records the tooling quirks that a new clone will hit.

## 2. Lifecycle

| Stage | Gate | Owner | Artifact |
| --- | --- | --- | --- |
| Issue | Ready and in a version milestone | Human owner or maintainer | Issue |
| Branch | Named `<type>/<issue>-<slug>` from `main` | Implementer | Branch |
| Commit | Conventional Commits, small, focused | Implementer | Commit |
| Draft PR | Opened when work starts, linked to the issue | Integrator | Draft pull request |
| CI | `ci-ok` and `pr-check / check` pass | CI | Check results |
| Review | No blocking findings for R2+ | Reviewer | Review record |
| Acceptance | Approval by risk tier | Human owner | Acceptance record |
| Merge queue | CI on the merged result | Merge queue | Queue result |
| Merge | Squash, branch deleted | Integrator or human | Merge commit |
| Release | Milestone 100 percent, preflight passes | Maintainer | Tag and release |
| Observe | No regression in the window | Human owner | Observation record |

## 3. Branch and commit

- Branch from `main` as `<type>/<issue>-<slug>`.
- Use one branch per issue.
- Keep the branch short-lived.
- Commit in Conventional Commits form.
- Do not commit secrets, generated artifacts, or unrelated changes.
- Update the branch from `main` before the merge queue by merging `main` into
  it (§8); a force push is a red line.

## 4. Draft pull request

- Open the pull request as a draft when work starts.
- Use an empty commit if there is no change yet.
- Link the issue with `Closes #N`.
- Use the issue's milestone.
- Assign the pull request.
- Keep it draft until every required check is green.

A draft pull request is a coordination artifact, not a request for review.

## 5. CI gates

Every pull request runs:

- `ci-ok` — the gate that needs every other job
- `pr-check / check` — title, assignee, and version milestone
- markdownlint and link check
- schema and example validation
- OpenCode configuration validation
- actionlint when workflows change
- the evidence manifest for the change

A failed check is not a pass. A flaky check is quarantined, not retried until
green.

## 6. Review and acceptance

- R0 and R1: automated gates; human sampling.
- R2: independent review.
- R3: independent review and human acceptance.
- R4: human sign-off and security review.

The reviewer sees the diff, the work item, and the evidence, not the author's
private reasoning. The author does not approve its own change.

## 7. Merge queue and merge

- Merges are serialized through the merge queue.
- The queue runs CI on the merged result: the fast gate for R0-R2, unless a
  full-gate trigger applies, and the full gate for R3-R4
  ([verification-stack.md](../40-assurance/verification-stack.md) §12). The
  selection is computed against the queue base.
- The merge method is squash.
- The pull request title becomes the commit on `main`.
- The branch is deleted after the merge.
- A failed queue entry returns the change to `implementing` or `blocked`.

## 8. Base freshness

The merge queue tests the merged result. Before the queue, a branch can still
go stale: a check fails because the base is old, not because the change is
wrong, and the factory treats it as a product failure. This section defines
staleness, how a runtime updates a branch, and which evidence survives the
update.

Terms:

- The **base delta** is the set of paths changed on the default branch between
  the merge base the evidence was produced on and the merge base at the new
  head. A merge base is `git merge-base <default branch> <head>`; when there is
  more than one, nothing carries.
- The **change patch** is the diff from the merge base to the branch head. Its
  **patch identity** is `git patch-id --stable` of that diff.

Defaults (`maxBranchAge` and `maxBaseUpdates` in the `mycelia.yaml` runtime
section, [mycelia schema](../../schemas/mycelia.schema.json)):

| Setting | Default |
| --- | --- |
| Maximum branch age since the merge base | 7 days |
| Maximum runtime base updates per work item | 3 |

### `MYC-EXE-020` Stale base

- **Statement:** A branch is stale when the base delta contains a path that the
  selection map
  ([verification-stack.md](../40-assurance/verification-stack.md) §12) links
  to a check selected for the change, when a release tag was created on the
  default branch after the merge base, or when the merge base is older than
  the configured maximum age. When a gate fails on a stale branch, the runtime
  MUST update the branch and re-run the gate before it classifies the failure;
  the failure on the stale base is not evidence against the change. The
  runtime updates a branch by merging the default branch into it, without a
  force push, under an idempotency key (`MYC-EXE-003`). Each runtime update
  MUST count against the configured maximum in the durable budget ledger
  (`MYC-EXE-007`); an update that would exceed it MUST NOT start, and the loop
  run ends `aborted` as budget exhaustion. A re-run after an update the runtime
  made does not count against the full-gate budget (`MYC-ASR-004`). A merge
  conflict follows the merge-conflict class
  ([failure-and-ambiguity.md](failure-and-ambiguity.md) §2).
- **Rationale:** A stale base made a release check fail with "release already
  exists" on a dependency change that was fine; only an update was needed.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Update record with the staleness decision, its reasons, and the
  update key ([update-record](../../schemas/update-record.schema.json)); gate results before and after the update.
- **Verification:** Fixture `stale-base`: fail a gate on a
  stale base; check that the runtime updates and re-runs before classifying.
- **Failure mode:** The work item is `blocked` when the update cannot be made;
  ceiling lowered to L1 when stale-base failures are classified against the
  change.

### `MYC-EXE-021` Evidence after a base update

- **Statement:** Evidence is tied to the current commit. After a base update
  without a conflict, the run returns to `verifying`, not `implementing`. An
  automated check result MAY be carried from the earlier commit only when all
  of these hold: the patch identity at both commits is equal; each commit has
  exactly one merge base; the selection map at the new head computes a
  selection for the base delta and does not select the check; and the base
  delta touches no path in the change patch, no full-gate trigger path of
  `MYC-ASR-002` (build, CI configuration, lockfiles, toolchain, shared test
  infrastructure, the selection map, the skip rules), and no guard
  configuration. Every check selected for the base delta MUST re-run. When
  any condition fails, nothing carries. Skip records (`MYC-ASR-005`) are
  re-evaluated at the new head. A review record carries only when the patch
  identity is equal; otherwise a new review is needed. Acceptance at R0-R2 is a
  gate decision and is evaluated again at the new head; human acceptance for
  R3 and R4 MUST NOT carry. The merge queue still runs its gate on the merged
  result. A carried result MUST record the earlier and new commits, both merge
  bases, both patch identities, and the selection map version.
- **Rationale:** Re-running every check after every base update makes each
  update cost a full cycle; carrying results without proof lets a base change
  break the change unseen.
- **Applies to:** L2-L4; all risk tiers the runtime runs.
- **Evidence:** Carried result records ([carried-result](../../schemas/carried-result.schema.json)); re-run results
  for the base delta.
- **Verification:** Fixture `carry-over`: update a base
  with a delta that touches one selected input; check that exactly the
  selected checks re-run and the rest carry with their records; repeat with a
  changed patch identity, a delta that touches a trigger path or a path in the
  change patch, and more than one merge base, and check that nothing carries.
- **Failure mode:** A carried result without its record is missing evidence and
  the work item is `blocked`; ceiling lowered to L1 when results carry without
  the conditions.

## 9. Release

- A release is the close of a `vX.Y.Z` milestone at 100 percent.
- The release workflow tags the default branch and creates a GitHub Release.
- The release notes are generated from the merged pull requests.
- A preflight checks the version files when the repository has them.
- Tags follow tag identity
  ([release-and-rollback.md](../40-assurance/release-and-rollback.md)
  `MYC-ASR-006`).
- A publish job runs after the release when the project publishes artifacts.
- A release is not a synonym for a merge; the merge gate and the release gate
  are separate.

## 10. Observation

After the merge, observe the change for the agreed window:

- error rate and latency for a service
- test and flake rate for a repository
- user report for a documentation change
- cost for a model or provider change

A regression reopens the work item and triggers the failure protocol.

## 11. Rollback

Every R2 and above change has a rollback path:

- revert the squash commit or the pull request
- disable the feature flag
- deploy the previous artifact
- restore the data from a tested backup or migration
- record the rollback in the trace and the work item

A rollback is a normal operation, not a failure of the process. An untested
rollback is an untested control.

## 12. Break-glass

Emergency access is time-bound, owned, and recorded. It cannot disable the
trace or the evidence requirement for R3 and R4. The post-incident review
happens before the next release.

## 13. Tooling note

The GitHub CLI may report "base branch policy prohibits the merge" even when
the pull request is ready, the checks pass, and `mergeStateStatus` is `CLEAN`.
This is a CLI and ruleset interaction, not a real policy failure.

Verify the state first:

```sh
gh pr view <N> --json isDraft,mergeable,mergeStateStatus
```

If the pull request is not a draft and the state is `CLEAN`, merge through the
REST API:

```sh
gh api -X PUT repos/<owner>/<repo>/pulls/<N>/merge \
  -f merge_method=squash \
  -f commit_title="<title> (#<N>)"
```

Delete the branch if the API merge did not do it. Record the command and the
result in the pull request as evidence.

## 14. Verification

- A direct push to `main` is rejected.
- A draft pull request cannot merge.
- A pull request without a version milestone fails `pr-check`.
- A pull request with a non-conventional title fails `pr-check`.
- `ci-ok` fails when a job fails or is cancelled.
- The merge queue runs CI on the merged result.
- A milestone below 100 percent does not release.
- A rollback drill succeeds.
- Record the test output as evidence.

## 15. Anti-patterns

- Pushing directly to `main`.
- A pull request without an issue.
- A non-conventional title.
- Merging a draft.
- Merging with failing checks.
- Skipping review.
- A long-lived branch as the integration strategy.
- A release with no notes or no rollback plan.
- Treating a CLI error as a policy decision.

## 16. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [autonomous-loop.md](autonomous-loop.md) — state machine
- [failure-and-ambiguity.md](failure-and-ambiguity.md) — failure protocol
- [multi-agent-concurrency.md](multi-agent-concurrency.md) — merge queue
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [decision-rights.md](../20-control/decision-rights.md) — acceptance
- [AGENTS.md](../../AGENTS.md) — operating contract
- [CONTRIBUTING.md](../../CONTRIBUTING.md) — contribution guide
- `release-and-rollback.md` — release assurance (planned)
- [docs/README.md](../README.md) — documentation map
