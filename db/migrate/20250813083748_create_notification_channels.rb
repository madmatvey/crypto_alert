class CreateNotificationChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_channels do |t|
      t.integer :kind, null: false
      t.jsonb :settings, null: false, default: {}
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end

    add_index :notification_channels, :kind
  end
end
