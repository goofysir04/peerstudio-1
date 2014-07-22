class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :answers, :dependent => :destroy
  has_many :rubric_items, :dependent => :destroy
  accepts_nested_attributes_for :rubric_items, :allow_destroy => true, reject_if: proc { |attributes| attributes['short_title'].blank? and attributes['title'].blank? }

  acts_as_taggable_on :milestones
  accepts_nested_attributes_for :taggings, :allow_destroy => true

  def task_list
    task_list = []
  	taggings = Tagging.where("taggable_id = ?", self.id)
  	for tagging in taggings
      if self.milestone_list.include?(tagging.tag_name)
        unless tagging.close_at.blank?
          task = { :name => tagging.tag_name, :open_at => tagging.open_at, :close_at => tagging.close_at, :review_open_at => tagging.review_open_at, :review_close_at => tagging.review_close_at }
          task_list << task
        end
      end
  	end
    return task_list
  end

  def ended?
    self.due_at < DateTime.current()
  end

  def closest_open()
    open_assignments_list = []
    assignments = Assignment.where("course_id = ?", self.course_id)
    for a in assignments
      if !a.ended?
        open_assignments_list << a
      end
    end
    if open_assignments_list.empty? 
      return nil
    else
      closest = open_assignments_list[0].due_at - DateTime.current()
      closest_class = open_assignments_list[0]
      for a in open_assignments_list
        if (a.due_at - DateTime.current()) <= closest
          closest_class = a
          closest = a.due_at - DateTime.current()
        end
      end
      return closest_class
    end
  end

end