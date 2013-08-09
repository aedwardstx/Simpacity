class DropSnmps < ActiveRecord::Migration
  def change
    drop_table :snmps
  end
end
