class ChangeIntAndIntGroup < ActiveRecord::Migration
  def change
    add_column :interfaces, :import_checkpoint, :datetime
    add_column :interface_groups, :import_checkpoint, :datetime
  end
end
