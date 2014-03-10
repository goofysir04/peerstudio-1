class ActionItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :assignment
  belongs_to :review
  belongs_to :answer

  default_scope {order 'priority DESC, user_id asc, review_id asc'}
end
