# frozen_string_literal: true

class TelegramNotifier
  API_BASE = "https://api.telegram.org"

  def initialize(http_client: Faraday.new(url: API_BASE))
    @http_client = http_client
  end

  def send_message(token:, chat_id:, text:)
    return false if token.to_s.strip.empty? || chat_id.to_s.strip.empty?

    path = "/bot#{token}/sendMessage"
    response = http_client.post(path) do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { chat_id: chat_id, text: text }.to_json
      req.options.timeout = 5
      req.options.open_timeout = 3
    end

    response.success?
  rescue StandardError => e
    Rails.logger.warn("TelegramNotifier error: #{e.class}: #{e.message}")
    false
  end

  private

  attr_reader :http_client
end
