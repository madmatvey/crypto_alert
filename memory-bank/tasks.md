# Task: Crypto Alert Notification Service (specification.md)

## Description
Implement a Rails 8 application that lets a user create crypto price alerts, manage notification channels, and receive notifications when thresholds are crossed. Prices come from the Binance API. Background price checking must use Sidekiq (no ActiveJob usage in app code). Provide REST APIs and a minimal UI. Deliver with RSpec test coverage per the spec.

## Complexity
Level: 3
Type: Feature

## Technology Stack
- Framework: Rails 8
- Language: Ruby (from `.ruby-version`)
- Database: PostgreSQL
- Background jobs: Sidekiq + Redis (no ActiveJob usage in app code)
- Mail: ActionMailer
- HTTP client: Faraday
- Test: RSpec, Capybara, FactoryBot, Faker, Shoulda-Matchers
- Lint: RuboCop (rails-omakase)
- Frontend: Hotwire (Turbo, Stimulus)

## Technology Validation Checkpoints
- [ ] Gems added/installed: sidekiq, redis, rspec-rails, factory_bot_rails, faker, shoulda-matchers, faraday, sidekiq-cron
- [ ] Sidekiq configured (initializer, Redis URL), web UI available in development
- [ ] Hello-world Sidekiq worker runs
- [ ] RSpec installed and `bundle exec rspec` runs
- [ ] Mailer test adapter configured; config validated
- [ ] Ensure Solid Queue is not used for background jobs

## Status
- [x] Initialization complete
- [x] Planning complete
- [x] Creative complete
- [ ] Technology validation complete
- [ ] Implementation in progress

## Implementation Plan
1. Setup tests and background job infrastructure
   - Add required gems; bundle install
   - Install RSpec; configure Shoulda Matchers
   - Add Sidekiq initializer and config; verify worker runs
2. Data models and migrations
   - Create `Alert(symbol, direction, threshold_price, active:boolean)`; validations; enum for direction {up, down}
   - Create `NotificationChannel(kind, settings:jsonb, enabled:boolean)`; validations
   - Create `AlertNotification(alert_id, notification_channel_id, delivered_at)`
3. Services
   - `BinanceClient#get_price(symbol)` returning BigDecimal or nil
   - `PriceChecker#triggered?(alert, current_price)`
   - `NotificationDispatcher#dispatch(alert, current_price)`
     - Log channel: append to `log/alerts.log`
     - Email channel: send via ActionMailer
4. Sidekiq workers and scheduling
   - `PriceCheckWorker` checks a single alert and dispatches
   - `PollActiveAlertsWorker` enqueues checks for all active alerts
   - Configure periodic schedule via `sidekiq-cron` (every 1 min) for polling
5. API endpoints
   - Alerts: index, create, update, destroy
   - Channels: index, create, update, destroy
6. UI (Hotwire)
   - Alerts list + form; activate/deactivate toggle
   - Channels list + form; edit/delete
7. Testing
   - Model specs for validations and associations
   - Service specs for `BinanceClient`, `PriceChecker`, `NotificationDispatcher`
   - Request specs for Alerts and Channels APIs
   - Feature specs for basic UI flows
   - Stub external calls and mail delivery
8. Edge cases
   - Handle invalid symbols and API errors
   - Multiple alerts for the same symbol handled independently
   - Threshold crossed at creation: do not trigger immediately; only on subsequent crossing

## Creative Phases — Decisions
- Architecture (scheduling): sidekiq-cron every 1 minute; batch poller enqueues per-alert checks
  - See: `memory-bank/creative/creative-architecture-scheduling.md`
- Data Model (channel settings): JSONB + per-kind model validation (`log_file`, `email`)
  - See: `memory-bank/creative/creative-data-model-notification-channel-settings.md`
- UI/UX (forms and layout): Standard CRUD pages with Turbo enhancements; accessible forms
  - See: `memory-bank/creative/creative-uiux-alerts-and-channels.md`

## Dependencies
- sidekiq, redis, rspec-rails, factory_bot_rails, faker, shoulda-matchers, faraday, sidekiq-cron

## Challenges & Mitigations
- **Redis requirement**: document local setup and `REDIS_URL`; skip external Redis in CI by stubbing workers
- **Binance API reliability**: add error handling and retries; stub in tests
- **Email in dev/test**: use test delivery adapter, preview mailers
- **Concurrency and rate limits**: batch polling and reasonable schedule
