# Metrics and health

Status: Draft

## 1. Purpose

A factory that cannot measure itself cannot improve, cannot know when to stop,
and cannot tell whether it is getting safer or faster. This document defines
the metric domains, the health model, and the thresholds that trigger action.

## 2. Metric domains

| Domain | Question | Example metric |
| --- | --- | --- |
| Delivery | How fast and how often? | Lead time, deployment frequency |
| Quality | How often is it wrong? | Change failure rate, escaped defects |
| Trust | Can we rely on the evidence? | Evidence coverage, mutation score, false acceptance |
| Cost | What does it cost? | Cost per accepted change |
| Reliability | Does it keep working? | Run success rate, SLO burn |
| Developer experience | Is it sustainable? | Review time, intervention rate |
| Security | Are we exposed? | Open findings, time to remediate |
| Adoption | Is it working in practice? | Readiness score, autonomy ceiling |

## 3. Delivery metrics

The DORA metrics, adapted to the factory:

- **Lead time for changes**: from issue accepted to merged and released.
- **Deployment frequency**: releases per week.
- **Change failure rate**: accepted changes that cause an incident or rollback.
- **Failed deployment recovery time**: from failure detection to recovery.

A factory can be fast and unsafe. Pair delivery with quality and trust.

## 4. Productivity and developer experience

The SPACE framework:

- **Satisfaction and well-being**: survey, burnout signals.
- **Performance**: outcome quality, not output volume.
- **Activity**: runs, changes, reviews.
- **Communication and collaboration**: handoffs, review threads.
- **Efficiency and flow**: queue time, wait time, focus time.

Developer experience signals:

- feedback loop time (local and CI)
- cognitive load (number of tools, configs, steps)
- flow interruptions (approval queue, flaky checks)

## 5. Quality and trust metrics

| Metric | Definition |
| --- | --- |
| First-pass success | Runs that reach `accepted` without rework |
| Rework rate | Accepted changes that need a follow-up fix |
| Evidence coverage | Required evidence present and verified |
| Mutation score | Killed mutants divided by total mutants |
| Flake rate | Flaky checks divided by total checks |
| Escaped defect rate | Defects found after release |
| Human intervention rate | Runs that need a human decision |
| False acceptance rate | Accepted changes later found wrong |
| Override rate | Human decisions that reverse an agent decision |
| Review time | Time from ready to decision |

A rising false acceptance rate is a signal to lower the autonomy ceiling.

## 6. Cost metrics

- tokens per accepted change
- cost per accepted change
- cost per risk tier
- CI minutes per accepted change
- human review minutes per accepted change
- cost of rollback and incidents

Cost without attribution cannot be managed. Attribute to work item, role,
model, and provider.

## 7. Reliability metrics

| SLI | SLO example |
| --- | --- |
| Run success rate | 99 percent of runs reach a terminal state |
| Check latency | 95 percent of checks finish within the budget |
| Runtime availability | 99.9 percent monthly |
| Trace integrity | 100 percent of exported traces pass the chain check |

The error budget is the allowed failure. Burn rate alerts fire before the
budget is exhausted.

## 8. Security metrics

- open critical and high findings
- time to remediate
- secret-scan detections
- policy exceptions active and expired
- supply-chain components without a current review
- incidents in the period

## 9. Adoption metrics

- readiness score and autonomy ceiling
- distribution of accepted runs by risk tier
- percentage of work items with a complete manifest
- percentage of repositories using the profile
- time to first accepted change in a new repository

## 10. Health model

| Status | Signals | Action |
| --- | --- | --- |
| Healthy | SLOs met; error budget above 50 percent; no critical finding | Continue |
| Degraded | SLO burn; flake or intervention rising; budget below 25 percent | Investigate; reduce WIP or sample more |
| Unhealthy | SLO breach; security incident; evidence gap; budget exhausted | Lower the autonomy ceiling; stop R3/R4 |

The health status is a decision input, not a dashboard decoration. A degraded
or unhealthy status changes the autonomy ceiling.

## 11. Dashboards and cadence

| Audience | Content | Cadence |
| --- | --- | --- |
| Human owner | Health, risk, cost, incidents | Weekly |
| Operator | Runs, queues, failures, SLO burn | Daily |
| Reviewer | Queue, review time, false acceptance | Daily or weekly |
| Security | Findings, exceptions, supply chain | Weekly |
| Maintainer | Readiness, autonomy ceiling, rule changes | Monthly |

Review the trend, not only the point. A single green day is not a trend.

## 12. Anti-patterns

- Measuring activity instead of outcomes.
- Coverage as a goal.
- Cost with no attribution.
- An SLO with no action.
- A dashboard nobody reads.
- A metric that rewards gaming.
- No baseline before a change.
- A health model that never changes a decision.

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and ceiling
- [trace-and-audit.md](trace-and-audit.md) — trace
- [provenance.md](provenance.md) — provenance
- [verification-stack.md](../40-assurance/verification-stack.md) — checks
- [test-integrity.md](../40-assurance/test-integrity.md) — mutation
- [human-acceptance.md](../40-assurance/human-acceptance.md) — false acceptance
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — cost
- `economics.md` — cost model (planned)
- `incident-response.md` — incident (planned)
- [docs/README.md](../README.md) — documentation map
