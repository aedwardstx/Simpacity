class SettingAddAverageLookback < ActiveRecord::Migration
  def change
    add_column :settings, :average_previous_hours, :integer
  end
end
