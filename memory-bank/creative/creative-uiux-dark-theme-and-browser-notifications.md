# 🎨🎨🎨 ENTERING CREATIVE PHASE: UI/UX

## Component Description
Dark theme styled after Binance and on-device browser notifications for triggered alerts. Enhance readability, reduce glare, and deliver instant feedback without page reloads.

## Requirements & Constraints
- Use existing Rails 8 + Hotwire stack; avoid new CSS/JS frameworks
- Accessible color contrast (WCAG AA), keyboard focus states
- Browser Notifications API with graceful fallback if permission denied
- No user accounts: notifications broadcast globally
- Minimal DOM churn; efficient Turbo Streams integration

## Options
### Theme Options
1) CSS-only using variables in `app/assets/stylesheets/application.css`
2) Integrate TailwindCSS (gem) and utility classes
3) Bootstrap (gem) with dark theme

### Browser Notification Delivery
A) Turbo Streams append + Stimulus controller consumes and calls `new Notification()`
B) Custom ActionCable channel + bespoke JS consumer
C) Polling endpoint returning pending notifications

## Options Analysis
- CSS-only
  - Pros: Zero new deps, fast to implement, easy to review
  - Cons: Manual styling, less utility helpers
- Tailwind
  - Pros: Rapid iterations, utilities
  - Cons: Adds build/gem, config overhead
- Bootstrap
  - Pros: Components out-of-the-box
  - Cons: Heavier, opinionated, dep bloat

- Turbo Streams + Stimulus
  - Pros: Native to app, simple append → notify flow, no custom channels
  - Cons: Requires careful DOM targeting and idempotency
- Custom ActionCable
  - Pros: Flexible events
  - Cons: More code, duplicative beside Turbo Streams
- Polling
  - Pros: Simple
  - Cons: Latency, wasteful

## Recommended Approach
- Theme: CSS-only with CSS variables; use Binance palette
- Notifications: Turbo Streams append (global stream) + Stimulus controller that reads data-values and triggers Notification API; fallback to inline toast if permission denied

## Implementation Guidelines
- Colors
  - Background: #0B0E11
  - Surface: #1E2329
  - Text Primary: #EAECEF; Secondary: #B7BDC6
  - Accent (Binance Yellow): #F0B90B; Accent Hover: #C38E00
  - Border: #2B3139; Positive: #0ECB81; Negative: #F6465D
- CSS variables in `:root` and dark tokens applied to `body`
- Tables: zebra rows with low-contrast borders, hover highlight
- Buttons/links: accent background with high-contrast text, focus outlines
- Stimulus controller behavior
  - On connect: request `Notification` permission if default
  - When an element with `data-controller="browser-notifications"` appears (from stream append), read:
    - `data-browser-notifications-title-value`
    - `data-browser-notifications-body-value`
    - Show `new Notification(title, { body })`
    - Remove element after showing to avoid duplicate notifications
  - If permission denied: render an inline toast banner in the container
- Stream targets
  - Add `<turbo-cable-stream-source channel="Turbo::StreamsChannel" signed-stream-name="...">` via `turbo_stream_from "browser_notifications"`
  - Append nodes under a hidden container with id `browser_notifications`
- Copy
  - Title: "Crypto Alert"
  - Body: "BTCUSDT up crossed 65000 — current 65050" (format adjustable)

## Verification Checkpoint
- Contrast ratio >= AA on primary text
- Permission flows: default → prompt, granted → shows system toast, denied → inline toast
- Stream append triggers exactly one Notification per broadcast
- No console errors; graceful no-op in unsupported browsers

# 🎨🎨🎨 EXITING CREATIVE PHASE
