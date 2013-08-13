class CreateDeviceAutoconfRules < ActiveRecord::Migration
  def change
    create_table :device_autoconf_rules do |t|
      t.boolean :enabled
      t.string :network   
      t.string :hostname_regex

      t.timestamps
    end
  end
end
