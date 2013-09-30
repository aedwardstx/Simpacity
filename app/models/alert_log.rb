class AlertLog < ActiveRecord::Base
    belongs_to :alert
    belongs_to :alertable, polymorphic: true
end
