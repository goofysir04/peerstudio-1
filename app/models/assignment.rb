class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :answers, :dependent => :destroy
  has_many :rubric_items, :dependent => :destroy
  accepts_nested_attributes_for :rubric_items, :allow_destroy => true, reject_if: proc { |attributes| attributes['short_title'].blank? and attributes['title'].blank? }

  acts_as_taggable_on :milestones

  def get_tasks
  	puts self.milestones
  	puts "*****************************************"
  	taggings = Tagging.where("taggable_id = ?", self.id)
  	for tagging in taggings
  		puts tagging.tag_id
  	end
  end
end
