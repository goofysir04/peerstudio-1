class TriggerAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment

  def self.pending_action(trigger, user, assignment)
	self.where(trigger: trigger, user: user, assignment:assignment).where("count > 0 ").first
  end

  #Returns an unsaved trigger
  def self.add_trigger(user, assignment, opts = {})
  	options = {count: 1, user: user, assignment: assignment, trigger: "generic"}.merge(opts)
  	trigger = self.where(user: user, assignment: assignment, trigger:options[:trigger]).first_or_create
  	trigger.description = options[:description]
  	trigger.increment(:count, options[:count])
  	return trigger
  end
end
