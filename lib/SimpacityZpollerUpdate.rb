#!/usr/bin/env ruby

require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

File.open(Setting.first.zpoller_hosts_location, 'w') do |f2|
  Device.all.each do |device|
    f2.puts "\"#{device.hostname}\",\"#{device.hostname}\",\"#{device.snmp.community_string}\""
  end
end
#run the zpoller config update script
#current_dir = Dir.pwd
Dir.chdir Setting.first.zpoller_base_dir
#system(Setting.first.zconfig_location)
`/usr/local/bin/node #{Setting.first.zconfig_location}`
#Dir.chdir current_dir
