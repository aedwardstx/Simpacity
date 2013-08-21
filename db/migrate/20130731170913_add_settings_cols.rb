class AddSettingsCols < ActiveRecord::Migration
  def change
    add_column :settings, :mongodb_test_window, :integer
    add_column :settings, :zpoller_base_dir, :string
    #@setting = Setting.first
    #@setting.update(:mongodb_test_window => '600', :zpoller_base_dir => '/usr/local/lib/node_modules/zpoller')
  end
end
