class RemoveDeviceSnmpCol < ActiveRecord::Migration
  def change
    remove_column :devices, :snmp_community, :string
  end
end
