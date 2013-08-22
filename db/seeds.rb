# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Setting.delete_all
Setting.create  :slice_size => 100, 
                :default_percentile => 5, 
                :default_watermark => 0.40, 
                :max_hist_dist => 180, 
                :default_hist_dist => 30, 
                :zpoller_rc_location => '/etc/init.d/zpoller', 
                :zconfig_location => '/usr/local/lib/node_modules/zpoller/bin/zconfig', 
                :zpoller_hosts_location => '/usr/local/lib/node_modules/zpoller/conf/hosts.csv',
                :mongodb_test_window => 600, 
                :zpoller_base_dir => '/usr/local/lib/node_modules/zpoller',
                :link_group_importer_lookback_window => 15, 
                :zpoller_poller_interval => 15, 
                :mailhost => 'mailout.rackspace.com',
                :polling_interval_secs => 15, 
                :max_trending_future_days => 365,
                :mongodb_db_hostname => 'localhost', 
                :mongodb_db_port => 27017, 
                :mongodb_db_name => 'zpoller'
