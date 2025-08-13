# frozen_string_literal: true

class NotificationEnqueuer
  def enqueue(alert:, current_price:)
    return if alert.nil?
    price_str = current_price&.to_s
    NotificationChannel.find_each do |channel|
      next unless channel.enabled?
      case channel.kind.to_sym
      when :log_file
        LogFileNotificationWorker.perform_async(alert.id, channel.id, price_str)
      when :email
        EmailNotificationWorker.perform_async(alert.id, channel.id, price_str)
      when :browser
        BrowserNotificationWorker.perform_async(alert.id, channel.id, price_str)
      when :telegram
        TelegramNotificationWorker.perform_async(alert.id, channel.id, price_str)
      end
    end
  end
end
