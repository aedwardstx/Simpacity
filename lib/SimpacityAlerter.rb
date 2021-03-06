#!/usr/bin/env ruby

require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'
require 'net/smtp'

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
            (temp_times, temp_gauges) = get_int_measurements(int.id, alert.percentile, noidName, start_epoch, end_epoch)
            #ensure there are more than zero measurements and more than 10bps average
            temp_g = int.averages.where(:percentile => alert.percentile, :noid => noidName).first
            if temp_times.length == 0 or !temp_g or temp_g.gauge <= 10 
              puts "DEBUG: ignoring this interface as it either does not have enough measurements or an average"
              int.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
              next 
            elsif temp_g.gauge < int.bandwidth * alert.watermark
              if not temp_times[0].between?(start_epoch, start_epoch+260000)  
                puts "temp_times: #{temp_times[0]}, start_epoch: #{start_epoch} out of bounds, probably not enough measurements"
                int.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
                next
              elsif not temp_times[-1].between?(end_epoch-260000, end_epoch) 
                puts "temp_times: #{temp_times[-1]}, end_epoch: #{end_epoch} out of bounds, probably not enough measurements"
                int.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
                next
              end
            end

            measurement_duration_sec = temp_times.sort[-1] - temp_times.sort[0]
            alert_lookback_duration = end_epoch - start_epoch

            puts "  Debug measurements length #{measurement_duration_sec} #{min_alert_measurements_percent * alert_lookback_duration}"

            projection = get_int_projection(int.id, alert.percentile, noidName, start_epoch, end_epoch, alert.watermark, Setting.first.max_trending_future_days)
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
              alert_log_entry = int.alert_logs.find_or_initialize_by(:noid => noidName, :alert_id => alert.id)
              alert_log_entry.projection = projection.days.from_now
              alert_log_entry.save
              #send email Alert.first.contact_group.email_addresses
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
          (temp_times, temp_gauges) = get_int_group_measurements(int_group.id, alert.percentile, noidName, start_epoch, end_epoch)

          #puts ":percentile => #{alert.percentile}, :noid => #{noidShortName}"
          temp_g = int_group.averages.where(:percentile => alert.percentile, :noid => noidName).first
          int_group_bw = get_int_group_bandwidth(int_group.id)
          if temp_times.length == 0 or !temp_g or temp_g.gauge <= 10
            puts "DEBUG: ignoring this interface group as it either does not have enough measurements or an average"
            int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
            next
          elsif temp_g.gauge < (int_group_bw * alert.watermark)
            if not temp_times[0].between?(start_epoch, start_epoch+260000) 
              puts "temp_times: #{temp_times[0]}, start_epoch: #{start_epoch} out of bounds, probably not enough measurements"
              int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
              next
            elsif not temp_times[-1].between?(end_epoch-260000, end_epoch) 
              puts "temp_times: #{temp_times[-1]}, end_epoch: #{end_epoch} out of bounds, probably not enough measurements"
              int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
              next
            end
          end


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
            alert_log_entry = int_group.alert_logs.find_or_initialize_by(:noid => noidName, :alert_id => alert.id)
            alert_log_entry.projection = projection.days.from_now
            alert_log_entry.save
          else
            #if there is an alert for this already, delete it
            int_group.alert_logs.where(:noid => noidName, :alert_id => alert.id).destroy_all
          end
        end
      end
    end
  end
end


### send email report

ContactGroup.all.each do |contact|
  report = ''

  report += "<h3>Interface groups with a high alert level</h3>\n"
  report += '<table style="width:100%">'
  report += '<tr><th>Group Name</th><th>Percentile</th><th>Watermark Exceed Projection</th><th>Record</th><th>Bandwidth</th><th>Averages</th></tr>'
  contact.alerts.where(:int_type => "interface-group", :severity => 5).each do |alert|
    alert.alert_logs.each do |alert_log|
      int_group = InterfaceGroup.find(alert_log.alertable_id)
      int_group_bw = get_int_group_bandwidth(int_group.id)
      avg = int_group.averages.where(:percentile => alert.percentile).collect {|avgs| "#{avgs.noid} - #{avgs.gauge / 1000000}mbps"}
      percentile = 100 - alert.percentile
      report += '<tr>'
      report += "<td>#{int_group.name}</td>\n"
      report += "<td>#{percentile}</td>\n"
      report += "<td>#{alert_log.projection}</td>\n" 
      report += "<td>#{alert_log.noid}</td>\n" 
      report += "<td>#{int_group_bw / 1000000}mbps</td>\n" 
      report += "<td>#{avg}</td>\n"
      report += '</tr>'
    end
  end
  report += '</tr></table>'
  report += "<br><br>\n"
  report += "<h3>Interfaces with a high alert level</h3>\n"
  report += '<table style="width:100%">'
  report += '<tr><th>Interface Name</th><th>Interface</th><th>Percentile</th><th>Watermark Exceed Projection</th><th>Record</th><th>Bandwidth</th><th>Averages</th></tr>'
  contact.alerts.where(:int_type => "interface", :severity => 5).each do |alert|
    alert.alert_logs.each do |alert_log|
      int = Interface.find(alert_log.alertable_id)
      avg = int.averages.where(:percentile => alert.percentile).collect {|avgs| "#{avgs.noid} - #{avgs.gauge / 1000000}mbps"}
      percentile = 100 - alert.percentile
      report += '<tr>'
      report += "<td>#{int.device.hostname}</td>\n"
      report += "<td>#{int.name}</td>\n"
      report += "<td>#{percentile}</td>\n" 
      report += "<td>#{alert_log.projection}</td>\n" 
      report += "<td>#{alert_log.noid}</td>\n"
      report += "<td>#{int.bandwidth / 1000000}mbps</td>\n"
      report += "<td>#{avg}<td>\n"
      report += '</tr>'
    end
  end


message = <<MESSAGE_END
From: SimpacityAlerter <noreply@rackspace.com>
To: <#{contact.email_addresses.gsub(/\s+/, "").gsub(/,/, '>, <')}>
MIME-Version: 1.0
Content-type: text/html
Subject: Simpacity Alert

#{report}

MESSAGE_END

  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message message, 'noreply@rackspace.com', 
                               contact.email_addresses.split(',').map(&:strip)
  end
end


