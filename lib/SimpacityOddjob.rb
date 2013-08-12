#!/usr/bin/env ruby

#Flow
#Crawl Zpollers targets collection to update the interface descriptions and speeds
#delete measurements that are using unconfigured percentiles


require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/root/projects/simpacity'
require "#{simpacity_base}/lib/SimpacityMath"

ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => "#{simpacity_base}/db/development.sqlite3"
)

#Require the Simpacity model files
require "#{simpacity_base}/app/models/interface_group.rb"
require "#{simpacity_base}/app/models/interface_group_relationship.rb"
require "#{simpacity_base}/app/models/interface.rb"
require "#{simpacity_base}/app/models/measurement.rb"
require "#{simpacity_base}/app/models/device.rb"
require "#{simpacity_base}/app/models/snmp.rb"
require "#{simpacity_base}/app/models/setting.rb"


#Slice Size controls how many contiguous measurements are examined at a time,
#also affects percentile calculation, think hard before you change this to something other than 100.
sliceSize = Setting.first.slice_size


