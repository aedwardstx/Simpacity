class AddLevel < ActiveRecord::Migration
  def change
    add_column :alerts, :severity, :int
  end
end
