# frozen_string_literal: true

class HelloWorker
  include Sidekiq::Worker

  def perform(message = "hello")
    Rails.logger.info("HelloWorker says: #{message}")
  end
end
