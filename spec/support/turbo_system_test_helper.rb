module TurboSystemTestHelper
  def connect_turbo
    if page.respond_to?(:connect_turbo_cable_stream_sources)
      connect_turbo_cable_stream_sources
    else
      sleep 0.2
    end
  end
end

RSpec.configure do |config|
  config.include TurboSystemTestHelper, type: :system
end
