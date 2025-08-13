# frozen_string_literal: true

class NotificationMessageBuilder
  def build_message(alert, current_price, channel)
    if channel.settings["format"] == "json"
      {
        symbol: alert.symbol,
        direction: alert.direction,
        threshold: alert.threshold_price,
        price: current_price
      }.to_json
    else
      "#{Time.now.utc.iso8601} #{alert.symbol} #{alert.direction} threshold=#{alert.threshold_price} price=#{current_price}"
    end
  end

  def browser_title
    "Crypto Alert"
  end

  def browser_body(alert, current_price)
    "#{alert.symbol} #{alert.direction} crossed #{alert.threshold_price} — current #{current_price}"
  end
end
