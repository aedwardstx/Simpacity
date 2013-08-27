class AdditionSettings < ActiveRecord::Migration
  def change
    add_column :settings, :min_alert_measurements_percent, :integer
    add_column :settings, :min_bps_for_inclusion, :bigint
    add_column :settings, :source_email_address, :string
  end
end
