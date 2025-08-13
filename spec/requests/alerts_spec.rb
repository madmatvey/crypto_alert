require 'rails_helper'

RSpec.describe 'Alerts API', type: :request do
  describe 'CRUD' do
    it 'lists alerts (JSON)' do
      create(:alert)
      get '/alerts.json'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'creates an alert (JSON)' do
      post '/alerts.json', params: { alert: { symbol: 'ETHUSDT', direction: 'down', threshold_price: 1000, active: true } }
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['symbol']).to eq('ETHUSDT')
    end

    it 'updates an alert (JSON)' do
      alert = create(:alert)
      patch "/alerts/#{alert.id}.json", params: { alert: { active: false } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['active']).to eq(false)
    end

    it 'destroys an alert (JSON)' do
      alert = create(:alert)
      delete "/alerts/#{alert.id}.json"
      expect(response).to have_http_status(:no_content)
    end
  end
end
