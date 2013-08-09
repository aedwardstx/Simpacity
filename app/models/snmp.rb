class Snmp < ActiveRecord::Base
  has_many :devices

  validates_presence_of :name
  validates_presence_of :community_string
  validates_uniqueness_of :community_string

  before_save :falsify_all_others1, :on => :update
  before_save :falsify_all_others2, :on => :create
  after_destroy :falsify_all_others3
  def falsify_all_others1
    if self.default_community == true
      Snmp.where('id != ? ', self.id).update_all("default_community = 'false'") 
      #Snmp.all.update_all("default_community = 'false'") 
    elsif self.default_community == false and Snmp.where("default_community = 't' AND id != ? ", self.id).count == 0
      self.default_community = true
    end
  end
  def falsify_all_others2
    #There seems to be a bug in sqlite in doing where statements with boolean, only "false" and "t" return results
    #elsif self.default_community == false and Snmp.where("default_community = 't' AND id != ? ", self.id).length == 0
    #if self.default_community == true and Snmp.where("default_community = 't' AND id != ? ", self.id).count == 0
    if self.default_community == true 
      Snmp.all.update_all("default_community = 'false'") 
      #self.default_community = true
    end
  end
  def falsify_all_others3
    if Snmp.where("default_community = 't'").count == 0
      Snmp.first.update(:default_community => true )
    end
  end

end

