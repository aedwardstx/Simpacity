class AddMoreSettings < ActiveRecord::Migration
  def change
    add_column :settings, :link_group_importer_lookback_window, :integer
    add_column :settings, :zpoller_poller_interval, :integer
    add_column :settings, :mailhost, :string

    @setting = Setting.first
    @setting.update(:link_group_importer_lookback_window => 15, :zpoller_poller_interval => 15, :mailhost => 'mailhost.rackspace.com')
  end
end
