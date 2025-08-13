class Alert < ApplicationRecord
  has_many :alert_notifications, dependent: :destroy

  enum :direction, { up: 0, down: 1 }

  validates :symbol, presence: true
  validates :direction, presence: true
  validates :threshold_price, presence: true, numericality: { greater_than: 0 }
end
