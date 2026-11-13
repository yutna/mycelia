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
- Rebase on `main` before the merge queue.

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
- The queue runs CI on the merged result.
- The merge method is squash.
- The pull request title becomes the commit on `main`.
- The branch is deleted after the merge.
- A failed queue entry returns the change to `implementing` or `blocked`.

## 8. Release

- A release is the close of a `vX.Y.Z` milestone at 100 percent.
- The release workflow tags the default branch and creates a GitHub Release.
- The release notes are generated from the merged pull requests.
- A preflight checks the version files when the repository has them.
- A publish job runs after the release when the project publishes artifacts.
- A release is not a synonym for a merge; the merge gate and the release gate
  are separate.

## 9. Observation

After the merge, observe the change for the agreed window:

- error rate and latency for a service
- test and flake rate for a repository
- user report for a documentation change
- cost for a model or provider change

A regression reopens the work item and triggers the failure protocol.

## 10. Rollback

Every R2 and above change has a rollback path:

- revert the squash commit or the pull request
- disable the feature flag
- deploy the previous artifact
- restore the data from a tested backup or migration
- record the rollback in the trace and the work item

A rollback is a normal operation, not a failure of the process. An untested
rollback is an untested control.

## 11. Break-glass

Emergency access is time-bound, owned, and recorded. It cannot disable the
trace or the evidence requirement for R3 and R4. The post-incident review
happens before the next release.

## 12. Tooling note

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

## 13. Verification

- A direct push to `main` is rejected.
- A draft pull request cannot merge.
- A pull request without a version milestone fails `pr-check`.
- A pull request with a non-conventional title fails `pr-check`.
- `ci-ok` fails when a job fails or is cancelled.
- The merge queue runs CI on the merged result.
- A milestone below 100 percent does not release.
- A rollback drill succeeds.
- Record the test output as evidence.

## 14. Anti-patterns

- Pushing directly to `main`.
- A pull request without an issue.
- A non-conventional title.
- Merging a draft.
- Merging with failing checks.
- Skipping review.
- A long-lived branch as the integration strategy.
- A release with no notes or no rollback plan.
- Treating a CLI error as a policy decision.

## 15. Related documents

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
