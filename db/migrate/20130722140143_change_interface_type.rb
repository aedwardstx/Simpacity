class ChangeInterfaceType < ActiveRecord::Migration
  def change
    rename_column :interfaces, :type, :link_type
  end
end
