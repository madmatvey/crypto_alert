require 'rails_helper'

RSpec.describe NotificationDispatcher do
  let(:dispatcher) { described_class.new }
  let(:alert) { create(:alert, last_price: 9000) }

  it 'dispatches to browser without error' do
    channel = NotificationChannel.new(kind: :browser, enabled: true, settings: {})
    expect { dispatcher.send(:dispatch_browser, channel, alert, 10000) }.not_to raise_error
  end

  it 'dispatches to telegram via notifier' do
    channel = NotificationChannel.new(kind: :telegram, enabled: true, settings: { 'bot_token' => 'TOKEN', 'chat_id' => '123' })
    notifier = instance_double(TelegramNotifier)
    allow(TelegramNotifier).to receive(:new).and_return(notifier)
    expect(notifier).to receive(:send_message).with(token: 'TOKEN', chat_id: '123', text: kind_of(String)).and_return(true)
    dispatcher.send(:dispatch_telegram, channel, alert, 10000)
  end
end
