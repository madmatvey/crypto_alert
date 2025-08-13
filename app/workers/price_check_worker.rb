# frozen_string_literal: true

class PriceCheckWorker
  include Sidekiq::Worker

  def perform(alert_id)
    alert = Alert.find_by(id: alert_id)
    return unless alert&.active?

    client = BinanceClient.new
    current_price = client.get_price(alert.symbol)

    if PriceChecker.new.triggered?(alert, current_price)
      NotificationEnqueuer.new.enqueue(alert: alert, current_price: current_price)
    end

    # Persist last observed price for future threshold crossing detection
    if current_price
      alert.update_column(:last_price, current_price)
    end
  end
end
