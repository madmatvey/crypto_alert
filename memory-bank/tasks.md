# Task: Browser & Telegram Notifications, Symbol Validation, Current Price, Dark Theme

## Description
Add browser notifications, Telegram message delivery, validate symbols via Binance before saving alerts, display current price for active alert symbols, and apply a Binance-styled dark theme.

## Complexity
Level: 3
Type: Feature

## Technology Stack
- Framework: Rails 8 (Hotwire: Turbo + Stimulus)
- Background jobs: Sidekiq + Redis
- Network: Faraday (Binance, Telegram)
- Realtime: Turbo Streams (ActionCable)
- Mail: ActionMailer
- Lint/Test: RuboCop, RSpec

## Technology Validation Checkpoints
- [x] Turbo Streams broadcast/subscribe path defined
- [x] Stimulus controller for Notification API hooked to stream target
- [ ] Telegram HTTP call (Faraday) verified with stub
- [ ] No additional gems required; config works in dev/test

## Status
- [x] Initialization complete
- [x] Planning complete
- [x] Creative complete
- [ ] Technology validation complete
- [ ] Implementation complete
- [ ] Reflection complete
- [ ] Archiving complete

## Implementation Plan
1) Notification channels
   - Extend `NotificationChannel` kinds: add `browser`, `telegram`
   - Validations:
     - `browser`: no extra settings
     - `telegram`: require `bot_token`, `chat_id`
   - Update form examples in `app/views/notification_channels/_form.html.erb`
   - Update `NotificationDispatcher` to support `:browser` and `:telegram`
   - Add `TelegramNotifier` service using Faraday
   - Add Turbo Stream broadcast for browser notifications

2) Symbol validation (Binance)
   - `Alert` model: `validate :binance_symbol_exists, on: :create` using `BinanceClient#get_price`
   - Error message: `symbol is invalid`

3) Current price display
   - Show `last_price` on `alerts#index` (add column to table and partial)
   - Ensure `PriceCheckWorker` persists `last_price` (already implemented)

4) Browser notifications UI
   - `alerts#index`: add `turbo_stream_from "browser_notifications"` and a target container with `data-controller="browser-notifications"`
   - Stimulus controller `browser_notifications_controller.js`:
     - Request `Notification` permission
     - On element connect, read `data-*` attributes and show `new Notification(title, { body })`, then remove element
   - Server: broadcast an append of a small `<div>` with the data attributes when an alert triggers

5) Dark theme
   - Update `app/assets/stylesheets/application.css` with dark palette (background #0B0E11, text #EAECEF, accent #F0B90B)
   - Style tables, buttons, links accordingly

6) Tests
   - `spec/services/telegram_notifier_spec.rb`: stub Faraday; expect POST to Telegram API
   - `spec/models/notification_channel_spec.rb`: validations for telegram/browser
   - `spec/models/alert_spec.rb`: symbol validation (stub BinanceClient)
   - `spec/services/notification_dispatcher_spec.rb`: dispatch routes for new kinds (stubs)

## Creative Phases Required
- UI/UX: Dark theme palette, button/table styling, notification behavior copy
  - Doc: memory-bank/creative/creative-uiux-dark-theme-and-browser-notifications.md
- Architecture: Naming for streams/Stimulus events (lightweight)
  - Doc: memory-bank/creative/creative-architecture-browser-notifications.md
- Data Model: Telegram channel settings and notifier
  - Doc: memory-bank/creative/creative-data-model-telegram-channel-settings.md

## Dependencies
- Reuse: Faraday, Turbo/Stimulus (no new gems)

## Challenges & Mitigations
- Browser notification permission may be denied: degrade gracefully (no-op)
- Telegram token handling in settings: document security note; avoid logging secrets
- Symbol validation costs a network call: perform only on create; stub in tests
