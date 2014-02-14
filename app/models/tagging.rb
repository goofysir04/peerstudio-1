class Tagging < ActiveRecord::Base
	default_scope :order=>'close_at ASC, open_at ASC, review_close_at ASC, review_open_at ASC'
end