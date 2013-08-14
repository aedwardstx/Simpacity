#!/usr/bin/env ruby

#Flow
#
#Description and Bandwidth Updating
# Crawl Zpollers targets collection to update the interface descriptions and speeds
#
#Unconfigured Percentiles Handling
# delete measurements that are using unconfigured percentiles
#   Will need to configure percentiles in AR for this, WAIT for percentile revamp
#
#
#


require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/root/projects/simpacity'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"


#Slice Size controls how many contiguous measurements are examined at a time,
#also affects percentile calculation, think hard before you change this to something other than 100.
sliceSize = Setting.first.slice_size


