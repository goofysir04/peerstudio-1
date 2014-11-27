class AssignmentGrade < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :rubric_item
  belongs_to :answer
  def self.export_to_csv()
  	CSV.generate({}) do |csv|
      csv << ['assignment','name', 'email', 'grade']
      self.where(is_final: true, experimental: false).group(:assignment_id, :user_id).sum(:credit).each do |group,grade|
        assignment = Assignment.find(group[0])
      	student = User.find(group[1])
        csv << [assignment.title, student.name,student.email, grade.round(2)]
      end
    end
  end
end
