class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.string :symbol, null: false
      t.integer :direction, null: false
      t.decimal :threshold_price, precision: 18, scale: 8, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :alerts, :symbol
    add_index :alerts, :direction
    add_index :alerts, [ :symbol, :direction ]
  end
end
