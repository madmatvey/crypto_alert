# 🎨 CREATIVE PHASE: ARCHITECTURE — Scheduling & Polling Cadence

🎨🎨🎨 ENTERING CREATIVE PHASE: ARCHITECTURE 🎨🎨🎨

## Problem Statement
Define how the system polls Binance prices and triggers notifications: scheduling strategy, polling cadence, worker design, concurrency, and idempotency.

## Requirements & Constraints
- Must use Sidekiq for background execution
- Poll active alerts regularly and scale to dozens/hundreds of alerts
- Avoid excessive load and unnecessary API calls
- Idempotent and safe re-runs; handle retries
- Easy to operate and test

## OPTIONS ANALYSIS

### Option 1: Cron-driven batch poller (sidekiq-cron every 1 min)
Description: Use `sidekiq-cron` to run `PollActiveAlertsWorker` every minute. It loads active alerts and enqueues one `PriceCheckWorker` per alert.
Pros:
- Simple, explicit schedule; easy ops and monitoring
- Scales horizontally with worker concurrency
- Clear separation of scheduling vs work execution
- Works well with Redis-backed Sidekiq
Cons:
- 1-minute granularity by default (near-real-time, not instant)
- Requires cron gem and Redis availability
Complexity: Low
Implementation Time: Short

### Option 2: Self-scheduling worker (recursive enqueue)
Description: `PollActiveAlertsWorker` schedules itself at the end of each run with `perform_in`.
Pros:
- No extra gem; flexible cadence per environment
- Can adapt next run based on workload
Cons:
- Harder to reason about drift and overlaps
- Failure modes can pause scheduling silently
- Requires careful locking to avoid duplicate chains
Complexity: Medium
Implementation Time: Medium

### Option 3: Event-driven via exchange stream (WebSockets)
Description: Subscribe to Binance price streams; evaluate alerts on incoming ticks.
Pros:
- Near real-time
- Potentially fewer redundant checks
Cons:
- Outside current scope; heavier infra & complexity
- Requires robust reconnect/backoff logic and per-symbol subscriptions
- Spec expects periodic checks; overkill initially
Complexity: High
Implementation Time: High

## Decision
Choose Option 1: cron-driven batch polling every 1 minute via `sidekiq-cron`.
Rationale: Matches spec expectations, simple, reliable, scalable enough. Can evolve later if requirements change.

## Implementation Plan
1) Define workers
- `PollActiveAlertsWorker`: query active alerts, enqueue `PriceCheckWorker` for each alert id
- `PriceCheckWorker(alert_id)`: fetch price, evaluate, dispatch if triggered; idempotent per run

2) Scheduling (initializer)
- Register `PollActiveAlertsWorker` with `sidekiq-cron` at `* * * * *`

3) Concurrency & pooling
- Set `RAILS_MAX_THREADS` (e.g., 10) and align DB pool
- Keep `PriceCheckWorker` lightweight; external calls with timeouts

4) Idempotency & rate control
- Each run evaluates current price only; no state mutation unless triggering
- Add short network timeouts and retries in `BinanceClient`
- Optionally use a simple limiter if API rate limits are hit

5) Edge case: alert created when already crossed
- Do NOT trigger immediately upon creation; only on subsequent crossing after creation timestamp
- Implementation: store `created_at`; `PriceChecker` compares previous vs current condition or uses threshold crossing logic (see Algorithm decision in future if needed)

6) Observability
- Log poll cycles and counts; add Sidekiq Web UI for monitoring

## Verification
- Meets 1-minute cadence requirement; scalable by worker threads
- Resilient to failures via Sidekiq retries
- Testability: workers unit-tested; cron presence verified in initializer spec

🎨🎨🎨 EXITING CREATIVE PHASE — DECISION MADE 🎨🎨🎨
