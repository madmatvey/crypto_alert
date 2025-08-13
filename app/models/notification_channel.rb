class NotificationChannel < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy

  enum :kind, { log_file: 0, email: 1, browser: 2, telegram: 3 }

  validates :kind, presence: true
  validate :validate_settings_by_kind

  def validate_settings_by_kind
    case kind&.to_sym
    when :log_file
      validate_log_file_settings
    when :email
      validate_email_settings
    when :browser
      validate_browser_settings
    when :telegram
      validate_telegram_settings
    else
      errors.add(:kind, "is not supported")
    end
  end

  def validate_log_file_settings
    path = settings.fetch("path", "").to_s
    format = settings.fetch("format", "plain").to_s

    path = "log/alerts.log" if path.strip.empty?
    settings["path"] = path

    unless %w[plain json].include?(format)
      errors.add(:settings, "format must be 'plain' or 'json'")
    end
  end

  def validate_email_settings
    to = settings["to"].to_s
    if to.strip.empty? || !(to =~ /@/)
      errors.add(:settings, "to must be a valid email")
    end

    settings["subject_template"] ||= "Alert: %{symbol} %{direction} %{threshold}"
  end

  def validate_browser_settings
    # no-op for now; presence of enabled flag is enough
    true
  end

  def validate_telegram_settings
    token = settings["bot_token"].to_s
    chat_id = settings["chat_id"].to_s

    if token.strip.empty?
      errors.add(:settings, "bot_token is required")
    end

    if chat_id.strip.empty?
      errors.add(:settings, "chat_id is required")
    elsif chat_id !~ /^-?\d+$/
      errors.add(:settings, "chat_id must be numeric")
    end
  end
end
