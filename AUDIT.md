# Audit

Status: Draft

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

## 5. Limitations

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

## 6. Next audit

- Before the `v1.0.0` freeze.
- After a reference implementation exists.
- After an incident or a near miss.
- Quarterly, with the concern radar.
- After a major OpenCode or framework change.

## 7. Related documents

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [GOVERNANCE.md](GOVERNANCE.md) — change process
- [coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md) — coverage
- [assurance-case.md](docs/70-adoption/assurance-case.md) — claims and evidence
- [readiness-assessment.md](docs/70-adoption/readiness-assessment.md) — assessment
- [docs/README.md](docs/README.md) — documentation map
