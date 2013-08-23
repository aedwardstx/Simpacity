class DropUserPrefsTable < ActiveRecord::Migration
  def change
    drop_table :user_preferences
  end
end
