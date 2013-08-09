class MeasurementChangeColumnname < ActiveRecord::Migration
  def change
    rename_column :measurements, :collectedAt, :collected_at
  end
end
