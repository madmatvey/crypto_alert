require 'rails_helper'

RSpec.describe 'NotificationChannels API', type: :request do
  describe 'CRUD' do
    it 'lists channels (JSON)' do
      create(:notification_channel, :log_file)
      get '/notification_channels.json'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'creates a channel (JSON)' do
      payload = { kind: 'email', enabled: true, settings_json: { to: 'alerts@example.com' }.to_json }
      post '/notification_channels.json', params: { notification_channel: payload }
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['kind']).to eq('email')
    end

    it 'updates a channel (JSON)' do
      ch = create(:notification_channel, :log_file)
      patch "/notification_channels/#{ch.id}.json", params: { notification_channel: { enabled: false } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['enabled']).to eq(false)
    end

    it 'destroys a channel (JSON)' do
      ch = create(:notification_channel, :log_file)
      delete "/notification_channels/#{ch.id}.json"
      expect(response).to have_http_status(:no_content)
    end
  end
end
