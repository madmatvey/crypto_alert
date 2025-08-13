# frozen_string_literal: true

class EmailNotificationWorker
  include Sidekiq::Worker

  def perform(alert_id, channel_id, price_str)
    alert = Alert.find_by(id: alert_id)
    channel = NotificationChannel.find_by(id: channel_id)
    return unless alert && channel && channel.enabled?

    current_price = price_str && BigDecimal(price_str)
    builder = NotificationMessageBuilder.new
    message = builder.build_message(alert, current_price, channel)

    to = channel.settings["to"].to_s
    return if to.blank?
    subject = (channel.settings["subject_template"] || "Alert: %{symbol} %{direction} %{threshold}") % {
      symbol: alert.symbol,
      direction: alert.direction,
      threshold: alert.threshold_price
    }
    AlertMailer.with(to: to, subject: subject, body: message).alert_email.deliver_now

    AlertNotification.create!(alert: alert, notification_channel: channel, delivered_at: Time.current)
  rescue StandardError => e
    Rails.logger.warn("EmailNotificationWorker error: #{e.class}: #{e.message}")
  end
end
