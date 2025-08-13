# 🎨🎨🎨 ENTERING CREATIVE PHASE: Data Model

## Component Description
Add Telegram as a `NotificationChannel` kind with minimal settings and a simple notifier service.

## Requirements & Constraints
- Settings JSON must include `bot_token` and `chat_id`
- Avoid extra gems; use Faraday
- Sensitive data stored in DB for this demo; document security note
- Handle HTTP failures gracefully; do not crash worker

## Options
1) Store `bot_token` + `chat_id` in channel settings (DB)
2) Use Rails credentials/env vars and reference by key
3) Introduce `telegram-bot-ruby` gem

## Analysis
- DB settings
  - Pros: Simple UI; aligns with existing channel pattern
  - Cons: Secrets in DB; acceptable for demo
- Credentials/ENV indirection
  - Pros: Safer in prod
  - Cons: Higher complexity for this scope
- Gem
  - Pros: Convenience methods
  - Cons: Extra dependency

## Recommended Approach
Option 1: keep settings in JSON with validations; implement a small `TelegramNotifier` using Faraday to call `https://api.telegram.org/bot<token>/sendMessage`.

## Implementation Guidelines
- Model
  - Extend enum: add `telegram`
  - Validation: presence of `bot_token`, `chat_id` (string); basic format checks (digits for chat_id)
- Dispatcher
  - When `channel.telegram?`, build text via existing `build_message` and call `TelegramNotifier.send_message(token, chat_id, text)`
- Service
  - Endpoint: `POST https://api.telegram.org/bot#{token}/sendMessage`
  - Params: `{ chat_id:, text: }`
  - Timeouts, error handling: rescue network errors; log warning and return false
- UI
  - Update examples in channels form to include telegram JSON
- Tests
  - Stub Faraday; assert correct URL and params

## Verification Checkpoint
- Invalid settings rejected with clear validation errors
- Dispatcher path sends one HTTP request with expected payload
- Worker continues even if Telegram call fails

# 🎨🎨🎨 EXITING CREATIVE PHASE
