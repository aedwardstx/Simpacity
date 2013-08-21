class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :slice_size
      t.integer :default_percentile
      t.float :default_watermark
      t.integer :max_hist_dist
      t.integer :default_hist_dist
      t.string :zpoller_rc_location
      t.string :zconfig_location
      t.string :zpoller_hosts_location

      t.timestamps
    end
    #Setting.create :slice_size => '100', :default_percentile => '5', :default_watermark => '0.40', :max_hist_dist => '180', :default_hist_dist => '30', :zpoller_rc_location => '/etc/init.d/zpoller', :zconfig_location => '/usr/local/lib/node_modules/zpoller/bin/zconfig', :zpoller_hosts_location => '/usr/local/lib/node_modules/zpoller/conf/hosts.csv'
  end
end
