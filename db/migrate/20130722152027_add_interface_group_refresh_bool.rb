class AddInterfaceGroupRefreshBool < ActiveRecord::Migration
  def change
    add_column :interface_groups, :refresh_next_import, :bool
  end
end
