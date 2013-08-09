class CreateSnmps < ActiveRecord::Migration
  def change
    create_table :snmps do |t|
      t.string :name
      t.string :community_string
      t.boolean :default_community, default: false
      t.timestamps
    end
  end
end
