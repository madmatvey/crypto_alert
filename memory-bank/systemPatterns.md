# Memory Bank: System Patterns

## Architecture
- MVC Rails app with service objects for external APIs and dispatching
- Background processing with Sidekiq workers (no Active Job for app jobs)
- Periodic polling via cron-like schedule (`sidekiq-cron`)
- Decoupled notification dispatchers per channel

## Modules
- Services: `BinanceClient`, `PriceChecker`, `NotificationDispatcher`
- Workers: `PollActiveAlertsWorker`, `PriceCheckWorker`
- Mailers: `AlertMailer`
- Models: `Alert`, `NotificationChannel`, `AlertNotification`

## Data Flow
1. `PollActiveAlertsWorker` runs every minute → loads active alerts
2. For each alert → enqueue `PriceCheckWorker(alert_id)`
3. `PriceCheckWorker` fetches price via `BinanceClient`, evaluates using `PriceChecker`
4. If triggered → `NotificationDispatcher` fan-out to enabled channels

## Error Handling
- Network timeouts and retries in `BinanceClient`
- Sidekiq retries for transient failures; log dead jobs via `default_retries_exhausted`
- Mailer uses `deliver_now` inside workers to avoid Active Job indirection

## Extensibility
- New channel = new dispatcher and validation in `NotificationChannel.settings`
- New symbol source = implement alternate client; keep `PriceChecker` unchanged
