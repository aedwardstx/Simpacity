#!/usr/bin/env ruby

#This script is to be called by the various Simpacity helper scripts
#

require 'rubygems'
gem 'activerecord'
require 'active_record'

#CHANGE ME TO FIT YOUR ENVIRONMENT!!
simpacity_base = '/opt/simpacity-dev'
require "#{simpacity_base}/lib/SimpacityMath"

ActiveRecord::Base.establish_connection(
    #:adapter => 'sqlite3',
    #:database => "#{simpacity_base}/db/development.sqlite3"
    :adapter => 'mysql',
    :encoding => 'utf8',
    :database => 'simpacity_dev',
    :username => 'simpacity_dev',
    :password => 'simpacity_dev_secret',
    :socket => '/var/run/mysqld/mysqld.sock',
    :pool => 5,
    :timeout => 5000
)

#Require the Simpacity model files
require "#{simpacity_base}/app/models/interface_group.rb"
require "#{simpacity_base}/app/models/interface_group_relationship.rb"
require "#{simpacity_base}/app/models/interface.rb"
require "#{simpacity_base}/app/models/measurement.rb"
require "#{simpacity_base}/app/models/srlg_measurement.rb"
require "#{simpacity_base}/app/models/device.rb"
require "#{simpacity_base}/app/models/snmp.rb"
require "#{simpacity_base}/app/models/setting.rb"
require "#{simpacity_base}/app/models/alert.rb"
require "#{simpacity_base}/app/models/alert_log.rb"
require "#{simpacity_base}/app/models/contact_group.rb"
require "#{simpacity_base}/app/models/device_autoconf_rule.rb"
require "#{simpacity_base}/app/models/interface_autoconf_rule.rb"
require "#{simpacity_base}/app/models/link_type.rb"
require "#{simpacity_base}/app/models/average.rb"


#Require some helpers
#require "#{simpacity_base}/app/helpers/frontend_helper.rb"
#require "#{simpacity_base}/app/helpers/alerts_helper.rb"

