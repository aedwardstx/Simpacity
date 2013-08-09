class ChangeLinktype < ActiveRecord::Migration
  def change
     remove_column :interfaces, :link_type, :string
     add_column :interfaces, :link_type_id, :integer

  end
end
