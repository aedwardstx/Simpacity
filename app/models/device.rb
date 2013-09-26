class Device < ActiveRecord::Base
  #require 'resolv'
  #TODO --
  # validate the pingability/resolvability of hostnames
  # load defaults for new objects, I have sample code at home, look it up
  # write out config for zpoller on new/update of model
  #
  has_many :interfaces, :dependent => :destroy
  belongs_to :snmp

  validates_presence_of :snmp
  validates_presence_of :hostname
  validates_uniqueness_of :hostname
  #validates_format_of :hostname, :with => /(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.)+(?:[a-zA-Z]{2,})$)/i
  #validates_presence_of :description

  #after_save :update_zpoller, on: [:create, :update]
  #after_destroy :update_zpoller

  #validate :hostname_resolvable, on: :create
  
  #validates :hostname, presence => true, :uniqueness => treu, format => {:with => /(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.)+(?:[a-zA-Z]{2,})$)/i}
  #def hostname_resolvable
  #  errors.add(:hostname, "is not resolvable") unless Resolv.new.getaddress(hostname)?
  #end
  #after_save :updateZpoller, on: [:create, :update]
  #after_destroy
  #validate that the hostname resolves to an IP address
  #validate the format of hostname against a regex
  #validate that the SNMP Community is there
  #set SNMP community to a default 
  protected

  #Update Zpoller when devices are updated/added/removed
  def update_zpoller
    File.open(Setting.first.zpoller_hosts_location, 'w') do |f2|
      Device.find(:all).each do |device|
        f2.puts "\"#{device.hostname}\",\"#{device.hostname}\",\"#{device.snmp.community_string}\""
      end
    end
    #run the zpoller config update script
    current_dir = Dir.pwd
    Dir.chdir Setting.first.zpoller_base_dir
    system(Setting.first.zconfig_location)
    Dir.chdir current_dir
  end
end
