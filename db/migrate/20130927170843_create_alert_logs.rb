class CreateAlertLogs < ActiveRecord::Migration
  def change
    create_table :alert_logs do |t|
      t.integer :alert_id
      t.belongs_to :alert
      t.references :alertable, polymorphic: true

      t.datetime :tx_projection
      t.datetime :rx_projection
      t.boolean :acknowledged

      t.timestamps
    end
  end
end
