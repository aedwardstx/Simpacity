#!/usr/bin/env ruby

require 'mongo'
include Mongo
gem 'activerecord'
require 'active_record'
require 'rubygems'
require 'action_view'
include ActionView::Helpers::DateHelper


#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'

require "#{simpacity_base}/lib/SimpacityExtensionCommon.rb"

@client = MongoClient.new(Setting.first.mongodb_db_hostname, Setting.first.mongodb_db_port)
@db     = @client[Setting.first.mongodb_db_name]

date_to_remove = 4.months.ago.to_i

@db.collections.each do |collection|
  if collection.name =~ /^host\./
    puts "Removing old items for: " + collection.name
    collection.remove({'_id' => {'$lt' => date_to_remove}})
    puts "Running compact on: " + collection.name
    @db.command({'compact' => collection.name})
  end

end
