# Memory Bank: Product Context

## User Stories
- As a user, I can create an alert with symbol, direction (up/down), and threshold price
- As a user, I can activate/deactivate and delete alerts
- As a user, I can add notification channels (log file, email) and enable/disable them
- As a user, I get notified when price crosses the threshold

## UX Expectations
- Simple lists and forms for alerts and channels
- Immediate feedback on validation errors
- Minimal navigation (alerts index as entry point)

## Operational Expectations
- Poll prices every minute
- Log notifications to `log/alerts.log`
- Send notification emails via ActionMailer (test adapter in test env)
