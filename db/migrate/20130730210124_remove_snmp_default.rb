class RemoveSnmpDefault < ActiveRecord::Migration
  def change
    remove_column :snmps, :default_community, :boolean
  end
end
