# Budgets and kill switch

Status: Draft

## 1. Purpose

Autonomy without a budget is an availability and cost risk. This document
defines the budget dimensions, ownership, enforcement, cost attribution, the
kill switch, and the drills that prove both work.

## 2. Budget dimensions

| Dimension | Unit | Example limit |
| --- | --- | --- |
| Tokens | Input and output tokens | 2 million per work item |
| Cost | USD | 20 USD per work item, 500 USD per month |
| Wall-clock time | Minutes | 60 minutes per run |
| Model steps | Steps | 30 per role |
| Tool calls | Calls | 200 per work item |
| CI minutes | Minutes | 60 per work item |
| Concurrency | Runs | 4 per repository |
| Storage | Bytes | 1 GiB of evidence per release |
| Human review | Minutes | 30 per R3 change |

## 3. Ownership

| Budget | Owner | Recorded in |
| --- | --- | --- |
| Per run | Work item | Work item and trace |
| Per role | Role contract | Role contract and policy |
| Per repository | Human owner | Repository policy |
| Per day or month | Human owner | Usage dashboard |
| Per incident | Incident commander | Incident record |

The agent cannot raise its own budget. A budget change is a decision with an
owner and a record.

## 4. Enforcement

- Set `steps` on every agent.
- Set a wall-clock limit on the runner and on long commands.
- Use provider usage limits and workspace budgets where available.
- Set CI `timeout-minutes` and concurrency limits.
- Use a budget guard in the runtime or a plugin that reads usage events.
- Stop at the limit; do not continue on a warning.
- Keep a reserve for rollback and incident response.

A limit that is not enforced is a wish, not a budget.

## 5. Cost attribution

Every usage record carries:

- work item ID
- role
- session
- model and provider
- input and output tokens
- cost
- tool calls
- CI minutes

This makes it possible to compute the cost per accepted change, per risk tier,
and per role. Cost without attribution cannot be managed.

## 6. Model routing and caching

- Route low-risk work to a cheaper model when the evaluation suite supports it.
- Route R3 and R4 to a model with a current evaluation.
- Define a fallback for provider outages.
- Use prompt caching and batch requests where the provider supports them.
- Do not route R3 or R4 to a model that has not passed the evaluation.
- Record the routing decision in the trace.

## 7. Budget exhaustion

Budget exhaustion is an `aborted` terminal state:

- record the dimension, the limit, and the consumed amount
- preserve the work and the trace
- do not retry automatically
- do not switch to an unbudgeted model
- let a human decide whether to raise the budget
- if the change is incomplete, leave the branch in a safe state

A retry after exhaustion without a new decision is a policy violation.

## 8. Kill switch

The kill switch stops a run or a whole repository.

Triggers:

- budget exhaustion
- security incident
- policy violation
- runaway loop
- unexpected data exfiltration
- compromised MCP server, plugin, or skill

Actions:

1. Interrupt the session.
2. Revoke the session credentials.
3. Disable the compromised component.
4. Stop the runner.
5. Preserve the trace and evidence.
6. Roll back the change or the release.
7. Record the incident.

The kill switch cannot be disabled by an agent. It must be reachable without a
deployment.

## 9. Alerts

- Warn at 50 percent, page at 80 percent, stop at 100 percent.
- Alert on a cost spike, a token spike, or an unusual tool-call pattern.
- Route alerts to the owner of the budget.
- Include the work item, role, model, and trace link.
- Review alerts weekly; a noisy alert is a defect.

## 10. Drills

Run at least quarterly:

- simulate budget exhaustion and verify the `aborted` state
- trigger the kill switch and measure time to stop
- verify that credentials are revoked
- verify that the trace and evidence survive
- verify that the rollback works
- record the drill result as evidence

A kill switch that has never been tested is not a control.

## 11. Anti-patterns

- No budget at all.
- A per-run budget with no monthly cap.
- Retrying after exhaustion.
- An agent raising its own budget.
- A kill switch that requires a release.
- No cost attribution.
- Model routing without evaluation.
- Alerts with no owner.
- A drill that only checks the dashboard.

## 12. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [threat-model.md](../00-foundations/threat-model.md) — denial of service
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- [policy-as-code.md](policy-as-code.md) — policy model
- [evidence-manifest.md](evidence-manifest.md) — evidence
- [decision-rights.md](decision-rights.md) — oversight
- [sandbox-and-isolation.md](sandbox-and-isolation.md) — isolation
- `economics.md` — cost model (planned)
- `metrics-and-health.md` — usage metrics (planned)
- `incident-response.md` — containment (planned)
- [docs/README.md](../README.md) — documentation map
