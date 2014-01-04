class Interface < ActiveRecord::Base
  #TODO
  # make the name a dropdown selector, right now, the name would have to be exactly correct to work
  #   mongodb lookup for the last 24 hours listing the interface names
  # make the speed automatically detected
  # validate the uniqueness of the device/name pair
  belongs_to :device
  belongs_to :link_type
  has_many :alert_logs, as: :alertable, :dependent => :destroy
  has_many :averages, as: :averageable, :dependent => :destroy
  #has_many :alerts, :through :alert_logs
  has_many :interface_groups, :through => :interface_group_relationships
  has_many :interface_group_relationships, :dependent => :destroy
  has_many :measurements, :dependent => :delete_all

  validates_presence_of :device
  validates_presence_of :link_type_id
  validates_presence_of :description
  validates_presence_of :name
  validates_presence_of :bandwidth
  
  attr_reader :device_tokens
  def device_tokens=(ids)
    self.device_id = ids.split(",").first
  end

  #def device_hostname
  #  device.hostname if device
  #end

  #def device_hostname=(hostname)
  #  self.device = Device.find_by_hostname(hostname) unless hostname.blank?
  #end
  
end
