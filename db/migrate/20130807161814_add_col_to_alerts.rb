class AddColToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :days_back, :integer
  end
end
