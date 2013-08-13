class CreateInterfaceAutoconfRules < ActiveRecord::Migration
  def change
    create_table :interface_autoconf_rules do |t|
      t.boolean :enabled
      t.string :name_regex
      t.string :description_regex
      t.belongs_to :link_type

      t.timestamps
    end
  end
end
