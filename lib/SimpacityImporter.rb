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


#Percentiles 99%,95%,90%,75%,50%,0%(Full Sampling), grab this from AR in the future
percentiles = [1,5,10,25,50,100]

#Slice Size controls how many contiguous measurements are examined at a time, 
#also affects percentile calculation, think hard before you change this to something other than 100. 
sliceSize = Setting.first.slice_size

#Move this definition to AR on a per-interface basis in the future
# This will do a best effort to grab these values from Mongo
#   will need logic to softfail if values are not there
recordsToCollect = ['ifInOctets','ifOutOctets']

#testing parameters as AR is not yet populated
#interfaces = {'router1' => ['Fa0/1','Fa0/0'], 'router2' => ['Fa0/1','Fa0/0']}

@client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
@db     = @client[Setting.first.mongodb_db_name]

def getRawMeasurements(hostname, interface, recordName, startTime, endTime)
  #Passed a hostname, interface, recordName, startTime, endTime
  #puts "getRawMeasurements DEBUG -- hostname=#{hostname},interface=#{interface},recordName=#{recordName},startTime=#{startTime},endTime=#{endTime}"
  collection = "host.#{hostname}"
  xvals = Array.new
  yvals = Array.new

  @db[collection].find({'_id' => {:$gt => startTime.to_i, :$lt => endTime.to_i}}).each do |measurement|
      #puts "line #{measurement['_id']} #{measurement['rate'][interface][recordName]}"
      xvals << measurement['_id']
      yvals << measurement['rate'][interface][recordName]
  end
  return xvals, yvals
end

#TODO -- I think the structure should be changed slightly here,     ---- maybe a studip ideeea
#     change from per-day,per-record,per-percentile  to  per-record,per-day,per-percentile
#     This way, the script will cycle seperately for each measurement
Interface.all.each do |int|
  puts "DEBUG -- interface=#{int},device=#{int.device.hostname}"
  #find first day of data in mongo -- TODO, should not need a loop here, get rid of it
  collection = "host.#{int.device.hostname}"
  firstEntryRef = @db[collection].find.sort( [['_id', :asc]] ).first
  firstEntryEpoch = firstEntryRef['_id']

  #Get time of first sample
  firstSampleTime = Time.at(firstEntryEpoch)

  #Get time for yesterday at end of day and the start of the first sample day
  yesterdayNow = Time.now-86400
  yesterdayEndOfDay = yesterdayNow.change(:hour => 23, :min=> 59, :sec => 59)
  firstSampleTimeMidnight = firstSampleTime.change(:hour => 0) # zero out hrs, mins, secs, usecs
  #firstSampleTimeEndofday = firstSampletime.change(:hour => 23, :min => 59, :sec => 59) # zero out hrs, mins, secs, usecs

  #Increment each day, starting with first sample day and ending with yesterday end of day
  dayIncrement = firstSampleTimeMidnight
  while dayIncrement < yesterdayEndOfDay
    dayIncrementStart = dayIncrement.change(:hour => 0)
    dayIncrement0600 = dayIncrement.change(:hour => 6)
    dayIncrement1800 = dayIncrement.change(:hour => 18)
    dayIncrementEnd = dayIncrement.change(:hour => 23, :min => 59, :sec => 59)
    puts " DEBUG #{dayIncrement}, #{dayIncrementStart.to_i}, #{dayIncrementEnd.to_i}"

    #foreach record to collect
    recordsToCollect.each do |recordToCollect|
      sMath = SimpacityMath.new(sliceSize)
      percentiles.each do |percentile|
        #find existing measurements
        ar_dayIncrement0600 = int.measurements.where(:collected_at => dayIncrement0600,
                                                               :percentile => percentile, :record => recordToCollect)
        ar_dayIncrement1800 = int.measurements.where(:collected_at => dayIncrement1800,
                                                               :percentile => percentile, :record => recordToCollect)

        #is the data already in AR for the day? 
        if ((ar_dayIncrement0600.count == 1) and (ar_dayIncrement1800.count == 1))
          #do nothing
          puts "Doing nothing, #{int.name}, #{dayIncrement0600}, #{dayIncrement1800}, #{percentile}, #{recordToCollect}"
        else
          #Clean up the entries if needed
          ar_dayIncrement0600.destroy_all
          ar_dayIncrement1800.destroy_all

          if not sMath.valuesLoaded
            #load the raw data for the day if not loaded already
            (arrayOfX,arrayOfY) = getRawMeasurements(int.device.hostname, int.name, recordToCollect, dayIncrementStart, dayIncrementEnd)
            #puts "Debug"
            #puts arrayOfX.inspect
            #puts arrayOfY.inspect
            sMath.loadValues(arrayOfX, arrayOfY)
          end
          
          sMath.findSIForPercentile(percentile)
          sampleY0600 = sMath.getYGivenX(dayIncrement0600.to_i)
          sampleY1800 = sMath.getYGivenX(dayIncrement1800.to_i)
          
          puts "Debug -- insert into AR - record=#{recordToCollect},percentile=#{percentile},collected_at=#{dayIncrement0600},gauge=#{sampleY0600}"
          puts "Debug -- insert into AR - record=#{recordToCollect},percentile=#{percentile},collected_at=#{dayIncrement1800},gauge=#{sampleY1800}"

          #update record in AR
          int.measurements.create(:record => recordToCollect, :percentile => percentile, :collected_at => dayIncrement0600, :gauge => sampleY0600)
          int.measurements.create(:record => recordToCollect, :percentile => percentile, :collected_at => dayIncrement1800, :gauge => sampleY1800)
        end
        #unload findings from SimpacityMath
        sMath.trashFindings
      end
      #nil all instance variables from sMath 
      sMath.trashEverything
    end

    #Increment to the next day
    dayIncrement += 86400
  end
end

