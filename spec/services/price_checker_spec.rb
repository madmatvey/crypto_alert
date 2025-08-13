require 'rails_helper'

RSpec.describe PriceChecker do
  let(:checker) { described_class.new }

  it 'triggers when direction up crosses from below to >= threshold' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :up, threshold_price: 10, active: true, last_price: 9)
    expect(checker.triggered?(alert, 10)).to eq(true)
    expect(checker.triggered?(alert, 11)).to eq(true)
    expect(checker.triggered?(alert, 9)).to eq(false)
  end

  it 'triggers when direction down crosses from above to <= threshold' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :down, threshold_price: 10, active: true, last_price: 11)
    expect(checker.triggered?(alert, 9)).to eq(true)
    expect(checker.triggered?(alert, 10)).to eq(true)
    expect(checker.triggered?(alert, 11)).to eq(false)
  end

  it 'does not trigger when current_price is nil' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :up, threshold_price: 10, active: true, last_price: 9)
    expect(checker.triggered?(alert, nil)).to eq(false)
  end

  it 'does not trigger on first observation when last_price is nil' do
    alert = Alert.new(symbol: 'BTCUSDT', direction: :up, threshold_price: 10, active: true, last_price: nil)
    expect(checker.triggered?(alert, 12)).to eq(false)
  end
end
