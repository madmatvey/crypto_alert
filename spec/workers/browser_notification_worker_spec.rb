require 'rails_helper'

RSpec.describe BrowserNotificationWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', last_price: 9900) }
  let!(:channel) { NotificationChannel.create!(kind: :browser, enabled: true, settings: {}) }

  it 'broadcasts and records alert notification' do
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)

    expect {
      Sidekiq::Testing.inline! do
        described_class.perform_async(alert.id, channel.id, '10000')
      end
    }.to change { AlertNotification.count }.by(1)

    expect(Turbo::StreamsChannel).to have_received(:broadcast_append_to)
  end
end
