class AddSettingsCols < ActiveRecord::Migration
  def change
    add_column :settings, :zpoller_base_dir, :string
    add_column :settings, :mongodb_test_window, :integer
    @setting = Setting.first
    @setting.update(:zpoller_base_dir => '/usr/local/lib/node_modules/zpoller', :mongodb_test_window => '600')
  end
end
