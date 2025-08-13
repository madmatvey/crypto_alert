require 'rails_helper'

RSpec.describe PriceCheckWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', direction: :up, threshold_price: 10) }
  let!(:channel) { create(:notification_channel, :log_file) }

  it 'dispatches when price meets threshold' do
    # Stub BinanceClient
    client = instance_double(BinanceClient)
    allow(BinanceClient).to receive(:new).and_return(client)
    allow(client).to receive(:get_price).with('BTCUSDT').and_return(BigDecimal('10.0'))

    dispatcher = instance_double(NotificationDispatcher)
    allow(NotificationDispatcher).to receive(:new).and_return(dispatcher)
    allow(dispatcher).to receive(:dispatch)

    expect { described_class.new.perform(alert.id) }
      .to change { AlertNotification.count }.by(1)

    expect(dispatcher).to have_received(:dispatch)
  end
end
