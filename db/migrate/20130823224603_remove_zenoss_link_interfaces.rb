class RemoveZenossLinkInterfaces < ActiveRecord::Migration
  def change
    remove_column :interfaces, :zenossLink, :string
  end
end
