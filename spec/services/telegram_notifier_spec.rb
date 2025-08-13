require 'rails_helper'

RSpec.describe TelegramNotifier do
  let(:http_client) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, success?: true) }

  it 'sends a POST to Telegram sendMessage with token and chat_id' do
    notifier = described_class.new(http_client: http_client)

    yielded_req = double(:req)
    allow(yielded_req).to receive(:headers).and_return({})
    allow(yielded_req).to receive(:headers=)
    allow(yielded_req).to receive(:body=)
    allow(yielded_req).to receive(:options).and_return(double(timeout: nil, open_timeout: nil, :timeout= => nil, :open_timeout= => nil))

    expect(http_client).to receive(:post).with("/botTOKEN/sendMessage").and_yield(yielded_req).and_return(response)

    expect(
      notifier.send_message(token: 'TOKEN', chat_id: '123', text: 'hello')
    ).to eq(true)
  end

  it 'returns false on network error' do
    notifier = described_class.new(http_client: http_client)
    allow(http_client).to receive(:post).and_raise(Faraday::TimeoutError)
    expect(notifier.send_message(token: 'TOKEN', chat_id: '123', text: 'hello')).to eq(false)
  end
end
