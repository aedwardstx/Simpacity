class Average < ActiveRecord::Base
  belongs_to :averageable, polymorphic: true
end
