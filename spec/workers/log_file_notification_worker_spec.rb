require 'rails_helper'

RSpec.describe LogFileNotificationWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', last_price: 9900) }
  let!(:channel) { create(:notification_channel, :log_file, enabled: true) }

  it 'writes to log and records alert notification' do
    log_path = Rails.root.join(channel.settings['path'])
    File.write(log_path, '') if File.exist?(log_path)

    expect {
      Sidekiq::Testing.inline! do
        described_class.perform_async(alert.id, channel.id, '10000')
      end
    }.to change { AlertNotification.count }.by(1)

    content = File.read(log_path)
    expect(content).to include('BTCUSDT')
    expect(content).to match(/price=10000/)
  end
end
