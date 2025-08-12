# 📄 Specification: Crypto Alert Notification Service

## 🧾 Overview
This document describes the expected behavior and test coverage for the **Crypto Alert Notification Service**, a fullstack Ruby on Rails application that allows users to:

1. Create price alerts for cryptocurrencies (e.g., BTCUSDT).
2. Receive notifications through multiple channels (log file, email, etc.).
3. Manage alert criteria and notification channels via Web UI.

No authentication or multi-user support is required. All prices are fetched from the Binance API.

---

## ✅ Expected Features and Behaviors

### 🔔 Alert Management
- Users can create an alert by specifying:
  - A valid crypto symbol (e.g., BTCUSDT).
  - A threshold price.
  - Direction: `up` (price goes above) or `down` (price goes below).
- Users can activate/deactivate alerts.
- System only allows valid Binance symbols.

### 📢 Notification Channels
- User can create, list, edit, and delete notification channels.
- Supported channel types:
  - Log File
  - Email (via ActionMailer)
- Future channels can be added easily (Telegram, Webhooks, etc.).

### ⚙️ Notification System
- System checks prices in background jobs (must be implemented via **Sidekiq**).
- On threshold breach, system sends a notification to all enabled channels for that alert.

---

## 🧪 Unit Tests (RSpec)

### Models
#### Alert
- [ ] Validates presence of `symbol`, `direction`, `threshold_price`
- [ ] Validates `direction` is either `up` or `down`
- [ ] Validates positive numeric `threshold_price`
- [ ] Has many alert_notifications

#### NotificationChannel
- [ ] Validates presence of `kind`
- [ ] Validates `settings` structure based on kind

#### AlertNotification
- [ ] Belongs to alert and channel

### Services
#### BinanceClient
- [ ] Returns correct price for valid symbols
- [ ] Raises error or returns nil for invalid symbols

#### PriceChecker
- [ ] Evaluates alert condition correctly for `up` and `down`

#### NotificationDispatcher
- [ ] Dispatches to all associated channels
- [ ] Supports email and log file channels

---

## 🔗 Integration Tests (RSpec request specs)

### Alerts API
- [ ] POST /alerts — creates a valid alert
- [ ] GET /alerts — lists existing alerts
- [ ] PATCH /alerts/:id — updates an alert
- [ ] DELETE /alerts/:id — deletes an alert

### Notification Channels API
- [ ] POST /channels — creates a notification channel
- [ ] GET /channels — lists user channels
- [ ] PATCH /channels/:id — updates settings
- [ ] DELETE /channels/:id — removes the channel

---

## 🧭 Feature Tests (Capybara + RSpec)

### Alerts UI
- [ ] User can visit alert index page and see list of alerts
- [ ] User can create a new alert via form
- [ ] User sees validation errors if input is invalid
- [ ] User can activate/deactivate alerts

### Notification Channels UI
- [ ] User can view and add notification channels
- [ ] User can remove or edit a channel

### Notification Flow
- [ ] When price crosses threshold, notification appears in log
- [ ] When price crosses threshold, email is sent

---

## 🧪 Edge Cases to Cover
- [ ] Non-existent or delisted symbols
- [ ] Network/API failure from Binance
- [ ] Multiple alerts for same symbol
- [ ] Alert threshold already crossed at creation

---

## 🛠 Recommended Tools and Setup
- **RSpec** for unit and integration tests
- **Capybara** for browser feature tests
- **FactoryBot** for test data
- **Faker** for dummy content
- **Shoulda-Matchers** for model validations

---

## 📦 Deliverables
- Complete Rails project with:
  - Tests passing via `bundle exec rspec`
  - Working notification logic
  - Basic UI for managing alerts and channels
  - Deployed GitHub repo with README and setup guide

---

## 🚧 Notes
- Background jobs must be implemented using **Sidekiq** (not ActiveJob).
- You are free to use Docker or not.
- External services (like email or Telegram) should be stubbed in tests.
- All specs should be runnable via `bundle exec rspec`.

