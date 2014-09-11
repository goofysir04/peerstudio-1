class AssignmentGrade < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  belongs_to :rubric_item

  def self.export_to_csv()
  	CSV.generate({}) do |csv|
      csv << ['name', 'email', 'grade']
      self.group(:user_id).sum(:credit).each do |user,grade|
      	student = User.find(user)
        csv << [student.name,student.email, grade.round(2)]
      end
    end
  end
end
