# frozen_string_literal: true

require "cgi"

class NotificationDispatcher
  def dispatch(alert, current_price)
    NotificationEnqueuer.new.enqueue(alert: alert, current_price: current_price)
  end

  private

  # Legacy helpers kept for spec compatibility
  def dispatch_log(channel, alert, current_price)
    path = channel.settings["path"] || "log/alerts.log"
    line = NotificationMessageBuilder.new.build_message(alert, current_price, channel)
    File.open(Rails.root.join(path), "a") { |f| f.puts(line) }
  end

  def dispatch_email(channel, alert, current_price)
    to = channel.settings["to"]
    return unless to.present?

    subject = (channel.settings["subject_template"] || "Alert: %{symbol} %{direction} %{threshold}") % {
      symbol: alert.symbol,
      direction: alert.direction,
      threshold: alert.threshold_price
    }
    body = NotificationMessageBuilder.new.build_message(alert, current_price, channel)
    AlertMailer.with(to: to, subject: subject, body: body).alert_email.deliver_later
  end

  def dispatch_browser(_channel, alert, current_price)
    title = NotificationMessageBuilder.new.browser_title
    body = NotificationMessageBuilder.new.browser_body(alert, current_price)
    html = %(<div data-controller="browser-notifications" data-browser-notifications-title-value="#{CGI.escapeHTML(title)}" data-browser-notifications-body-value="#{CGI.escapeHTML(body)}"></div>)
    Turbo::StreamsChannel.broadcast_append_to("browser_notifications", target: "browser_notifications", html: html)
  end

  def dispatch_telegram(channel, alert, current_price)
    token = channel.settings["bot_token"].to_s
    chat_id = channel.settings["chat_id"].to_s
    text = NotificationMessageBuilder.new.build_message(alert, current_price, channel)
    TelegramNotifier.new.send_message(token: token, chat_id: chat_id, text: text)
  end
end
