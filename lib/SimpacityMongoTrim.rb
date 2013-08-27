require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

recordsToCollect = { 'ifInOctets' => 'i', 'ifOutOctets' => 'o'}

def getRawMeasurements(hostname, interface, recordName, startTime, endTime)
  #Passed a hostname, interface, recordName, startTime, endTime
  #puts "getRawMeasurements DEBUG -- hostname=#{hostname},interface=#{interface},recordName=#{recordName},startTime=#{startTime},endTime=#{endTime}"
  collection = "host.#{hostname}"
  xvals = Array.new
  yvals = Array.new

  @db[collection].find({'_id' => {:$gt => startTime.to_i, :$lt => endTime.to_i}}).each do |measurement|
      #puts "line #{measurement['_id']} #{measurement['rate'][interface][recordName]}"
      xvals << measurement['_id']
      yvals << measurement['rate'][interface][recordName] * 8
  end
  return xvals, yvals
end




Interface.all.each do |int|
  puts "DEBUG -- interface=#{int.name},device=#{int.device.hostname}"
  #find first day of data in mongo -- TODO, should not need a loop here, get rid of it
  collection = "host.#{int.device.hostname}"
  firstEntryRef = @db[collection].find.sort( [['_id', :asc]] ).first
  firstEntryEpoch = firstEntryRef['_id']




