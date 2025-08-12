# Memory Bank: Tech Context

## Stack and Versions
- Ruby: 3.4.4
- Rails: 8.0.2
- DB: PostgreSQL
- Background jobs: Sidekiq 8.x + Redis (no Active Job usage in app code)
- Mailer: ActionMailer
- HTTP client: Faraday
- Tests: RSpec, Capybara, FactoryBot, Faker, Shoulda-Matchers
- Lint: RuboCop (rails-omakase)

## Key Decisions
- Use Sidekiq directly for background processing; do not implement app jobs with Active Job.
- Avoid Rails 8 default Solid Queue for our app jobs. If any framework features enqueue via Active Job (e.g., deliver_later), either:
  - Call `deliver_now` within our Sidekiq workers, or
  - Set `config.active_job.queue_adapter = :sidekiq` across environments to route framework jobs to Sidekiq.
- Schedule polling via `sidekiq-cron` (open-source) on a 1-minute cadence.
- Mount Sidekiq Web UI at `/sidekiq` (protected in production).

## Gems to add
- sidekiq
- redis
- sidekiq-cron
- rspec-rails
- factory_bot_rails
- faker
- shoulda-matchers
- faraday

## Sidekiq configuration (initializer)
```ruby
# config/initializers/sidekiq.rb
require "sidekiq"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0") }
  # Tune scheduled polling if needed
  # config.average_scheduled_poll_interval = 15

  # Optional: global handler for jobs that exhaust retries
  config.default_retries_exhausted = ->(job, ex) {
    Sidekiq.logger.info "#{job["class"]} is dead: #{ex.message}"
  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0") }
end
```

## Concurrency and DB pool
- Sidekiq concurrency derives from `RAILS_MAX_THREADS` by default. Ensure DB pool matches.
```yaml
# config/database.yml (snippet)
default: &default
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
```
- Example process sizing:
```sh
RAILS_MAX_THREADS=10 bundle exec sidekiq
```

## Cron scheduling (sidekiq-cron)
```ruby
# config/initializers/sidekiq_cron.rb
require "sidekiq/cron/job"
Sidekiq::Cron::Job.create(
  name: "PollActiveAlerts - every 1 min",
  cron: "* * * * *",
  class: "PollActiveAlertsWorker"
)
```

## Sidekiq Web UI (routes)
```ruby
# config/routes.rb
require "sidekiq/web"
mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
```
- Production protection example:
```ruby
# config/routes.rb (production)
require "sidekiq/web"
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
end
mount Sidekiq::Web, at: "/sidekiq"
```

## Testing Sidekiq
```ruby
# spec/rails_helper.rb (snippet)
require "sidekiq/testing"
Sidekiq::Testing.inline!
```
- For API-level assertions against real Redis: `Sidekiq::Testing.disable!` within specific examples.

## ActionMailer in tests
- Test environment already uses `config.action_mailer.delivery_method = :test`.
- In workers, call `deliver_now` to avoid Active Job.

## Environment variables
- `REDIS_URL` (e.g., redis://127.0.0.1:6379/0)
- `SIDEKIQ_USERNAME`, `SIDEKIQ_PASSWORD` (production UI protection)

## Rails 8 note
- Rails 8 defaults to Solid Queue for Active Job. We will not use Active Job for app jobs; if any framework feature enqueues jobs, we will either force `deliver_now` or set `config.active_job.queue_adapter = :sidekiq` to keep everything on Sidekiq.
