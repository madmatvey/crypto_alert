require 'rails_helper'

RSpec.describe BinanceClient do
  it 'returns BigDecimal price on success' do
    conn = Faraday.new do |b|
      b.adapter :test do |stubs|
        stubs.get('/api/v3/ticker/price') do |env|
          expect(env.params['symbol']).to eq('BTCUSDT')
          [ 200, { 'Content-Type' => 'application/json' }, { price: '12345.67' }.to_json ]
        end
      end
    end

    client = described_class.new(http_client: conn)
    price = client.get_price('btcusdt')
    expect(price).to be_a(BigDecimal)
    expect(price).to eq(BigDecimal('12345.67'))
  end

  it 'returns nil on failure' do
    conn = Faraday.new do |b|
      b.adapter :test do |stubs|
        stubs.get('/api/v3/ticker/price') { [ 500, {}, '' ] }
      end
    end
    client = described_class.new(http_client: conn)
    expect(client.get_price('ETHUSDT')).to be_nil
  end
end
