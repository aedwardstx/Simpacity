class InterfaceGroup < ActiveRecord::Base
  has_many :alert_logs, as: :alertable, :dependent => :destroy
  has_many :averages, as: :averageable, :dependent => :destroy
  #has_many :alerts, :through :alert_logs
  has_many :interfaces, :through => :interface_group_relationships 
  has_many :interface_group_relationships, :dependent => :destroy
  has_many :srlg_measurement, :dependent => :destroy


  attr_reader :interface_tokens
  def interface_tokens=(ids)
    self.interface_ids = ids.split(",")
  end

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :interface_ids  #This does not completely work, highlighting is busted, highlighting works when reffering to interface_tokens but is otherwise busted
  #TODO -- validate the existance of the interface_ids specified

end
