#!/usr/bin/env ruby

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
#noidsToCollect = ['ifInOctets','ifOutOctets']
#Provides a mapping for common name to the shorthand name used in the DB
noidsToCollect = { 'ifInOctets' => 'i', 'ifOutOctets' => 'o'}


now = Time.now
end_time = now - 1.day
end_time = end_time.change(:hour => 23, :min=> 59, :sec => 59)
end_epoch = end_time.to_i
min_alert_measurements_percent = Setting.first.min_alert_measurements_percent.to_f / 100

Alert.all.each do |alert|
  start_time = now - (alert.days_back * 86400)
  start_time = start_time.change(:hour => 0)
  start_epoch = start_time.to_i
  puts "Alert #{alert.name}, #{alert.int_type}, #{alert.link_type.name}, #{alert.match_regex}, #{alert.percentile}, #{alert.watermark}, days_out: #{alert.days_out}, days_back:#{alert.days_back}"

  #puts "Debug #{start_epoch} - #{end_epoch} #{alert.inspect}"
  #puts alert.inspect
  if alert.enabled == true
    if alert.int_type == 'interface'
      Interface.all.each do |int|
        if ((int.link_type.id == alert.link_type.id) and !!("#{int.name}#{int.description}".match(/#{alert.match_regex}/)))
          #foreach noid to collect
          noidsToCollect.each do |noidName,noidShortName|

            #check if there are at least xx% of the expected noids.  TODO - This is a bad way to do this, use a where to grab first and last instead
            (temp_times, temp_gauges) = get_int_measurements(int.id, alert.percentile, noidName, start_epoch, end_epoch)
            next if temp_times.length == 0
            measurement_duration_sec = temp_times.sort[-1] - temp_times.sort[0]
            alert_lookback_duration = end_epoch - start_epoch

            puts "  Debug measurements length #{measurement_duration_sec} #{min_alert_measurements_percent * alert_lookback_duration}"

            projection = get_int_projection(int.id, alert.percentile, noidName, start_epoch, end_epoch, alert.watermark, Setting.first.max_trending_future_days)
            #puts projection.inspect
            puts "  "
            #skip this alert if we are not already in an exhaustion situation and we dont think there will be enough measurements
            if projection > 1 and measurement_duration_sec < (min_alert_measurements_percent * alert_lookback_duration)
              puts "    Skipping as there is not enough data: #{int.device.hostname}_#{int.name}, #{projection} days"
              #if there is an alert for this already, delete it
              int.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
              next
            elsif projection <= alert.days_out
              #generate alert
              puts "    Alert fired for Alert.name: #{alert.name}, Int.id: #{int.id}, Int.device.hostname: #{int.device.hostname}, Int.name: #{int.name}, Record: #{noidName}, Projection: #{projection}"
              alert_log_entry = int.alert_logs.where(:noid => noidName, :alert_id => alert.id).first
              if alert_log_entry
                alert_log_entry.update(:noid => noidName, :projection => projection.days.from_now, :alert_id => alert.id)
              else
                int.alert_logs.create(:noid => noidName, :projection => projection.days.from_now, :alert_id => alert.id)
              end
            else
              #if there is an alert for this already, delete it
              int.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
            end
          end
        end
      end
    elsif alert.int_type == 'interface-group'
      InterfaceGroup.all.each do |int_group|
        #foreach noid to collect
        noidsToCollect.each do |noidName,noidShortName|
          #check if there are at least xx% of the expected noids. TODO - This is a bad way to do this, use a where to grab first and last instead
          (temp_times, temp_gauges) = get_int_group_measurements(int_group.id, alert.percentile, noidName, start_epoch, end_epoch)
          next if temp_times.length == 0
          measurement_duration_sec = temp_times.sort[-1] - temp_times.sort[0]
          alert_lookback_duration = end_epoch - start_epoch

          projection = get_int_group_projection(int_group.id, alert.percentile, noidName, start_epoch, end_epoch, alert.watermark, Setting.first.max_trending_future_days)
          #puts projection.inspect

          puts "Debug measurements length #{measurement_duration_sec} #{min_alert_measurements_percent * alert_lookback_duration}"
          #skip this alert if we are not already in an exhaustion situation and we dont think there will be enough measurements
          if projection > 1 and measurement_duration_sec < (min_alert_measurements_percent * alert_lookback_duration)
            puts "Skipping as there is not enough data: #{int_group.name}, #{projection} days"
            #if there is an alert for this already, delete it
            int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
            next
          elsif projection <= alert.days_out
            #generate alert
            puts "Alert fired for Alert.name: #{alert.name}, Int_group.id: #{int_group.id}, Int_group.name: #{int_group.name}, Record: #{noidName}, Projection: #{projection}"
            alert_log_entry = int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).first
            if alert_log_entry
              alert_log_entry.update(:noid => noidName, :projection => projection.days.from_now, :alert_id => alert.id)
            else
              int_group.alert_logs.create(:noid => noidName, :projection => projection.days.from_now, :alert_id => alert.id)
            end
          else
            #if there is an alert for this already, delete it
            int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
          end
        end
      end
    end
  end
end

