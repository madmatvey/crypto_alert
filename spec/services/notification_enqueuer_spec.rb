require 'rails_helper'

RSpec.describe NotificationEnqueuer do
  let(:alert) { create(:alert, last_price: 9000) }

  before do
    Sidekiq::Worker.clear_all
  end

  it 'enqueues one job per enabled channel with serialized price' do
    log = create(:notification_channel, :log_file, enabled: true)
    email = create(:notification_channel, :email, enabled: true)
    browser = NotificationChannel.create!(kind: :browser, enabled: true, settings: {})
    telegram = NotificationChannel.create!(kind: :telegram, enabled: true, settings: { 'bot_token' => 'T', 'chat_id' => '1' })

    described_class.new.enqueue(alert: alert, current_price: BigDecimal('123.45'))

    expect(Sidekiq::Queues['default'].size).to eq(4)
  end
end
