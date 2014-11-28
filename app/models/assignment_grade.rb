class AssignmentGrade < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :rubric_item
  belongs_to :answer
  def self.export_to_csv()
  	CSV.generate({}) do |csv|
      csv << ['assignment', 'name', 'email', 'grade', 'due_at','submitted_at','late']
      self.where(is_final: true, experimental: false).group(:assignment_id, :user_id, :answer_id).sum(:credit).each do |group,grade|
        assignment = Assignment.find(group[0])
      	student = User.find(group[1])
        answer = Answer.find(group[2])
        csv << [assignment.title, student.name,student.email, grade.round(2), assignment.due_at.in_time_zone("Pacific Time (US & Canada)").strftime("%d/%m/%y %H:%M:%S"), answer.submitted_at.in_time_zone("Pacific Time (US & Canada)").strftime("%d/%m/%y %H:%M:%S"), answer.submitted_at > assignment.due_at ? "Late": ""]
      end
    end
  end
end
