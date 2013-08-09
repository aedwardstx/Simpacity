class Setting < ActiveRecord::Base

  validates_presence_of :slice_size
  validates_presence_of :default_percentile
  validates_presence_of :default_watermark
  validates_presence_of :max_hist_dist
  validates_presence_of :default_hist_dist
  validates_presence_of :zpoller_rc_location
  validates_presence_of :zconfig_location
  validates_presence_of :zpoller_hosts_location
  validates_presence_of :zpoller_base_dir
  validates_presence_of :mongodb_test_window
  validates_presence_of :mongodb_db_hostname
  validates_presence_of :mongodb_db_port
  validates_presence_of :mongodb_db_name

end
