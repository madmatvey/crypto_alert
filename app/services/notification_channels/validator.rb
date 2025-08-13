# frozen_string_literal: true

module NotificationChannels
  class Validator
    Result = Struct.new(:ok, :message, keyword_init: true)

    def validate(kind:, settings: {})
      case kind.to_s
      when "log_file"
        validate_log_file(settings)
      when "email"
        validate_email(settings)
      when "browser"
        Result.new(ok: true, message: "Browser notifications require no settings")
      when "telegram"
        validate_telegram(settings)
      else
        Result.new(ok: false, message: "Unsupported channel kind")
      end
    end

    private

    def validate_log_file(settings)
      path = settings.fetch("path", "log/alerts.log").to_s
      dir = File.dirname(path)
      full_dir = Rails.root.join(dir)
      if Dir.exist?(full_dir) && File.writable?(full_dir)
        Result.new(ok: true, message: "Path is writable: #{path}")
      else
        Result.new(ok: false, message: "Directory not writable or does not exist: #{dir}")
      end
    end

    def validate_email(settings)
      to = settings.fetch("to", "").to_s
      if to =~ /@/
        Result.new(ok: true, message: "Email looks valid")
      else
        Result.new(ok: false, message: "Recipient email is invalid")
      end
    end

    def validate_telegram(settings)
      token = settings.fetch("bot_token", "").to_s
      chat_id = settings.fetch("chat_id", "").to_s
      return Result.new(ok: false, message: "bot_token is required") if token.strip.empty?
      return Result.new(ok: false, message: "chat_id must be numeric") unless chat_id.to_s.match?(/^-?\d+$/)

      # Probe getMe to validate token without sending messages
      http = Faraday.new(url: TelegramNotifier::API_BASE)
      resp = http.get("/bot#{token}/getMe") do |req|
        req.options.timeout = 3
        req.options.open_timeout = 2
      end
      if resp.success?
        Result.new(ok: true, message: "Telegram token looks valid")
      else
        Result.new(ok: false, message: "Telegram API responded with #{resp.status}")
      end
    rescue StandardError => e
      Rails.logger.info("Validator telegram probe failed: #{e.class}: #{e.message}")
      Result.new(ok: false, message: "Could not verify Telegram token")
    end
  end
end
