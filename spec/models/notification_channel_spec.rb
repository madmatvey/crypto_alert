require 'rails_helper'

RSpec.describe NotificationChannel, type: :model do
  it { is_expected.to define_enum_for(:kind).with_values(log_file: 0, email: 1) }

  context 'log_file' do
    it 'defaults path and accepts valid format' do
      nc = described_class.new(kind: :log_file, settings: { 'format' => 'plain' })
      expect(nc).to be_valid
      expect(nc.settings['path']).to eq('log/alerts.log')
    end

    it 'rejects invalid format' do
      nc = described_class.new(kind: :log_file, settings: { 'format' => 'xml' })
      expect(nc).not_to be_valid
    end
  end

  context 'email' do
    it 'requires to email' do
      nc = described_class.new(kind: :email, settings: {})
      expect(nc).not_to be_valid
    end

    it 'accepts valid email and sets subject template default' do
      nc = described_class.new(kind: :email, settings: { 'to' => 'a@b.com' })
      expect(nc).to be_valid
      expect(nc.settings['subject_template']).to be_present
    end
  end
end
