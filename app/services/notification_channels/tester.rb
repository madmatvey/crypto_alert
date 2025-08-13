# frozen_string_literal: true

require "digest"

module NotificationChannels
  class Tester
    Result = Struct.new(:ok, :message, :settings_digest, keyword_init: true)

    def test(kind:, settings: {}, session_id: nil)
      digest = compute_digest(kind, settings)
      case kind.to_s
      when "log_file"
        test_log_file(settings, digest)
      when "email"
        test_email(settings, digest)
      when "telegram"
        test_telegram(settings, digest)
      when "browser"
        # For browser, we cannot verify server-side. Return instruction; client will ACK.
        Result.new(ok: false, message: "Trigger browser test on client", settings_digest: digest)
      else
        Result.new(ok: false, message: "Unsupported channel kind", settings_digest: digest)
      end
    end

    private

    def compute_digest(kind, settings)
      Digest::SHA256.hexdigest([ kind.to_s, settings.to_json ].join("|"))
    end

    def test_log_file(settings, digest)
      path = settings.fetch("path", "log/alerts.log").to_s
      full_path = Rails.root.join(path)
      File.open(full_path, "a") { |f| f.puts("[TEST] #{Time.now.utc.iso8601}") }
      Result.new(ok: true, message: "Wrote test line to #{path}", settings_digest: digest)
    rescue StandardError => e
      Result.new(ok: false, message: "Failed to write: #{e.message}", settings_digest: digest)
    end

    def test_email(settings, digest)
      to = settings.fetch("to", "").to_s
      return Result.new(ok: false, message: "Recipient email is invalid", settings_digest: digest) unless to =~ /@/
      AlertMailer.with(to: to, subject: "Test Notification", body: "This is a test.").test_email.deliver_now
      Result.new(ok: true, message: "Sent test email to #{to}", settings_digest: digest)
    rescue StandardError => e
      Result.new(ok: false, message: "Failed to send email: #{e.message}", settings_digest: digest)
    end

    def test_telegram(settings, digest)
      token = settings.fetch("bot_token", "").to_s
      chat_id = settings.fetch("chat_id", "").to_s
      ok = TelegramNotifier.new.send_message(token: token, chat_id: chat_id, text: "Test notification")
      if ok
        Result.new(ok: true, message: "Telegram test sent", settings_digest: digest)
      else
        Result.new(ok: false, message: "Telegram test failed", settings_digest: digest)
      end
    rescue StandardError => e
      Result.new(ok: false, message: "Telegram error: #{e.message}", settings_digest: digest)
    end
  end
end
