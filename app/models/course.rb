class Course < ActiveRecord::Base
  belongs_to :user
  has_many :assignments
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  has_many :enrollments
  has_many :students, through: :enrollments, source: :user
  def ended?
  	!self.open_enrollment
  end

  def self.closest_open(id)
    open_assignments_list = []
    assignments = Assignment.where("course_id = ?", id)
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
