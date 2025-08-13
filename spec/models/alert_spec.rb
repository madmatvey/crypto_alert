require 'rails_helper'

RSpec.describe Alert, type: :model do
  it { is_expected.to validate_presence_of(:symbol) }
  it { is_expected.to define_enum_for(:direction).with_values(up: 0, down: 1) }
  it { is_expected.to validate_presence_of(:threshold_price) }
  it { is_expected.to validate_numericality_of(:threshold_price).is_greater_than(0) }
end
