class AdditionalSettings < ActiveRecord::Migration
  def change
    add_column :settings, :polling_interval_secs, :integer
    add_column :settings, :max_trending_future_days, :integer
    
    #setting = Setting.first
    #setting.update(:polling_interval_secs => 15, :max_trending_future_days => 365)

  end
end
