# Crypto Alert — Rails 8

A Rails 8 application that watches crypto prices like a hawk and sends notifications when your favorite coins cross your price thresholds. Think of it as a personal crypto butler that never sleeps (thanks to Sidekiq). Built with modern Rails patterns, comprehensive testing, and a dash of developer-friendly humor.

## What It Does

### 🚨 Alerts
Create price alerts for any crypto pair on Binance. Set thresholds, choose direction (up/down), and let the app do the heavy lifting. No more staring at charts like a zombie!

![alerts_screen](public/alerts_screen.png)

### 🔔 Notifications
Multiple notification channels to keep you informed:
- **Email**: Old school but reliable
- **Telegram**: Because who doesn't love getting crypto alerts while chatting?
- **Browser**: Instant desktop notifications (with proper user consent, of course)
- **Log files**: For the paranoid who want to keep records of everything

### ⚡ Background Processing
Sidekiq workers handle all the heavy lifting, so your app stays responsive. No more blocking requests while waiting for API calls!

![sidekiq_workers_screen](public/sidekiq_workers_screen.png)

### 🧪 Testing
Comprehensive test suite with Capybara + Selenium. Because nothing says "I care about quality" like 49 passing tests and 0 failures.

![screencast_tests](public/screencast_tests.gif)

## Development Approach

### Architecture Philosophy
This app follows the "thin controllers, fat services" mantra (with a side of "models should be models, not Swiss Army knives"). Business logic lives in service objects, background jobs handle async work, and controllers just handle HTTP concerns.

### Key Patterns
- **Service Objects**: `NotificationEnqueuer`, `NotificationMessageBuilder`, `Alerts::SymbolValidator` - because sometimes you need more than just a model
- **Sidekiq Workers**: Each notification type gets its own worker. Separation of concerns, baby!
- **Comprehensive Testing**: RSpec, Capybara, system tests - we test everything except the coffee machine
- **Error Handling**: Graceful degradation when APIs are having a bad day

### Code Quality
- **RuboCop**: Because consistent code is happy code
- **Brakeman**: Security first, crypto second
- **Comprehensive specs**: 49 examples, 0 failures, 1 pending (because browser notifications are ephemeral little creatures)

## Prerequisites
- Ruby 3.4.x (because we're not savages using old Ruby versions)
- PostgreSQL 14+ (for storing all those precious alerts)
- Redis 6+ (Sidekiq's best friend)

## Setup
```bash
bundle install
bin/rails db:prepare
```

Start Redis locally:
```bash
redis-server
```

### Environment Variables
Recommended ENV variables (development defaults are fine, but you do you):
- `REDIS_URL` (default: `redis://localhost:6379/0`)
- `ALERTS_FROM` (default: `alerts@example.com`)

## Running
```bash
bin/rails server
```

Visit:
- **App**: http://localhost:3000
- **Sidekiq UI** (dev): http://localhost:3000/sidekiq - watch your background jobs do their thing!

## Background Jobs & Scheduling
- **Workers**: `PriceCheckWorker`, `PollActiveAlertsWorker` - the unsung heroes
- **Cron**: Configured via `config/sidekiq_schedule.yml` (runs poller every minute, because crypto never sleeps)
- **Sidekiq/Redis**: Properly configured in `config/initializers/sidekiq.rb`

## API
JSON endpoints for all your programmatic needs:
- **Alerts**: `GET/POST /alerts(.json)`, `PATCH/DELETE /alerts/:id(.json)`
- **Channels**: `GET/POST /notification_channels(.json)`, `PATCH/DELETE /notification_channels/:id(.json)`

## UI Features
- **Turbo Streams**: Live updates without the JavaScript headache
- **Structured Forms**: No more JSON textareas for channel settings (we're civilized now)
- **Dark Theme**: Binance-inspired design because light themes are so 2020
- **Validation**: Real-time symbol validation via Binance API

## Testing
```bash
bundle exec rspec -f d
```

Our test suite includes:
- **Unit specs**: For all the service objects and models
- **Integration specs**: For the notification flow
- **System specs**: Full user journeys with Capybara + Selenium
- **Worker specs**: Because background jobs need love too

## Linting
```bash
bin/rubocop -A
```

Keep your code clean and your conscience clear.

## Deployment Notes
- Ensure PostgreSQL and Redis are available and `REDIS_URL` is set
- Precompile assets if needed: `bin/rails assets:precompile`
- Run Sidekiq process:
```bash
bundle exec sidekiq -C config/sidekiq.yml
```
- Schedule (sidekiq-cron) is loaded automatically on server boot via initializer

## Security
- Keep credentials and env vars secure (obviously)
- Review `config/content_security_policy.rb` as needed
- CSRF protection enabled (because we're not animals)

## Contributing
1. Fork it
2. Create a feature branch
3. Write tests (because we're professionals)
4. Make sure RuboCop is happy
5. Submit a pull request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

---

*Built with ❤️ and ☕ by developers who believe that good code should be both functional and maintainable. No crypto was harmed in the making of this application.*
