require 'rails_helper'

RSpec.describe PriceChecker do
  let(:checker) { described_class.new }

  it 'triggers when direction up and price >= threshold' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :up, threshold_price: 10, active: true)
    expect(checker.triggered?(alert, 10)).to eq(true)
    expect(checker.triggered?(alert, 11)).to eq(true)
    expect(checker.triggered?(alert, 9)).to eq(false)
  end

  it 'triggers when direction down and price <= threshold' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :down, threshold_price: 10, active: true)
    expect(checker.triggered?(alert, 9)).to eq(true)
    expect(checker.triggered?(alert, 10)).to eq(true)
    expect(checker.triggered?(alert, 11)).to eq(false)
  end

  it 'does not trigger when current_price is nil' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :up, threshold_price: 10, active: true)
    expect(checker.triggered?(alert, nil)).to eq(false)
  end
end
