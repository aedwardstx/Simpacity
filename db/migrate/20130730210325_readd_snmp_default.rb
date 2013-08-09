class ReaddSnmpDefault < ActiveRecord::Migration
  def change
    add_column :snmps, :default_community, :boolean
  end
end
