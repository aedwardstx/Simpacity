class Alert < ActiveRecord::Base
  has_many :alert_logs, :dependent => :destroy
  belongs_to :contact_group
  belongs_to :link_type

  #commented out -- if the checkbox is unchecked, the validation fails
  #validates_presence_of :enabled
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :int_type
  validates_presence_of :link_type_id
  validates_presence_of :match_regex
  validates_presence_of :percentile
  validates_presence_of :watermark
  validates_presence_of :days_out
  validates_presence_of :contact_group_id
  validates_uniqueness_of :name
end
