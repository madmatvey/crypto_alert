require 'rails_helper'

RSpec.describe 'User Stories: Channels → Alerts → Notifications', type: :system do
  it 'creates channels, creates an alert, triggers crossing, and records notifications' do
    # Start clean for mail and logs
    ActionMailer::Base.deliveries.clear
    log_path = Rails.root.join('log/alerts.log')
    File.write(log_path, '') if File.exist?(log_path)

    # Create Browser channel
    visit notification_channels_path
    click_on 'New Channel'
    select 'Browser', from: 'Kind'
    check 'Enabled'
    click_on 'Create Notification channel'

    # Create Log File channel
    visit notification_channels_path
    click_on 'New Channel'
    select 'Log file', from: 'Kind'
    check 'Enabled'
    fill_in 'Path', with: log_path.to_s
    select 'plain', from: 'Format'
    click_on 'Create Notification channel'

    # Create Telegram channel
    visit new_notification_channel_path
    select 'Telegram', from: 'Kind'
    check 'Enabled'
    fill_in 'Bot token', with: 'TOKEN'
    fill_in 'Chat id', with: '123'
    click_on 'Create Notification channel'

    # Stub Telegram notifier
    telegram_double = instance_double(TelegramNotifier)
    allow(TelegramNotifier).to receive(:new).and_return(telegram_double)
    allow(telegram_double).to receive(:send_message).and_return(true)

    # Create valid alert (allow symbol validation)
    allow_any_instance_of(BinanceClient).to receive(:get_price).and_return(BigDecimal('10000'))
    visit alerts_path
    click_on 'New Alert'
    fill_in 'Symbol', with: 'BTCUSDT'
    select 'Up', from: 'Direction'
    fill_in 'Threshold price', with: '10000'
    check 'Active'
    click_on 'Create Alert'

    # Go back to index to load list
    visit alerts_path
    expect(page).to have_content('BTCUSDT')

    # Prepare crossing: set last_price below threshold
    alert = Alert.order(created_at: :desc).first
    alert.update_column(:last_price, BigDecimal('9900'))

    # Stub current price to reach threshold and trigger
    allow_any_instance_of(BinanceClient).to receive(:get_price).with('BTCUSDT').and_return(BigDecimal('10000'))

    # Run worker directly to avoid queue timing
    expect {
      PriceCheckWorker.new.perform(alert.id)
    }.to change { AlertNotification.count }.by(3)

    # Log file has a new line
    log_content = File.read(log_path)
    expect(log_content).to include('BTCUSDT')
    expect(log_content).to match(/price=10000/)

    # Telegram was called
    expect(telegram_double).to have_received(:send_message).with(hash_including(token: 'TOKEN', chat_id: '123', text: kind_of(String)))

    # last_price updated
    alert.reload
    expect(alert.last_price).to eq(BigDecimal('10000'))
  end
end
