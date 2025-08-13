require 'rails_helper'

RSpec.describe PriceCheckWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', direction: :up, threshold_price: 10, last_price: 9) }
  let!(:enabled_channel) { create(:notification_channel, :log_file, enabled: true) }
  let!(:disabled_channel) { create(:notification_channel, :log_file, enabled: false) }

  it 'enqueues per enabled channel when threshold is crossed and updates last_price' do
    client = instance_double(BinanceClient)
    allow(BinanceClient).to receive(:new).and_return(client)
    allow(client).to receive(:get_price).with('BTCUSDT').and_return(BigDecimal('10.0'))

    enqueuer = instance_double(NotificationEnqueuer)
    allow(NotificationEnqueuer).to receive(:new).and_return(enqueuer)
    expect(enqueuer).to receive(:enqueue).with(alert: alert, current_price: BigDecimal('10.0'))

    expect { described_class.new.perform(alert.id) }.not_to change { AlertNotification.count }

    alert.reload
    expect(alert.last_price).to eq(BigDecimal('10.0'))
  end
end
