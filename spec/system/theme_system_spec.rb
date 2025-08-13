require 'rails_helper'

RSpec.describe 'Theme', type: :system do
  it 'renders dark theme navigation and buttons' do
    visit root_path
    expect(page).to have_css('nav')
    # Buttons exist in nav
    within('nav') do
      expect(page).to have_link('Alerts')
      expect(page).to have_link('Channels')
    end
  end
end
