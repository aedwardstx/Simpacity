class CreateLinkTypes < ActiveRecord::Migration
  def change
    create_table :link_types do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
