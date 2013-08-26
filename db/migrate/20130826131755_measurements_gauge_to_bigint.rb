class MeasurementsGaugeToBigint < ActiveRecord::Migration
  def change
    remove_column :measurements, :gauge, :int
    add_column :measurements, :gauge, :bigint
  end
end
