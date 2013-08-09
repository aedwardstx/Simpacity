class ContactGroup < ActiveRecord::Base
  has_many :alerts

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :email_addresses
  validates_uniqueness_of :name
end
