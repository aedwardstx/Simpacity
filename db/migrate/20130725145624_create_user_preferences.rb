class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.string :session_id
      t.string :percentile
      t.string :historical_distance
      t.integer :high_watermark
      t.timestamps
    end
  end
end
