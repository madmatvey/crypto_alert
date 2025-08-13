require 'rails_helper'

RSpec.describe 'Notification Channels', type: :system do
  it 'creates a browser channel' do
    visit notification_channels_path
    click_on 'New Channel'

    select 'Browser', from: 'Kind'
    check 'Enabled'
    fill_in 'Settings (JSON)', with: '{}'
    click_on 'Create Notification channel'

    expect(page).to have_content('browser').or have_content('Browser')
  end

  it 'creates a telegram channel' do
    visit new_notification_channel_path
    select 'Telegram', from: 'Kind'
    check 'Enabled'
    fill_in 'Settings (JSON)', with: { bot_token: 'TOKEN', chat_id: '123' }.to_json
    click_on 'Create Notification channel'

    expect(page).to have_content('telegram').or have_content('Telegram')
  end
end
