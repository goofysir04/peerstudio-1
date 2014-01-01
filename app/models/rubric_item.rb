class RubricItem < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user

  default_scope :order=>'ends_at ASC'
end
