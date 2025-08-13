# frozen_string_literal: true

class TelegramNotificationWorker
  include Sidekiq::Worker

  def perform(alert_id, channel_id, price_str)
    alert = Alert.find_by(id: alert_id)
    channel = NotificationChannel.find_by(id: channel_id)
    return unless alert && channel && channel.enabled?

    current_price = price_str && BigDecimal(price_str)
    builder = NotificationMessageBuilder.new
    message = builder.build_message(alert, current_price, channel)

    token = channel.settings["bot_token"].to_s
    chat_id = channel.settings["chat_id"].to_s
    return if token.blank? || chat_id.blank?

    ok = TelegramNotifier.new.send_message(token: token, chat_id: chat_id, text: message)
    if ok
      AlertNotification.create!(alert: alert, notification_channel: channel, delivered_at: Time.current)
    end
  rescue StandardError => e
    Rails.logger.warn("TelegramNotificationWorker error: #{e.class}: #{e.message}")
  end
end
