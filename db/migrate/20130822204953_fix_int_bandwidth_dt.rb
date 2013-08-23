class FixIntBandwidthDt < ActiveRecord::Migration
  def change
    remove_column :interfaces, :bandwidth, :int
    add_column :interfaces, :bandwidth, :bigint
  end
end
