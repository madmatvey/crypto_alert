# 🎨🎨🎨 ENTERING CREATIVE PHASE: Architecture

## Component Description
End-to-end path to deliver alert-trigger events from Sidekiq worker to browser via Hotwire Turbo Streams and Stimulus.

## Requirements & Constraints
- No per-user accounts: single global stream ok
- Delivery should be at-most-once per trigger broadcast
- Keep server changes minimal; reuse Turbo Streams channel
- Payload must be serializable, small, and forward-compatible

## Options
1) Turbo::StreamsChannel broadcast_append_to("browser_notifications")
2) Custom ActionCable channel with JSON payload
3) DB-backed queue with periodic broadcast sweeper

## Analysis
- Turbo Streams
  - Pros: Zero custom channels; helpers; works with Turbo in views
  - Cons: Requires target container and small view partial or HTML string
- Custom ActionCable
  - Pros: Flexible event types
  - Cons: More boilerplate, testing complexity
- DB queue + sweeper
  - Pros: Retryable, durable
  - Cons: Overkill here; extra tables/processes

## Recommended Approach
Use Turbo Streams. Global stream key: `browser_notifications`. When `PriceCheckWorker` detects a trigger, server broadcasts an append to target `browser_notifications`. The appended node carries Stimulus values for title/body.

## Implementation Guidelines
- Stream name: `browser_notifications`
- Target element id: `browser_notifications`
- Payload shape
  - title: string (e.g., "Crypto Alert")
  - body: string (e.g., "#{alert.symbol} #{alert.direction} crossed #{alert.threshold_price} — current #{current_price}")
  - id: optional unique for dedup (e.g., `"alert-#{alert.id}-#{Time.now.to_i}"`)
- Server broadcast (concept)
  - Render small HTML snippet:
    - `<div data-controller="browser-notifications" data-browser-notifications-title-value="..." data-browser-notifications-body-value="..."></div>`
  - Use `Turbo::StreamsChannel.broadcast_append_to("browser_notifications", target: "browser_notifications", html: snippet)`
- Idempotency
  - Include a transient `data-id` and let controller ignore duplicates if same id seen in memory
- Security
  - Content only; no executable code in payload; escape values
- Testing
  - Stub broadcast and assert it is called when trigger fires

## Verification Checkpoint
- A single broadcast append results in one browser toast
- Stream and target names consistent
- No dependency on user sessions or cookies

# 🎨🎨🎨 EXITING CREATIVE PHASE
