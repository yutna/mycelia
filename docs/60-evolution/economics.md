# Economics

Status: Draft

## 1. Purpose

Autonomy that is not economically sustainable is not autonomy. This document
defines the cost model, the unit economics, attribution, budgeting, the cost
levers, and the return on investment.

## 2. Cost categories

| Category | Examples |
| --- | --- |
| Model tokens | Input, output, cache read and write |
| Compute | Agent runtime, sandbox, build, test |
| CI minutes | Runner time, concurrency |
| Storage | Artifacts, traces, evidence |
| Human time | Review, acceptance, incident, policy |
| Incidents | Rollback, recovery, lost work |
| Tooling | Licenses, managed services |

A cost model that counts only tokens is not a cost model.

## 3. Unit economics

| Metric | Formula |
| --- | --- |
| Total cost | Tokens + compute + CI + storage + human + incidents |
| Cost per accepted change | Total cost divided by accepted changes |
| Cost per attempt | Total cost divided by attempts |
| Rework cost | Cost of rejected and revised runs |
| Cost per risk tier | Total cost for the tier divided by accepted changes in the tier |
| Human cost | Review minutes multiplied by the loaded hourly rate |
| ROI | Value delivered divided by total cost |
| Payback | Cost divided by monthly value |
| Autonomy value | Human minutes saved minus review, audit, and incident cost |

## 4. Attribution

Every cost record carries:

- work item
- role
- run and session
- model and provider
- repository and team
- risk tier
- timestamp

Attribution comes from usage events, the trace, and the cost record. A cost
without attribution cannot be managed or charged back.

## 5. Budgeting

- Per run, per day, and per month.
- Reserve a share for rollback and incident response.
- Alert at 50, 80, and 100 percent.
- Stop at the limit; do not retry on a new budget without a decision.
- Review the budget against the value and the risk tier.
- A budget that is never reached may be too high; a budget that is always
  reached may be a capacity problem.

## 6. Cost levers

- Route low-risk work to a cheaper model.
- Use prompt caching and batch requests.
- Keep the context small and relevant.
- Reduce unnecessary tool calls.
- Cache dependencies in CI.
- Use the smallest sandbox that meets the isolation requirement.
- Parallelize independent work.

Do not cut verification to reduce cost. The rework and incident cost is
usually larger.

## 7. Human cost

Human cost includes:

- review and acceptance time
- context switching
- approval queue waiting
- incident command
- policy and exception maintenance

A fast agent with a slow review queue is not a fast factory. Measure the queue
time, not only the run time.

## 8. ROI and value

Value can be:

- revenue from faster delivery
- cost avoidance from fewer incidents
- risk reduction from better evidence
- cycle time reduction
- quality improvement
- human time freed for higher-value work

Measure before and after. Include rework, incidents, and human time. An ROI
without a baseline is a guess.

## 9. Chargeback and showback

- Start with showback: report cost by team and work item.
- Move to chargeback when the attribution is stable.
- Allocate shared costs: runtime, CI, trace storage, human review.
- Review the allocation quarterly.
- Do not charge a team for a shared incident caused by the platform.

## 10. Capacity planning

- Estimate demand: work items per week by risk tier.
- Measure concurrency and queue time.
- Use the WIP limit and Little's law to size the system.
- Plan capacity for review and incident response, not only for agents.
- Revisit after a model or tool change.

## 11. Worked example

Illustrative numbers:

- 100 runs, 60 accepted.
- Model and compute: 1,200 USD.
- Human review: 10 hours at 50 USD per hour = 500 USD.
- Total: 1,700 USD.
- Cost per accepted change: 1,700 / 60 = 28.33 USD.

Compare with the baseline cost per change and the value delivered. The number
is only meaningful next to the baseline.

## 12. Anti-patterns

- Counting tokens but not human time.
- Ignoring rework and incidents.
- Cost per run without accepted changes.
- No attribution.
- Cutting verification to save money.
- A budget with no reserve.
- ROI with no baseline.
- Chargeback before the attribution is stable.

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [budgets-and-kill-switch.md](../20-control/budgets-and-kill-switch.md) — budgets
- [metrics-and-health.md](../50-observability/metrics-and-health.md) — metrics
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — usage events
- [human-acceptance.md](../40-assurance/human-acceptance.md) — human time
- [incident-response.md](incident-response.md) — incident cost
- [docs/README.md](../README.md) — documentation map
