require 'rails_helper'

RSpec.describe TelegramNotificationWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', last_price: 9900) }
  let!(:channel) { NotificationChannel.create!(kind: :telegram, enabled: true, settings: { 'bot_token' => 'TOKEN', 'chat_id' => '123' }) }

  it 'sends telegram message and records alert notification' do
    notifier = instance_double(TelegramNotifier)
    allow(TelegramNotifier).to receive(:new).and_return(notifier)
    allow(notifier).to receive(:send_message).and_return(true)

    expect {
      Sidekiq::Testing.inline! do
        described_class.perform_async(alert.id, channel.id, '10000')
      end
    }.to change { AlertNotification.count }.by(1)

    expect(notifier).to have_received(:send_message).with(hash_including(token: 'TOKEN', chat_id: '123', text: kind_of(String)))
  end
end
