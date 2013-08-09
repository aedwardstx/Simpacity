class CreateSrlgMeasurements < ActiveRecord::Migration
  def change
    create_table :srlg_measurements do |t|
      t.belongs_to :interface_group
      t.timestamp :collected_at
      t.integer :percentile
      t.integer :gauge
      t.string :record

      t.timestamps
    end
  end
end



