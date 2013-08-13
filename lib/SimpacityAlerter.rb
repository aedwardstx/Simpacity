#!/usr/bin/env ruby

#Flow
#walk the configured alerts and email the contact group associated if needed
# puts 'hell yes' if string.match /#{regex}/
#
#


require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'
require '/root/projects/simpacity/lib/SimpacityExtensionCommon.rb'

require '/root/projects/simpacity/lib/SimpacityAlerterFunctions.rb'


#Slice Size controls how many contiguous measurements are examined at a time,
#also affects percentile calculation, think hard before you change this to something other than 100.
sliceSize = Setting.first.slice_size

records = ['ifInOctets','ifOutOctets']
now = Time.now
end_time = now - 1.day
end_time = end_time.change(:hour => 23, :min=> 59, :sec => 59)
end_epoch = end_time.to_i


Alert.all.each do |alert|
  start_time = now - (alert.days_back * 86400)
  start_time = start_time.change(:hour => 0)
  start_epoch = start_time.to_i

  #puts alert.inspect
  if alert.enabled == true
    if alert.int_type == 'interface'
      Interface.all.each do |int|
        if ((int.link_type.id == alert.link_type.id) and !!("#{int.name}#{int.description}".match(/#{alert.match_regex}/)))
          records.each do |record|
            #puts int.id, alert.percentile, record, start_epoch, end_epoch, alert.watermark, alert.days_out
            projection = get_int_projection(int.id, alert.percentile, record, start_epoch, end_epoch, alert.watermark, alert.days_out)
            #puts projection.inspect
            if projection <= alert.days_out
              #generate alert
              puts "Alert fired for Alert.name: #{alert.name}, Int.id: #{int.id}, Int.device.hostname: #{int.device.hostname}, Int.name: #{int.name}, Record: #{record}, Projection: #{projection}"
            end
          end
        end
      end
    elsif alert.int_type == 'interface_group'
      InterfaceGroups.each do |int_group|
        records.each do |record|
          projection = get_int_group_projection(int_group.id, alert.percentile, record, start_epoch, end_epoch, alert.watermark, alert.days_out)
          if projection <= alert.days_out
            #generate alert
            puts "Alert fired for Alert.name: #{alert.name}, Int_group.id: #{int_group.id}, Projection: #{projection}"
          end
        end
      end
    end
  end
end

