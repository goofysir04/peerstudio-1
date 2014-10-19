class Review < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  belongs_to :assignment
  has_many :feedback_items, :dependent => :destroy
  has_many :feedback_item_attributes, through: :feedback_items

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

  def all_comments
    comments = "" 
    comments << (self.comments or "")
    self.feedback_items.each do |f|
      comments << " "
      comments << (f.like_feedback or "")
    end
    return comments
  end

  def set_answer_attribute_weights!(weights)
  	return if weights.nil?
    weights.each do |id, attrs|
  		feedback_attribute = self.feedback_item_attributes.where(answer_attribute_id: id).first_or_create(answer_attribute_id: id)
		feedback_attribute.weight = attrs[:weight]
		feedback_attribute.save!  		
  	end
  end

  def answer_attribute_weight(answer_attribute_id)
  	feedback_attribute = self.feedback_item_attributes.where(answer_attribute_id: answer_attribute_id).first
  	if feedback_attribute.blank?
  		return 0
  	else
  		return feedback_attribute.weight
  	end
  end

end
