class InterfaceGroupRelationship < ActiveRecord::Base
  belongs_to :interface
  belongs_to :interface_group
end
