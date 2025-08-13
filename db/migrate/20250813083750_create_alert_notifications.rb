class CreateAlertNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_notifications do |t|
      t.references :alert, null: false, foreign_key: true
      t.references :notification_channel, null: false, foreign_key: true
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
