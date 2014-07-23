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
  	courses = Course.find(id).assignments.order('due_at asc').select{|a| !a.ended?}
  	return courses[0]
  end
end