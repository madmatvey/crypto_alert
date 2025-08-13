require 'rails_helper'
require 'capybara/rspec'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome
  end
end

module TurboSystemTestHelper
  def connect_turbo
    if page.respond_to?(:connect_turbo_cable_stream_sources)
      connect_turbo_cable_stream_sources
    else
      # Fallback: small wait to allow cable to connect in older turbo-rails versions
      sleep 0.2
    end
  end
end

RSpec.configure do |config|
  config.include TurboSystemTestHelper, type: :system
end
