class InterfaceAutoconfRule < ActiveRecord::Base
  belongs_to :link_type

  validates_presence_of :name_regex
  validates_presence_of :description_regex
  validates_presence_of :link_type_id

end
