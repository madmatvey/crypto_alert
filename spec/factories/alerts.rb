FactoryBot.define do
  factory :alert do
    symbol { 'BTCUSDT' }
    direction { :up }
    threshold_price { BigDecimal('10000.0') }
    active { true }
  end
end
