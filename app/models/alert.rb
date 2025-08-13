class Alert < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy

  enum :direction, { up: 0, down: 1 }

  validates :symbol, presence: true
  validates :direction, presence: true
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
  validate :binance_symbol_exists, on: :create

  private

  def binance_symbol_exists
    return if symbol.to_s.strip.empty?

    validator = Alerts::SymbolValidator.new
    if !validator.valid_symbol?(symbol)
      errors.add(:symbol, "is invalid")
    end
  rescue StandardError
    errors.add(:symbol, "could not be validated at this time")
  end
end
