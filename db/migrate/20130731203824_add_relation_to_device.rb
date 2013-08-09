class AddRelationToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :snmp_id, :integer
    add_column :settings, :mongodb_db_hostname, :string
    add_column :settings, :mongodb_db_port, :integer
    add_column :settings, :mongodb_db_name, :string
  end
end
