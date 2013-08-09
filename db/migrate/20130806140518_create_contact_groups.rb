class CreateContactGroups < ActiveRecord::Migration
  def change
    create_table :contact_groups do |t|
      t.string :name
      t.text :description
      t.text :email_addresses

      t.timestamps
    end
  end
end
