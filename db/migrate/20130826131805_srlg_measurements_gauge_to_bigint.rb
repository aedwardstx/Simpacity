class SrlgMeasurementsGaugeToBigint < ActiveRecord::Migration
  def change
    remove_column :srlg_measurements, :gauge, :int
    add_column :srlg_measurements, :gauge, :bigint
  end
end
