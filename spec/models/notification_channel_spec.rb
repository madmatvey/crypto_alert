require 'rails_helper'

RSpec.describe NotificationChannel, type: :model do
  it { is_expected.to define_enum_for(:kind).with_values(log_file: 0, email: 1, browser: 2, telegram: 3) }

  context 'telegram validations' do
    it 'requires bot_token and chat_id' do
      channel = described_class.new(kind: :telegram, enabled: true, settings: {})
      expect(channel).not_to be_valid
      expect(channel.errors[:settings]).to include("bot_token is required")
      expect(channel.errors[:settings]).to include("chat_id is required")
    end

    it 'accepts numeric chat_id' do
      channel = described_class.new(kind: :telegram, enabled: true, settings: { 'bot_token' => 'TOKEN', 'chat_id' => '123' })
      expect(channel).to be_valid
    end
  end

  context 'browser validations' do
    it 'is valid with empty settings' do
      channel = described_class.new(kind: :browser, enabled: true, settings: {})
      expect(channel).to be_valid
    end
  end
end
