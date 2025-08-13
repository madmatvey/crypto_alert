require 'rails_helper'

RSpec.describe 'Alerts', type: :system do
  it 'creates a valid alert and redirects to index with flash' do
    allow_any_instance_of(BinanceClient).to receive(:get_price).and_return(BigDecimal('10000'))

    visit root_path
    click_on 'New Alert'

    fill_in 'Symbol', with: 'BTCUSDT'
    select 'Up', from: 'Direction'
    fill_in 'Threshold price', with: '10000'
    check 'Active'

    click_on 'Create Alert'

    expect(page).to have_current_path(alerts_path, ignore_query: true)
    expect(page).to have_content('Alert was successfully created.')
    expect(page).to have_selector('#alerts tr', minimum: 1)
    expect(page).to have_content('BTCUSDT')
  end

  it 'rejects invalid symbol on create' do
    allow_any_instance_of(BinanceClient).to receive(:get_price).and_return(nil)

    visit new_alert_path
    fill_in 'Symbol', with: 'BADPAIR'
    select 'Up', from: 'Direction'
    fill_in 'Threshold price', with: '100'
    check 'Active'
    click_on 'Create Alert'

    expect(page).to have_content('Symbol is invalid').or have_content('prohibited this alert')
  end

  it 'shows current price when present' do
    alert = create(:alert, last_price: BigDecimal('12345.67'))
    visit alerts_path
    expect(page).to have_selector('table')
    within("#alert_#{alert.id}") do
      expect(page).to have_content('12345.67')
    end
  end

  it 'updates an alert and redirects to index with flash' do
    alert = create(:alert, symbol: 'BTCUSDT', direction: :up, threshold_price: 10000, active: true)

    visit alerts_path
    within("#alert_#{alert.id}") do
      click_on 'Edit'
    end

    uncheck 'Active'
    click_on 'Update Alert'

    expect(page).to have_current_path(alerts_path, ignore_query: true)
    expect(page).to have_content('Alert was successfully updated.')
  end

  it 'deletes an alert and redirects to index with flash' do
    alert = create(:alert, symbol: 'ETHUSDT', direction: :down, threshold_price: 1500, active: true)

    visit alerts_path
    expect(page).to have_selector("#alert_#{alert.id}")

    accept_confirm do
      within("#alert_#{alert.id}") do
        click_on 'Delete'
      end
    end

    expect(page).to have_current_path(alerts_path, ignore_query: true)
    expect(page).to have_content('Alert was successfully destroyed.')
    expect(page).not_to have_selector("#alert_#{alert.id}")
  end
end
