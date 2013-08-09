class MeasurementChangeColumns < ActiveRecord::Migration
  def change
    add_column :measurements, :percentile, :integer
    add_column :measurements, :gauge, :integer
    remove_column :measurements, :tx, :integer
    remove_column :measurements, :rx, :integer
  end
end
