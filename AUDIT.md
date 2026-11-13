# Audit

Status: v1.0.0 audit

## 1. Purpose

The repository claims an evidence-based approach. It must audit itself with the
same standard. This document records the method, the findings, the
dispositions, and the limitations.

## 2. Scope and method

The audit covers the specification, the schemas, the examples, the OpenCode
configuration, and the repository workflow. It does not cover a runtime
implementation, because none is included.

Method:

1. Run the automated checks.
2. Walk the coverage crosswalk.
3. Compare the claims in the assurance case with the evidence.
4. Ask the adversarial questions from the threat model.
5. Record the findings and the dispositions.
6. State the limitations.

## 3. Checks performed

| Check | Result |
| --- | --- |
| Markdown lint | Pass |
| Local link check | Pass |
| Actionlint | Pass |
| OpenCode config schema | Pass |
| Schema meta-validation | Pass |
| Example validation | Pass |
| 12 original areas crosswalk | Complete |
| Tier 1 and Tier 2 keyword crosswalk | Complete |
| External framework crosswalk | Complete, informative |
| Adversarial questions | Answered in the threat model and test-integrity docs |

## 4. Findings

| ID | Severity | Finding | Disposition |
| --- | --- | --- | --- |
| `AUD-01` | Medium | `gh pr merge` reports a false branch-policy error on this ruleset | Fixed: the REST merge fallback is documented in `change-lifecycle.md` |
| `AUD-02` | Low | A low-severity `katex` advisory is in the dev dependency tree | Accepted: transitive, upstream; monitor Dependabot |
| `AUD-03` | Low | Planned documents were linked before they existed, failing the link check | Fixed: use code spans until the file exists; the link check caught it |
| `AUD-04` | Medium | No reference implementation is included | Accepted: the repository is a specification, not a runtime |
| `AUD-05` | Medium | No external human review of the specification | Open: schedule before `v1.0.0` or after a reference implementation |
| `AUD-06` | Medium | No production evidence | Accepted: the repository does not run a factory |
| `AUD-07` | Low | Some thresholds are illustrative and configurable | Accepted: the manifest records the actual value |
| `AUD-08` | Low | The EU AI Act mapping is informative | Accepted: it is not legal advice |
| `AUD-09` | Medium | OpenCode version drift can change behavior | Watch: the conformance checklist and the version review |
| `AUD-10` | Medium | The model provider is a trust boundary | Accepted: documented in the threat model and the system context |
| `AUD-11` | Medium | Approval fatigue is mitigated, not eliminated | Accepted: sampling, metrics, and audit |
| `AUD-12` | Medium | Trace and evidence storage depend on the implementation | Accepted: the runtime contract defines the requirement |
| `AUD-13` | Medium | The spec repository is not a runtime factory; its self-assessment ceiling is L0 | Accepted: by design; it demonstrates the model honestly |
| `AUD-14` | Low | No `CODEOWNERS` file | Fixed: `.github/CODEOWNERS` added |
| `AUD-15` | Low | No acceptance records for the spec repository itself | Accepted: single maintainer, specification-only |
| `AUD-16` | Low | No runtime trace or metrics for the spec repository | Accepted: the CI and git history are the trace |
| `AUD-17` | Medium | No external adversarial execution | Open: requires a reference implementation |
| `AUD-18` | Low | The self-assessment is not independent | Open: an independent assessor is required for a conformance claim |

## 5. Adversarial review

| Question | Answer |
| --- | --- |
| How could an agent satisfy the letter but not the intent? | Weaken tests, fabricate evidence, or bypass policy. The controls are the test-diff guard, the independent verifier, and the policy layer. |
| What evidence could be fabricated? | Test logs, review records, and coverage reports. The controls are hashes, commit binding, and an independent verifier. |
| Which failure would be silent? | A trace gap or stale evidence. The no-silent-success invariant and the trace integrity check address it. |
| Which human intervention remains? | R3 and R4 acceptance, policy changes, and incident command. |
| What if the model changes? | The evaluation suite, pinning, and canary. |
| What if an MCP server is malicious? | The allowlist, pin, review, and sandbox. |
| What if the repository has no tests? | The readiness assessment reports the gap; characterization tests come first. |
| What if the human rubber-stamps? | Sampling, review time, false-acceptance metrics, and audit. |
| What if the trace is tampered with? | The hash chain and, optionally, an external anchor. |
| What if the specification is wrong? | Governance, review, audit, and versioning. |

## 6. Self-assessment

This repository is assessed with its own model.

| Control | Score | Evidence |
| --- | --- | --- |
| `CTL-01` | 3 | README, mise, clean-clone CI |
| `CTL-02` | 2 | Work item schema and example |
| `CTL-03` | 3 | `.github/CODEOWNERS` |
| `CTL-04` | 3 | `AGENTS.md`, `CONTRIBUTING.md` |
| `CTL-05` | 2 | Skills and references reviewed |
| `CTL-06` | 2 | Compaction configured |
| `CTL-07` | 3 | Role contracts |
| `CTL-08` | 3 | Permissions and policies |
| `CTL-09` | 2 | Config only; no production bot identity |
| `CTL-10` | 3 | Policy red lines |
| `CTL-11` | 3 | Evidence manifest and schemas |
| `CTL-12` | 2 | Decision rights defined |
| `CTL-13` | 1 | No runtime loop in this repository |
| `CTL-14` | 2 | Protocol defined; no runtime drill |
| `CTL-15` | 1 | No runtime budget or kill switch |
| `CTL-16` | 1 | No concurrent runtime |
| `CTL-17` | 2 | Branch ruleset and merge flow |
| `CTL-18` | 2 | Rollback defined; no release artifact |
| `CTL-19` | 3 | CI checks |
| `CTL-20` | 1 | No mutation for documentation; not applicable |
| `CTL-21` | 2 | Review defined; single maintainer |
| `CTL-22` | 1 | No acceptance records for this repository |
| `CTL-23` | 1 | No runtime trace sink |
| `CTL-24` | 1 | No metrics or evaluations for this repository |

**Ceiling: L0.** The L1 gate requires `CTL-13` at 2 or higher; it is 1 because
this repository is a specification, not a running factory. The result is
honest by design. A reference implementation is needed before the repository
itself can claim L1 or above.

The self-assessment demonstrates the method, not a conformance claim.

## 7. Limitations

- The specification is not a certification.
- No reference implementation is included.
- No external human review has been completed.
- No production evidence exists.
- No legal review has been completed.
- The framework versions in the crosswalk change over time.
- A low-severity dev dependency advisory remains open.
- The model provider is outside the factory's control.
- No formal proof is claimed.
- Other harnesses are out of scope.
- The self-assessment is not independent.

## 8. Next audit

- After the `v1.0.0` freeze.
- After a reference implementation exists.
- After an incident or a near miss.
- Quarterly, with the concern radar.
- After a major OpenCode or framework change.

## 9. Related documents

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [GOVERNANCE.md](GOVERNANCE.md) — change process
- [coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md) — coverage
- [assurance-case.md](docs/70-adoption/assurance-case.md) — claims and evidence
- [readiness-assessment.md](docs/70-adoption/readiness-assessment.md) — assessment
- [docs/README.md](docs/README.md) — documentation map
