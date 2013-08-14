#!/usr/bin/env ruby

#foreach interfaceGroup   
# if the refresh flag set(i.e. interface associations were changed)
#   delete all measurements for the interfaceGroup in AR
# foreach day of data in the mongodb, for the set of interfaces in the group(should data for all int be mandidtory for the period?)
#   foreach recorded counter configured(RxOctets, TxOctets, etc.)
#     foreach percentile configured
#       determine if data is recorded in AR
#       if not
#         run the calulation on the data and record it
#       else
#         do nothing
#
#

require 'rubygems'
require 'mongo'
require 'pp'
include Mongo
gem 'activerecord'
#require 'sqlite3'
require 'active_record'
require 'benchmark'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/root/projects/simpacity'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"


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
recordsToCollect = ['ifInOctets','ifOutOctets']

@client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
@db     = @client[Setting.first.mongodb_db_name]

def getRawMeasurements(hostname, interface, recordName, startTime, endTime)
  #Passed a hostname, interface, recordName, startTime, endTime
  #puts "getRawMeasurements DEBUG -- hostname=#{hostname},interface=#{interface},recordName=#{recordName},startTime=#{startTime},endTime=#{endTime}"
  collection = "host.#{hostname}"
  xvals = Array.new
  yvals = Array.new

  #TODO PERFORMANCE This could be a slowdown, see if there is a way to directly map 
  @db[collection].find({'_id' => {:$gt => startTime.to_i, :$lt => endTime.to_i}}).each do |measurement|
      #puts "line #{measurement['_id']} #{measurement['rate'][interface][recordName]}"
      xvals << measurement['_id']
      yvals << measurement['rate'][interface][recordName]
  end
  return xvals, yvals
end

yesterdayNow = Time.now-86400
yesterdayEndOfDay = yesterdayNow.change(:hour => 23, :min=> 59, :sec => 59)


InterfaceGroup.all.each do |int_group|
  #if the refresh_next_import bool is true, delete all points in AR for the interface_group
  if int_group.refresh_next_import == 1 
    puts "Deleting all entries in AR for #{int_group.name} as refresh_next_import was set to true"
    int_group.srlg_measurement.destroy_all  #delete_all may be faster and all thats needed
    int_group.refresh_next_import = 0
    int_group.save
  end

  #Find the earliest mongodb entry for the interface group
  firstEntryEpoch = Time.now.to_i 
  int_group.interfaces.each do |int|
    puts "DEBUG -- interface=#{int.name},device=#{int.device.hostname}"
    #find first day of data in mongo -- TODO, should not need a loop here, get rid of it
    collection = "host.#{int.device.hostname}"

    #puts @db[collection].find.sort( [['_id', :asc]] ).inspect
    firstEntryRef = @db[collection].find.sort( [['_id', :asc]] ).first
    firstEntryEpoch = firstEntryRef['_id'] if firstEntryRef['_id'] < firstEntryEpoch
  end
  firstSampleTime = Time.at(firstEntryEpoch)
  #puts "DEBUG HERE -- #{firstSampleTime}"
  #Get time for yesterday at end of day and the start of the first sample day
  firstSampleTimeMidnight = firstSampleTime.change(:hour => 0) # zero out hrs, mins, secs, usecs


  #cycle through the days
  dayIncrement = firstSampleTimeMidnight
  while dayIncrement < yesterdayEndOfDay
    dayIncrementStart = dayIncrement.change(:hour => 0)
    dayIncrement0600 = dayIncrement.change(:hour => 6)
    dayIncrement1800 = dayIncrement.change(:hour => 18)
    dayIncrementEnd = dayIncrement.change(:hour => 23, :min => 59, :sec => 59)
    puts " DEBUG #{dayIncrement}, #{dayIncrementStart.to_i}, #{dayIncrementEnd.to_i}"
    
    recordsToCollect.each do |recordToCollect|
      sMath = SimpacityMath.new(sliceSize)
      percentiles.each do |percentile|
        ar_dayIncrement0600 = int_group.srlg_measurement.where(:collected_at => dayIncrement0600, 
                                                               :percentile => percentile, :record => recordToCollect) 
        ar_dayIncrement1800 = int_group.srlg_measurement.where(:collected_at => dayIncrement1800, 
                                                               :percentile => percentile, :record => recordToCollect)  
        if ((ar_dayIncrement0600.count == 1) and (ar_dayIncrement1800.count == 1))
          #do nothing
          puts "Doing nothing, #{int_group.name}, #{dayIncrement0600}, #{dayIncrement1800}, #{percentile}, #{recordToCollect}"
        else
          puts "Starting else loop"

          #Clean up the entries if needed 
          ar_dayIncrement0600.destroy_all
          ar_dayIncrement1800.destroy_all

          #load the raw data for the day,int_group,recrod if not loaded already
          if not sMath.valuesLoaded
            int_group.interfaces.each do |int|
              puts "Loading data from MongoDB - #{int.device.hostname},#{int.name},#{recordToCollect},#{dayIncrementStart},#{dayIncrementEnd}"
              (arrayOfX,arrayOfY) = getRawMeasurements(int.device.hostname, int.name, recordToCollect, dayIncrementStart, dayIncrementEnd) 
              sMath.loadGroupValues(arrayOfX, arrayOfY, int.id)
            end
            #aggregate all the figures -- TODO PERFORMANCE benchmark(0.16-0.25) 
            sMath.aggregateGroupValues(window) 
          end

          #call simacityMath
          sMath.findSIForPercentile(percentile)
          sampleY0600 = sMath.getYGivenX(dayIncrement0600.to_i)
          sampleY1800 = sMath.getYGivenX(dayIncrement1800.to_i)
          
          #update record in AR
          puts "Debug -- insert into AR - record=#{recordToCollect},percentile=#{percentile},collected_at=#{dayIncrement0600},gauge=#{sampleY0600}"
          int_group.srlg_measurement.create(:record => recordToCollect, :percentile => percentile, :collected_at => dayIncrement0600, :gauge => sampleY0600)
          puts "Debug -- insert into AR - record=#{recordToCollect},percentile=#{percentile},collected_at=#{dayIncrement1800},gauge=#{sampleY1800}"
          int_group.srlg_measurement.create(:record => recordToCollect, :percentile => percentile, :collected_at => dayIncrement1800, :gauge => sampleY1800)
        end
      end
      sMath.trashEverything
    end
    #Increment to the next day
    dayIncrement += 86400
  end
end
