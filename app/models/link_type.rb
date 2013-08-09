class LinkType < ActiveRecord::Base
  has_one :interface
  validates_presence_of :name
  validates_presence_of :description
end
