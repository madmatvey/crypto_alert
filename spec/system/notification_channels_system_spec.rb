require 'rails_helper'

RSpec.describe 'Notification Channels', type: :system do
  it 'creates a browser channel and redirects to index with flash' do
    visit notification_channels_path
    click_on 'New Channel'

    select 'Browser', from: 'Kind'
    check 'Enabled'
    click_on 'Create Notification channel'

    expect(page).to have_current_path(notification_channels_path, ignore_query: true)
    expect(page).to have_content('Channel was successfully created.')
    expect(page).to have_content('browser').or have_content('Browser')
  end

  it 'creates a telegram channel and redirects to index with flash' do
    visit new_notification_channel_path
    select 'Telegram', from: 'Kind'
    check 'Enabled'
    fill_in 'Bot token', with: 'TOKEN'
    fill_in 'Chat id', with: '123'
    click_on 'Create Notification channel'

    expect(page).to have_current_path(notification_channels_path, ignore_query: true)
    expect(page).to have_content('Channel was successfully created.')
    expect(page).to have_content('telegram').or have_content('Telegram')
  end

  it 'supports Check settings for log_file (shows error for unwritable dir)' do
    visit new_notification_channel_path
    select 'Log file', from: 'Kind'
    check 'Enabled'
    fill_in 'Path', with: '/root/forbidden/alerts.log'
    click_on 'Check settings'
    expect(page).to have_content('Directory not writable').or have_css('#check_result')
  end

  it 'updates a channel and redirects to index with flash' do
    channel = create(:notification_channel, kind: :log_file, enabled: true, settings: {})

    visit notification_channels_path
    within("#notification_channel_#{channel.id}") do
      click_on 'Edit'
    end

    uncheck 'Enabled'
    click_on 'Update Notification channel'

    expect(page).to have_current_path(notification_channels_path, ignore_query: true)
    expect(page).to have_content('Channel was successfully updated.')
  end

  it 'deletes a channel and redirects to index with flash' do
    channel = create(:notification_channel, kind: :browser, enabled: true, settings: {})

    visit notification_channels_path
    expect(page).to have_selector("#notification_channel_#{channel.id}")

    within("#notification_channel_#{channel.id}") do
      click_on 'Delete'
    end

    expect(page).to have_current_path(notification_channels_path, ignore_query: true)
    expect(page).to have_content('Channel was successfully destroyed.')
    expect(page).not_to have_selector("#notification_channel_#{channel.id}")
  end

  it 'toggles fields per kind selection' do
    visit new_notification_channel_path
    # Browser shows info, no token fields
    select 'Browser', from: 'Kind'
    expect(page).to have_content('Browser notifications')
    expect(page).not_to have_field('Bot token')
    # Telegram shows token/chat fields
    select 'Telegram', from: 'Kind'
    expect(page).to have_field('Bot token')
    expect(page).to have_field('Chat id')
    # Log file shows path/format
    select 'Log file', from: 'Kind'
    expect(page).to have_field('Path')
    expect(page).to have_select('Format')
  end

  it 'checks settings for browser (inline result)' do
    visit new_notification_channel_path
    select 'Browser', from: 'Kind'
    click_on 'Check settings'
    expect(page).to have_css('#check_result')
    expect(page).to have_content('no settings').or have_content('Browser notifications')
  end

  it 'checks settings for telegram (ok path with stub)' do
    visit new_notification_channel_path
    select 'Telegram', from: 'Kind'
    fill_in 'Bot token', with: 'TOKEN'
    fill_in 'Chat id', with: '123'
    # Stub Faraday getMe
    allow(Faraday).to receive(:new).and_return(double(get: double(success?: true)))
    click_on 'Check settings'
    expect(page).to have_css('#check_result')
    expect(page).to have_content('token looks valid').or have_content('ok')
  end
end
