#!/usr/bin/env ruby

#import flow
#gather a list of interfaces from active record
#get devices from AR
#foreach device.interface
#  foreach day of data in the mongodb
#    foreach recorded counter configured(RxOctets, TxOctets, etc.)
#      foreach percentile configured
#        determine if data is recorded in AR 
#        if not
#          run the calulation on the data and record it
#        else
#          do nothing

require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"


#Percentiles 99%,95%,90%,75%,50%,0%(Full Sampling), grab this from AR in the future
percentiles = [1,5,10,25,50,100]

#Slice Size controls how many contiguous measurements are examined at a time, 
#also affects percentile calculation, think hard before you change this to something other than 100. 
sliceSize = Setting.first.slice_size

#Move this definition to AR on a per-interface basis in the future
# This will do a best effort to grab these values from Mongo
#   will need logic to softfail if values are not there
#recordsToCollect = ['ifInOctets','ifOutOctets']
#Provides a mapping for common name to the shorthand name used in the DB
recordsToCollect = { 'ifInOctets' => 'i', 'ifOutOctets' => 'o'}

#testing parameters as AR is not yet populated
#interfaces = {'router1' => ['Fa0/1','Fa0/0'], 'router2' => ['Fa0/1','Fa0/0']}

@client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
@db     = @client[Setting.first.mongodb_db_name]


def getRawMeasurements(hostname, interface, recordName, starting_point_epoch, sliceSize)
  #Passed a hostname, interface, recordName, startTime, endTime
  #puts "getRawMeasurements DEBUG -- hostname=#{hostname},interface=#{interface},recordName=#{recordName},startTime=#{startTime},endTime=#{endTime}"
  min_Bps_for_inclusion = Setting.first.min_bps_for_inclusion / 8 
  collection = "host.#{hostname}"
  xvals = Array.new
  yvals = Array.new

  @db[collection].find({'_id' => {:$gt => startTime.to_i, :$lt => Time.now.to_i}, "rate.#{interface}.#{recordName}" => {:$gt => min_Bps_for_inclusion}}, :fields => "rate.#{interface}", :sort => ['_id', Mongo::ASCENDING], :limit => sliceSize).each do |measurement|
    if defined? measurement['rate'][interface][recordName] and measurement['rate'][interface][recordName].is_a? Integer
      gauge = measurement['rate'][interface][recordName] * 8  
      #puts "line #{measurement['_id']} #{gauge}"
      xvals << measurement['_id']
      yvals << gauge
    else
      puts "skipping measurement as not defined -- this should never really happen"
    end
  end
  return xvals, yvals
end

#TODO -- I think the structure should be changed slightly here,     ---- maybe a studip ideeea
#     change from per-day,per-record,per-percentile  to  per-record,per-day,per-percentile
#     This way, the script will cycle seperately for each measurement
Interface.all.each do |int|
  puts "DEBUG -- interface=#{int.name},device=#{int.device.hostname}"
  bandwidth = int.bandwidth
  collection = "host.#{int.device.hostname}"

  if defined? int.import_checkpoint
    starting_point_epoch = int.import_checkpoint.to_i + 1
    #go to the next interface if the measurements are too new or its the future
    next if starting_point_epoch + (10 * Setting.first.polling_interval_secs * Setting.first.slice_size) > Time.now
  else
    firstEntryRef = @db[collection].find.sort( [['_id', :asc]] ).first
    firstEntryEpoch = firstEntryRef['_id']
    starting_point_epoch = firstEntryEpoch
  end

  #foreach record to collect
  recordsToCollect.each do |recordName,recordShortName|
    sMath = SimpacityMath.new(sliceSize)
    percentiles.each do |percentile|
      #load the raw data for the day if not loaded already
      (arrayOfX,arrayOfY) = getRawMeasurements(int.device.hostname, int.name, recordShortName, starting_point_epoch, sliceSize)
      #puts arrayOfX.inspect
      #puts arrayOfY.inspect
      sMath.loadValues(arrayOfX, arrayOfY)
      if sMath.valuesLoaded 
        sMath.findSIForPercentile(percentile)
        sampleY0600 = sMath.getYGivenX(dayIncrement0600.to_i)
       
        puts "Debug -- insert into AR - record=#{recordName},percentile=#{percentile},collected_at=#{dayIncrement0600},gauge=#{sampleY0600}"

        #update record in AR
        int.measurements.create(:record => recordName, :percentile => percentile, :collected_at => dayIncrement0600, :gauge => sampleY0600)
      else
        puts "Values missing for time period"
      end
      #unload findings from SimpacityMath
      sMath.trashFindings
    end
    #nil all instance variables from sMath 
    sMath.trashEverything
  end

end

