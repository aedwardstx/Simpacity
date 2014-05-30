class ChangeRecordToNoid < ActiveRecord::Migration
  def change
    rename_column :alert_logs, :record, :noid
    rename_column :averages, :record, :noid
    rename_column :srlg_measurements, :record, :noid
    rename_column :measurements, :record, :noid
  end
end
