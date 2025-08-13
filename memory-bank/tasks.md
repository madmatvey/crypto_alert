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
- [x] Telegram HTTP call (Faraday) verified with stub
- [x] No additional gems required; config works in dev/test

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

## System Test Plan (Capybara + Selenium)

- Setup
  - Driver: Selenium with headless Chrome (Capybara) for `type: :system`
  - Include Turbo SystemTest helper: use `connect_turbo_cable_stream_sources` before asserting stream updates
  - Action Cable: `test` adapter (already configured); Rails 8 system tests defaults OK
  - Sidekiq: run inline within specific examples or stub dispatchers

- Scenarios
  - Alerts CRUD (UI)
    - Visit `alerts#index`, see table headers incl. "Current Price"
    - Create valid alert: BTCUSDT, verify show page and index row present
    - Create invalid alert: stub `BinanceClient#get_price` => nil; assert error "Symbol is invalid"
    - Update alert: toggle `active`, verify change persisted
    - Destroy alert: confirm removal from list
  - Current price display
    - Given alert with `last_price`, index shows number with 2 decimals
    - Trigger worker inline with stubbed price; refresh; updated `last_price` renders
  - Notification channels CRUD (UI)
    - Create `browser` channel via form JSON `{}`
    - Create `telegram` channel via form JSON `{ bot_token: 'TOKEN', chat_id: '123' }`
    - Update and delete channel via UI
  - Browser notifications broadcast (Turbo Streams)
    - On `alerts#index`, subscribe with `<%= turbo_stream_from "browser_notifications" %>`
    - Call a helper that simulates a trigger (invoke dispatcher or directly broadcast)
    - `connect_turbo_cable_stream_sources`; assert an element briefly appears in `#browser_notifications` then disappears
  - Telegram dispatch path (no network)
    - Stub `TelegramNotifier` to capture payload
    - Simulate dispatch (run `NotificationDispatcher`); assert called with expected text
  - Email dispatch (optional)
    - Create email channel; simulate dispatch; assert `ActionMailer::Base.deliveries.count` increments
  - Dark theme UI
    - Assert that layout nav uses `var(--surface)` background style and links have class `button`

- Files to create
  - `spec/system/system_setup_spec_helper.rb`: driver config, Turbo helper include
  - `spec/system/alerts_system_spec.rb`
  - `spec/system/notification_channels_system_spec.rb`
  - `spec/system/notifications_system_spec.rb` (Turbo + Telegram)
  - `spec/system/theme_system_spec.rb`

- Stubbing strategy
  - Use RSpec `allow_any_instance_of(BinanceClient).to receive(:get_price)` within examples that create alerts
  - Stub `TelegramNotifier` with instance double in system tests
  - For Turbo broadcasts, prefer running `NotificationDispatcher` with a fabricated alert; or directly call `Turbo::StreamsChannel.broadcast_append_to`

- Acceptance criteria
  - All system specs pass headless locally and in CI
  - No flakiness: use Capybara expectations with waiting behavior; call `connect_turbo_cable_stream_sources` before assertions
  - No external network calls during tests

## User Stories E2E Test Plan (Channels → Alerts → Notifications)

- Scope
  - Full flow from creating notification channels to receiving notifications when an alert threshold is crossed
  - Run with Capybara + Selenium (headless), Sidekiq inline where needed, and no external network

- Global Setup (per scenario where needed)
  - Create channels via UI: browser ({}), log_file({path:"log/alerts.log",format:"plain"}), email({to:"alerts@example.com"}), telegram({bot_token:"TOKEN",chat_id:"123"})
  - Ensure clean log file for assertions: truncate `log/alerts.log`

- Stories & Acceptance Criteria
  1) Create Channels (as user)
     - Visit Channels → New Channel; create Browser, Log file, Email, Telegram
     - Expect each to appear in Channels index and show page
  2) Create Valid Alert (as user)
     - Visit Alerts → New Alert; symbol BTCUSDT, direction Up, threshold 10000, active checked
     - Stub `BinanceClient#get_price` to any numeric to pass validation
     - Expect Alert row present on index
  3) Invalid Symbol Rejected (as user)
     - Stub `BinanceClient#get_price` => nil
     - Attempt to create alert; expect validation error "Symbol is invalid"
  4) Trigger Notifications (Up)
     - Given alert: last_price=9900, threshold=10000, direction=up, active=true
     - Stub `BinanceClient#get_price('BTCUSDT')` => 10000
     - Run `PriceCheckWorker.perform(alert.id)` (Sidekiq inline or direct call)
     - Expect:
       - `AlertNotification.count` increased by number of enabled channels
       - Log file appended with a line containing symbol and price
       - `ActionMailer::Base.deliveries.size` increased by 1
       - `TelegramNotifier` received `send_message` with expected text (stub instance)
       - `alert.last_price` updated to 10000
  5) Trigger Notifications (Down)
     - Given alert: last_price=10100, threshold=10000, direction=down, active=true
     - Stub current price => 10000; run worker
     - Expect same channel dispatch assertions as (4)
  6) Disabled Channel Not Notified
     - Disable one channel via UI; run trigger like (4)
     - Expect `AlertNotification` not created for disabled channel and no side-effect (e.g., no email added)
  7) Browser Notification Signal (pragmatic)
     - Because Stimulus removes the ephemeral node, verify via:
       - DB side-effect: `AlertNotification` created for `browser` kind
       - Optional: stub `Turbo::StreamsChannel.broadcast_append_to` and assert called once with expected target

- Files
  - `spec/system/user_stories/full_flow_system_spec.rb`

- Stubbing & Helpers
  - Binance: `allow_any_instance_of(BinanceClient).to receive(:get_price).and_return(BigDecimal('...'))`
  - Telegram: `allow(TelegramNotifier).to receive(:new).and_return(instance_double(...))`
  - Email: assert `ActionMailer::Base.deliveries`
  - Log: read from `Rails.root.join('log/alerts.log')`
  - Sidekiq: use `Sidekiq::Testing.inline!` within scenario blocks or call worker directly

- Non-flaky Strategy
  - Prefer assertions on persisted records (AlertNotification), mail deliveries, and file content over transient DOM for browser notifications
  - Use Capybara’s waiting matchers for UI steps; avoid racing with ActionCable by deferring UI assertions until after worker run
