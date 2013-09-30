class CreateAverages < ActiveRecord::Migration
  def change
    create_table :averages do |t|
      t.references :averageable, polymorphic: true
      t.string :record
      t.integer :percentile
      t.timestamps
    end
    add_column :averages, :gauge, :bigint
  end
end
