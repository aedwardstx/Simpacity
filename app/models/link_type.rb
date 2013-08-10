class LinkType < ActiveRecord::Base
  has_one :interface
  has_many :alerts
  validates_presence_of :name
  validates_presence_of :description
end
