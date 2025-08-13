# frozen_string_literal: true

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Load cron schedule if present
  schedule_file = Rails.root.join("config", "sidekiq_schedule.yml")
  if File.exist?(schedule_file)
    require "sidekiq/cron/job"
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
