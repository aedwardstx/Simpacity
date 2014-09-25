#!/usr/bin/env ruby

require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

@min_Bps_for_inclusion = Setting.first.min_bps_for_inclusion / 8 
@polling_interval_secs = Setting.first.polling_interval_secs

#Percentiles 99%,95%,90%,75%,50%,0%(Full Sampling), grab this from AR in the future
percentiles = [1,5,10,25,50,100]

#Slice Size controls how many contiguous measurements are examined at a time, 
#also affects percentile calculation, think hard before you change this to something other than 100. 
sliceSize = Setting.first.slice_size

#Move this definition to AR on a per-interface basis in the future
# This will do a best effort to grab these values from Mongo
#   will need logic to softfail if values are not there
#noidsToCollect = ['ifInOctets','ifOutOctets']
#Provides a mapping for common name to the shorthand name used in the DB
noidsToCollect = { 'ifInOctets' => 'i', 'ifOutOctets' => 'o'}

@client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
@db     = @client[Setting.first.mongodb_db_name]


def getRawMeasurements(hostname, interface, noidName, starting_point_epoch, sliceSize)
  #Passed a hostname, interface, noidName, startTime, endTime
  #puts "getRawMeasurements DEBUG -- hostname=#{hostname},interface=#{interface},noidName=#{noidName},startTime=#{startTime},endTime=#{endTime}"
  collection = "host.#{hostname}"
  xvals = Array.new
  yvals = Array.new

  puts "Getting raw measurements: collection: #{collection}, $gt: #{starting_point_epoch}, $lt: #{Time.now.to_i}, #{interface}, #{noidName}, #{@min_Bps_for_inclusion}, #{interface}, #{sliceSize}"
  @db[collection].find({'_id' => {:$gt => starting_point_epoch, :$lt => Time.now.to_i}, "rate.#{interface}.#{noidName}" => {:$gt => @min_Bps_for_inclusion}}, :fields => "rate.#{interface}", :sort => ['_id', Mongo::ASCENDING], :limit => sliceSize).each do |measurement|
    if defined? measurement['rate'][interface][noidName] and measurement['rate'][interface][noidName].is_a? Integer
      gauge = measurement['rate'][interface][noidName] * 8  
      #puts "line #{measurement['_id']} #{gauge}"
      xvals << measurement['_id']
      yvals << gauge
    else
      puts "skipping measurement as not defined -- this should never really happen"
    end
  end

  return xvals, yvals
end
  
Interface.all.each do |int|
  puts "DEBUG -- interface=#{int.name},device=#{int.device.hostname}"

  loop do
    if defined? int.import_checkpoint
      starting_point_epoch = int.import_checkpoint.to_i + 1
      #go to the next interface if the measurements are too new or its the future
      break if starting_point_epoch + (10 * @polling_interval_secs * sliceSize) > Time.now.to_i
    else
      starting_point_epoch = 1
    end

    write_checkpoint = 0
    checkpoint_epoch = 0
    #foreach noid to collect
    noidsToCollect.each do |noidName,noidShortName|
      #load the raw data for the day if not loaded already
      (arrayOfX,arrayOfY) = getRawMeasurements(int.device.hostname, int.name, noidShortName, starting_point_epoch, sliceSize)

      #should add a check here to prevent this from rening unless the sliceSize is satisfied
      #if arrayOfX.length > 0
      if arrayOfX.length == sliceSize and arrayOfY.length == sliceSize
        #find mean 
        sampleX = arrayOfX.reduce(:+) / arrayOfX.length

        arrayOfX_count = arrayOfX.count
        #puts "#{arrayOfX_count}/#{arrayOfY.count}"
        percentiles.each do |percentile|
          
          #In order to keep the sort target from returning nil, have to handle the percentile averaging differently
          #if arrayOfX_count < percentile #percentile is larger than arrayOfX_count
          #  sampleY = arrayOfY.inject{ |sum, element| sum + element }.to_f / arrayOfX_count
          #else #percentile is less than or equal to arrayOfX_count
            #sampleY = arrayOfY.sort[-percentile..-1].inject{ |sum, element| sum + element }.to_f / percentile 
          
          if percentile == 100
            #get the average as 100 mean average
            sampleY = arrayOfY.reduce(:+) / arrayOfX_count
          else
            #get the percentile
            indexToGrab = ((100 - percentile).to_f / 100 * arrayOfX_count).ceil - 1 
            sampleY = arrayOfY.sort[indexToGrab].to_i 
          end
          #end

          puts "Debug -- insert into AR - hostname=#{int.device.hostname},interface=#{int.name},noid=#{noidName},percentile=#{percentile},collected_at=#{sampleX},gauge=#{sampleY}"

          #update noids in AR
          int.measurements.create(:noid => noidName, :percentile => percentile, :collected_at => Time.at(sampleX), :gauge => sampleY)
          
        end
        proposed_checkpoint_epoch = arrayOfX.sort[-1]
        checkpoint_epoch = proposed_checkpoint_epoch if proposed_checkpoint_epoch > checkpoint_epoch
        write_checkpoint += 1
      end
    end
    #Write out checkpoint
    if write_checkpoint > 0
      puts "Writting checkpoint for hostname=#{int.device.hostname},interface=#{int.name},checkpoint=#{checkpoint_epoch}"
      int.update(:import_checkpoint => Time.at(checkpoint_epoch))
    else
      puts "Import Complete for object"
      break
    end
  end
end
