class RubricItem < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
end
