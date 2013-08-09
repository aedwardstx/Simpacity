class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.boolean :enabled
      t.string :name
      t.text :description
      t.string :int_type  #TODO -- find a better name for this, it bugs me :-/ -- to determine if an interface or interface_group
      t.belongs_to :link_type
      t.string :match_regex
      t.integer :percentile #maybe there should be a limit here or in the model - 1-100
      t.float :watermark  #maybe there should be a limit here or in the model - 0.000001-1.00
      t.integer :days_out
      t.belongs_to :contact_group

      t.timestamps
    end
  end
end
