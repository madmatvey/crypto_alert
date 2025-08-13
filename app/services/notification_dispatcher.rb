# frozen_string_literal: true

require "cgi"

class NotificationDispatcher
  def dispatch(alert, current_price)
    NotificationChannel.find_each do |channel|
      next unless channel.enabled?

      case channel.kind.to_sym
      when :log_file
        dispatch_log(channel, alert, current_price)
      when :email
        dispatch_email(channel, alert, current_price)
      when :browser
        dispatch_browser(channel, alert, current_price)
      when :telegram
        dispatch_telegram(channel, alert, current_price)
      end
    end
  end

  private

  def dispatch_log(channel, alert, current_price)
    path = channel.settings["path"] || "log/alerts.log"
    line = build_message(alert, current_price, channel)
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
    body = build_message(alert, current_price, channel)
    AlertMailer.with(to: to, subject: subject, body: body).alert_email.deliver_later
  end

  def dispatch_browser(_channel, alert, current_price)
    title = "Crypto Alert"
    body = "#{alert.symbol} #{alert.direction} crossed #{alert.threshold_price} — current #{current_price}"
    html = %(<div data-controller="browser-notifications" data-browser-notifications-title-value="#{CGI.escapeHTML(title)}" data-browser-notifications-body-value="#{CGI.escapeHTML(body)}"></div>)
    Turbo::StreamsChannel.broadcast_append_to("browser_notifications", target: "browser_notifications", html: html)
  end

  def dispatch_telegram(channel, alert, current_price)
    token = channel.settings["bot_token"].to_s
    chat_id = channel.settings["chat_id"].to_s
    text = build_message(alert, current_price, channel)
    TelegramNotifier.new.send_message(token: token, chat_id: chat_id, text: text)
  end

  def build_message(alert, current_price, channel)
    if channel.settings["format"] == "json"
      { symbol: alert.symbol, direction: alert.direction, threshold: alert.threshold_price, price: current_price }.to_json
    else
      "#{Time.now.utc.iso8601} #{alert.symbol} #{alert.direction} threshold=#{alert.threshold_price} price=#{current_price}"
    end
  end
end
