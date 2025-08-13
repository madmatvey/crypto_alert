class NotificationChannel < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy

  enum :kind, { log_file: 0, email: 1 }

  validates :kind, presence: true
  validate :validate_settings_by_kind

  def validate_settings_by_kind
    case kind&.to_sym
    when :log_file
      validate_log_file_settings
    when :email
      validate_email_settings
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
end
