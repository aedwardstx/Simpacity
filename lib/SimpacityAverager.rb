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


#Move this definition to AR on a per-interface basis in the future
# This will do a best effort to grab these values from Mongo
#   will need logic to softfail if values are not there
records = ['ifInOctets','ifOutOctets']

#TODO -- move average calc percentile and days back to general settings
average_previous_hours = Setting.first.average_previous_hours

records.each do |record|
  [100,50,25,10,5,1].each do |percentile|
    Interface.all.each do |int|
      measure_count = 0
      measure_sum = 0
      average = 0
      measurements = int.measurements.where(:record => record, :percentile => percentile, :collected_at => average_previous_hours.hours.ago..Time.now)
      measurements.each do |measures|
        measure_sum += measures.gauge
        measure_count += 1
      end

      if not measure_count == 0
        average = (measure_sum / measure_count)
      end

      #store to AR
      int.averages.where(:percentile => percentile, :record => record).destroy_all
      int.averages.create(:percentile => percentile, :record => record, :gauge => average)
      puts "done with ittr"
    end

    InterfaceGroup.all.each do |int_group|
      measure_count = 0
      measure_sum = 0
      average = 0
      measurements = int_group.srlg_measurement.where(:record => record, :percentile => percentile, :collected_at => average_previous_hours.hours.ago..Time.now)
      measurements.each do |measures|
        measure_sum += measures.gauge
        measure_count += 1
      end

      if not measure_count == 0
        average = (measure_sum / measure_count)
      end

      #store to AR
      int_group.averages.where(:percentile => percentile, :record => record).destroy_all
      int_group.averages.create(:percentile => percentile, :record => record, :gauge => average)
      puts "done with itter"
    end
  end
end

