class MeasurementAddRecord < ActiveRecord::Migration
  def change
    add_column :measurements, :record, :string
  end
end
