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

#The window defines the lookback time window used when aggregating measurements from multiple interfaces
#   This is needed as collection times maybe skewed between interfaces
#   Move this value to AR in the future
window = Setting.first.link_group_importer_lookback_window

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

InterfaceGroup.all.each do |int_group|
  #if the refresh_next_import bool is true, delete all points in AR for the interface_group
  if int_group.refresh_next_import == true 
    puts "Deleting all entries in AR for #{int_group.id},#{int_group.name} as refresh_next_import was set to true"
    SrlgMeasurement.delete_all(:interface_group_id => int_group.id)
    #int_group.srlg_measurement.destroy_all  
    puts "Done deleting entries, resetting import_checkpoint to nil, and refresh_next_import to false"
    int_group.update(:import_checkpoint => nil, :refresh_next_import => false)
  end

  #bandwidth = get_int_group_bandwidth(int_group.id)

  puts "DEBUG -- interface_group=#{int_group.name}"
  #bandwidth = int_group.bandwidth

  loop do
    if defined? int_group.import_checkpoint
      starting_point_epoch = int_group.import_checkpoint.to_i + 1
      #go to the next interface group if the measurements are too new or its the future
      break if starting_point_epoch + (10 * @polling_interval_secs * sliceSize) > Time.now.to_i
    else
      starting_point_epoch = 1
    end

    write_checkpoint = 0
    checkpoint_epoch = 0
    #foreach noid to collect
    noidsToCollect.each do |noidName,noidShortName|
      sMath = SimpacityMath.new(sliceSize)

      #load the raw data into SimpacityMath
      int_group.interfaces.each do |int|
        puts "Loading data from MongoDB - #{int.device.hostname},#{int.name},#{noidName},#{starting_point_epoch},#{sliceSize}"
        (arrayOfX,arrayOfY) = getRawMeasurements(int.device.hostname, int.name, noidShortName, starting_point_epoch, sliceSize) 
        sMath.loadGroupValues(arrayOfX, arrayOfY, int.id)
      end
      #aggregate all the figures 
      if sMath.aggregateGroupValues(window) == false
        puts "Failed to load values for aggregate group"
        next
      end

      (arrayOfX_unfiltered, arrayOfY_unfiltered) = sMath.getRawVals
      arrayOfX = arrayOfX_unfiltered.shift(sliceSize)
      arrayOfY = arrayOfY_unfiltered.shift(sliceSize)

      if arrayOfX.length == sliceSize and arrayOfY.length == sliceSize
        #find mean 
        sampleX = arrayOfX.reduce(:+) / arrayOfX.length

        arrayOfX_count = arrayOfX.count
        percentiles.each do |percentile|
          if percentile == 100
            #get the average as 100 mean average
            sampleY = arrayOfY.reduce(:+) / arrayOfX_count
          else
            #get the percentile
            indexToGrab = ((100 - percentile).to_f / 100 * arrayOfX_count).ceil - 1
            sampleY = arrayOfY.sort[indexToGrab].to_i
          end

          puts "Debug -- insert into AR - Int_Group=#{int_group.name},noid=#{noidName},percentile=#{percentile},collected_at=#{sampleX},gauge=#{sampleY}"

          #update noids in AR
          int_group.srlg_measurement.create(:noid => noidName, :percentile => percentile, :collected_at => Time.at(sampleX), :gauge => sampleY)
          
        end
        proposed_checkpoint_epoch = arrayOfX.sort[-1]
        checkpoint_epoch = proposed_checkpoint_epoch if proposed_checkpoint_epoch > checkpoint_epoch
        write_checkpoint += 1
      end
    end
    #Write out checkpoint
    if write_checkpoint > 0
      puts "Writting checkpoint for Int Group=#{int_group.name},checkpoint=#{checkpoint_epoch}"
      int_group.update(:import_checkpoint => Time.at(checkpoint_epoch))
    else
      puts "Import Complete for object"
      break
    end
  end
end

