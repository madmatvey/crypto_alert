# frozen_string_literal: true

class PollActiveAlertsWorker
  include Sidekiq::Worker

  def perform
    Alert.where(active: true).find_each do |alert|
      PriceCheckWorker.perform_async(alert.id)
    end
  end
end
