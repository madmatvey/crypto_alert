# frozen_string_literal: true

class LogFileNotificationWorker
  include Sidekiq::Worker

  def perform(alert_id, channel_id, price_str)
    alert = Alert.find_by(id: alert_id)
    channel = NotificationChannel.find_by(id: channel_id)
    return unless alert && channel && channel.enabled?

    current_price = price_str && BigDecimal(price_str)
    builder = NotificationMessageBuilder.new
    message = builder.build_message(alert, current_price, channel)

    path = channel.settings["path"].presence || "log/alerts.log"
    File.open(Rails.root.join(path), "a") { |f| f.puts(message) }

    AlertNotification.create!(alert: alert, notification_channel: channel, delivered_at: Time.current)
  rescue StandardError => e
    Rails.logger.warn("LogFileNotificationWorker error: #{e.class}: #{e.message}")
  end
end
