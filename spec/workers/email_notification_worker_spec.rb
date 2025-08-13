require 'rails_helper'

RSpec.describe EmailNotificationWorker, type: :worker do
  let!(:alert) { create(:alert, symbol: 'BTCUSDT', last_price: 9900) }
  let!(:channel) { create(:notification_channel, :email, enabled: true) }

  it 'sends email and records alert notification' do
    ActionMailer::Base.deliveries.clear

    expect {
      Sidekiq::Testing.inline! do
        described_class.perform_async(alert.id, channel.id, '10000')
      end
    }.to change { AlertNotification.count }.by(1)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include(channel.settings['to'])
    expect(mail.subject).to include('Alert:')
  end
end
