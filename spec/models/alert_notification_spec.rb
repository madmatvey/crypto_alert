require 'rails_helper'

RSpec.describe AlertNotification, type: :model do
  it { is_expected.to belong_to(:alert) }
  it { is_expected.to belong_to(:notification_channel) }
end
