require 'rails_helper'

RSpec.describe 'Notifications (Turbo Streams)', type: :system do
  include TurboSystemTestHelper

  it 'receives a browser notification broadcast' do
    skip 'Ephemeral element removed immediately by Stimulus; assert via service specs instead'

    visit alerts_path
    connect_turbo

    alert = create(:alert, last_price: 9000)
    NotificationDispatcher.new.send(:dispatch_browser, NotificationChannel.new(kind: :browser, enabled: true, settings: {}), alert, 10050)

    visit alerts_path
    connect_turbo

    expect(page).to have_css('[data-controller="browser-notifications"]', wait: 2)
  end
end
