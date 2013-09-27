#!/usr/bin/env ruby

#Flow
#
#Description and Bandwidth Updating
# Crawl Zpollers targets collection to update the interface descriptions and speeds
#
#Unconfigured Percentiles Handling
# delete measurements that are using unconfigured percentiles
#   Will need to configure percentiles in AR for this, WAIT for percentile revamp
#
#
#


require 'rubygems'
require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

require "#{simpacity_base}/app/helpers/frontend_helper.rb"
require "#{simpacity_base}/app/helpers/interfaces_helper.rb"
require "#{simpacity_base}/app/helpers/interface_bulks_helper.rb"

include FrontendHelper
include InterfacesHelper
include InterfaceBulksHelper


Device.all.each do |device|
  #get all ints from interfaces
  #each int from mongo, is already added? no?, does it match the expressions? yes? add it

  interfaces = get_interfaces_for_device(device.id)

  interfaces.each do |int_name|
    (bandwidth, description) = get_interface_metadata_by_name(device.hostname,int_name)
    int_ar = device.interfaces.where(:name => int_name)
    puts "int is: #{int_name}, bandwidth is: #{bandwidth}, description is: #{description}"
    InterfaceAutoconfRule.where(:enabled => true).each do |rule|
      #check if the interface matches the expressions in the rule -- Also, make sure it does not have a '.' in the name, this currently breaks things
      if description =~ /#{rule.description_regex}/ and int_name =~ /#{rule.name_regex}/ and not int_name =~ /\./
        if int_ar.length == 1
          #update
          puts "hey hey update"
        elsif int_ar.length == 0
          #create
          puts "I am creating an entry - device: #{device.hostname}, int_name: #{int_name}, link_type_id: #{rule.link_type_id}, description: #{description}, bandwidth: #{bandwidth}"
          #device.interfaces.create(:name => int_name, :link_type_id => rule.link_type_id, :description => description, :bandwidth => bandwidth) 
        else
          puts 'This shouldn\'t happen'
        end
        #break
      else
        puts 'Regexs failed to match'
      end
    end
  end
end 
