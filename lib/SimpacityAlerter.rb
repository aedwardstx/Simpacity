#!/usr/bin/env ruby

#Flow
#walk the configured alerts and email the contact group associated if needed
#
#
#TODO
#need to add a minimum data-points requirement to avoid an alert being generated prematurely


require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'


#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

require "#{simpacity_base}/app/helpers/frontend_helper.rb"
require "#{simpacity_base}/app/helpers/alerts_helper.rb"
include FrontendHelper
include AlertsHelper


#Slice Size controls how many contiguous measurements are examined at a time,
#also affects percentile calculation, think hard before you change this to something other than 100.
sliceSize = Setting.first.slice_size

#Move this definition to AR on a per-interface basis in the future
# This will do a best effort to grab these values from Mongo
#   will need logic to softfail if values are not there
#recordsToCollect = ['ifInOctets','ifOutOctets']
#Provides a mapping for common name to the shorthand name used in the DB
recordsToCollect = { 'ifInOctets' => 'i', 'ifOutOctets' => 'o'}


now = Time.now
end_time = now - 1.day
end_time = end_time.change(:hour => 23, :min=> 59, :sec => 59)
end_epoch = end_time.to_i
min_alert_measurements_percent = Settings.min_alert_measurements_percent.first.to_f / 100

Alert.all.each do |alert|
  start_time = now - (alert.days_back * 86400)
  start_time = start_time.change(:hour => 0)
  start_epoch = start_time.to_i

  #puts alert.inspect
  if alert.enabled == true
    if alert.int_type == 'interface'
      Interface.all.each do |int|
        if ((int.link_type.id == alert.link_type.id) and !!("#{int.name}#{int.description}".match(/#{alert.match_regex}/)))
          #foreach record to collect
          recordsToCollect.each do |recordName,recordShortName|

            #check if there are at least xx% of the expected records
            (temp_times, temp_gauges) = get_int_measurements(int.id, alert.percentile, recordShortName, start_epoch, end_epoch)
            puts "Debug measurements length #{temp_gauges.length < ( min_alert_measurements_percent * ((end_epoch - start_epoch) / 86400.0 * 2).ceil )}"
            next if temp_gauges.length < ( min_alert_measurements_percent * ((end_epoch - start_epoch) / 86400.0 * 2).ceil ) 

            #puts int.id, alert.percentile, record, start_epoch, end_epoch, alert.watermark, alert.days_out
            projection = get_int_projection(int.id, alert.percentile, recordShortName, start_epoch, end_epoch, alert.watermark, alert.days_out)
            #puts projection.inspect
            if projection <= alert.days_out
              #generate alert
              puts "Alert fired for Alert.name: #{alert.name}, Int.id: #{int.id}, Int.device.hostname: #{int.device.hostname}, Int.name: #{int.name}, Record: #{recordName}, Projection: #{projection}"
            end
          end
        end
      end
    elsif alert.int_type == 'interface_group'
      InterfaceGroups.each do |int_group|
        #foreach record to collect
        recordsToCollect.each do |recordName,recordShortName|
          projection = get_int_group_projection(int_group.id, alert.percentile, recordShortName, start_epoch, end_epoch, alert.watermark, alert.days_out)
          if projection <= alert.days_out
            #generate alert
            puts "Alert fired for Alert.name: #{alert.name}, Int_group.id: #{int_group.id}, Record: #{recordName}, Projection: #{projection}"
          end
        end
      end
    end
  end
end

