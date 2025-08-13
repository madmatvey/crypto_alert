# frozen_string_literal: true

class BrowserNotificationWorker
  include Sidekiq::Worker

  def perform(alert_id, channel_id, price_str)
    alert = Alert.find_by(id: alert_id)
    channel = NotificationChannel.find_by(id: channel_id)
    return unless alert && channel && channel.enabled?

    current_price = price_str && BigDecimal(price_str)
    builder = NotificationMessageBuilder.new
    title = builder.browser_title
    body = builder.browser_body(alert, current_price)
    html = %(<div data-controller="browser-notifications" data-browser-notifications-title-value="#{CGI.escapeHTML(title)}" data-browser-notifications-body-value="#{CGI.escapeHTML(body)}"></div>)
    Turbo::StreamsChannel.broadcast_append_to("browser_notifications", target: "browser_notifications", html: html)

    AlertNotification.create!(alert: alert, notification_channel: channel, delivered_at: Time.current)
  rescue StandardError => e
    Rails.logger.warn("BrowserNotificationWorker error: #{e.class}: #{e.message}")
  end
end
