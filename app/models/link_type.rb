class LinkType < ActiveRecord::Base
  has_one :interface
  has_one :alert
  has_one :interface_autoconf_rule
  validates_presence_of :name
  validates_presence_of :description
end
