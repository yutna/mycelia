# Evaluation and model change

Status: Draft

## 1. Purpose

A model or prompt change without an evaluation is a hope, not a decision. This
document defines the evaluation suite, the metrics, and the change process for
models, prompts, policies, and agent profiles.

## 2. What to evaluate

| Dimension | Question |
| --- | --- |
| Task success | Does the agent complete the work item? |
| Quality | Is the result correct, readable, and reversible? |
| Safety | Does it respect policy, secrets, and scope? |
| Evidence | Does it produce the required evidence? |
| Cost | Is the cost within the budget? |
| Latency | Is the feedback loop fast enough? |
| Tool use | Does it choose and call tools correctly? |

## 3. Evaluation suite

| Suite | Purpose | Size |
| --- | --- | --- |
| Smoke | Fast check on every change | 3-5 tasks |
| Golden | Representative work items | 10-50 tasks |
| Regression | Every escaped defect becomes a task | Growing |
| Adversarial | Prompt injection, policy bypass, secret access | 10-30 cases |
| Held-out | Optional, not visible to the agent | Small |

Task sources:

- real work items with acceptance criteria
- incidents and escaped defects
- synthetic tasks for edge cases
- adversarial cases from the threat model

Each task has a fixed input, an expected outcome, and a scoring method.

## 4. Metrics

| Metric | Meaning |
| --- | --- |
| pass@1 | The task passes on the first attempt |
| pass@k | The task passes within k attempts |
| rubric score | The review rubric result |
| evidence completeness | Required evidence present and verified |
| policy violations | Denied or blocked actions |
| cost | Cost per task |
| latency | Time per task |
| human intervention | Runs that need a human decision |

Thresholds:

- no regression on safety or policy
- pass rate within the agreed tolerance of the baseline
- cost within the agreed budget
- no new critical finding

## 5. Change process

1. **Define the subject.** Model, prompt, policy, or agent profile, with a
   version.
2. **Record the baseline.** The current version's metrics.
3. **Run the suite.** Smoke, golden, regression, and adversarial.
4. **Compare.** Pass rate, safety, evidence, cost, and latency.
5. **Decide.** Adopt, canary, reject, or roll back.
6. **Canary.** Run on low-risk work for a limited period.
7. **Roll out.** Expand only when the canary is stable.
8. **Monitor.** Watch the health metrics and the error budget.
9. **Roll back.** Revert to the baseline on a regression.

A model change without a baseline is not an evaluation.

## 6. Model routing

- Route low-risk work to a cheaper model when the evaluation supports it.
- Route R3 and R4 to a model with a current evaluation.
- Define a fallback for provider outages.
- Record the route in the trace.
- Do not route R3 or R4 to a model that has not passed the suite.
- Re-evaluate when the provider changes a model or a default.

## 7. Prompt and policy changes

A prompt or policy change follows the same process:

- version the change
- run the smoke, golden, and adversarial suites
- canary on low-risk work
- record the decision
- keep the previous version for rollback

A policy change that tightens access does not need a canary, but it needs a
negative test.

## 8. Evaluation record

The record contains:

- the suite and its version
- the subject type, ID, and version
- the baseline and its score
- the result: score, pass rate, cost, latency, regressions
- the decision: adopt, canary, reject, or rollback
- the timestamp

## 9. Anti-patterns

- Changing a model because it feels better.
- No baseline.
- A suite that never grows.
- A suite the agent can see and optimize for.
- A canary with no metric.
- A rollback path that was never tested.
- R3 or R4 on an unevaluated model.
- A prompt change with no version.

## 10. Data contract

- Schema: [schemas/evaluation-record.schema.json](../../schemas/evaluation-record.schema.json)
- Example: [examples/evaluation-record.example.yaml](../../examples/evaluation-record.example.yaml)

## 11. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [metrics-and-health.md](../50-observability/metrics-and-health.md) — metrics
- [provenance.md](../50-observability/provenance.md) — model provenance
- [verification-stack.md](../40-assurance/verification-stack.md) — checks
- [test-integrity.md](../40-assurance/test-integrity.md) — mutation
- [adversarial-and-resilience.md](../40-assurance/adversarial-and-resilience.md) — adversarial cases
- [release-and-rollback.md](../40-assurance/release-and-rollback.md) — rollback
- `rule-lifecycle.md` — rule change (planned)
- [docs/README.md](../README.md) — documentation map
