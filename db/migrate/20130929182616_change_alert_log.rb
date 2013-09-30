class ChangeAlertLog < ActiveRecord::Migration
  def change
    remove_column :alert_logs, :rx_projection, :datetime
    remove_column :alert_logs, :tx_projection, :datetime
    add_column :alert_logs, :projection, :datetime
    add_column :alert_logs, :record, :string
  end
end
