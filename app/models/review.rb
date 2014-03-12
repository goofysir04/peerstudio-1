class Review < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  belongs_to :assignment
  has_many :feedback_items, :dependent => :destroy

  accepts_nested_attributes_for :feedback_items, allow_destroy: true

  def empty?
  	review_blank = true
	self.feedback_items.each do |f|
	 if f.answer_attributes.count > 0
	 	review_blank = false
	 end
	end
	if !self.comments.blank?
		review_blank = false
	end

	return review_blank
  end

end
