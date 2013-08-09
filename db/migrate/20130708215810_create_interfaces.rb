class CreateInterfaces < ActiveRecord::Migration
  def change
    create_table :interfaces do |t|
      t.belongs_to :device
      t.string :type
      t.string :description
      t.string :name
      t.integer :bandwidth
      t.string :zenossLink
      t.timestamps
    end

    create_table :interface_groups do |t|
      t.string :description
      t.string :name
      t.timestamps
    end

    create_table :devices do |t|
      t.string :description
      t.string :hostname
      t.timestamps
    end

    create_table :interface_group_relationships do |t|
      t.belongs_to :interface
      t.belongs_to :interface_group
      t.timestamps
    end

    create_table :measurements do |t|
      t.belongs_to :interface
      t.integer :rx
      t.integer :tx
      t.timestamp :collectedAt
      t.timestamps
    end
  end
end
