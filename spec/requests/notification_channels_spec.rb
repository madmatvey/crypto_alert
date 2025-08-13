require 'rails_helper'

RSpec.describe 'NotificationChannels', type: :request do
  it 'creates a telegram channel via JSON' do
    post '/notification_channels.json', params: { notification_channel: { kind: 'telegram', enabled: true, settings_json: { bot_token: 'TOKEN', chat_id: '123' }.to_json } }
    expect(response).to have_http_status(:created).or have_http_status(:ok)
  end
end
