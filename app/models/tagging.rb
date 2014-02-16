class Tagging < ActiveRecord::Base
	belongs_to :tag
	belongs_to :assignment

	default_scope :order=>'close_at ASC, open_at ASC, review_close_at ASC, review_open_at ASC'

	def tag_name
		return Tag.find(self.tag_id).name
	end
end