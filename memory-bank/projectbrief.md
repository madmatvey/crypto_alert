# Memory Bank: Project Brief

## Goal
Ship a Rails 8 app that lets a single user create crypto price alerts and receive notifications (log and email) when thresholds are crossed. Fetch prices from Binance. Provide REST endpoints and a minimal UI. Deliver with passing RSpec tests.

## Scope
- Alerts CRUD and activation toggle
- Notification channels CRUD (log, email)
- Background polling + dispatch via Sidekiq every minute
- Minimal UI using Hotwire
- Test suite (models, services, requests, features)

## Constraints
- Use Sidekiq (not Active Job) for app background logic
- PostgreSQL DB
- Email via ActionMailer (test adapter for specs)
- External API calls must be stubbed in tests

## Non-goals (initial)
- Multi-user authentication
- Advanced channels (Telegram, webhooks)
- Sophisticated UI styling
