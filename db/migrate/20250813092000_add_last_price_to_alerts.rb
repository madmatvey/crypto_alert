class AddLastPriceToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :last_price, :decimal, precision: 18, scale: 8
  end
end
