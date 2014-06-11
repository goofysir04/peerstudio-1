class TriggerAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment

  def pending_action(trigger, user, assignment)
	self.where(trigger: trigger, user: user, assignment:assignment).where("count > 0 ")
  end
end
