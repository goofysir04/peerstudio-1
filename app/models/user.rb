require 'csv'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

	devise :omniauthable, :omniauth_providers=>[:coursera]

  validate do |user|
    user.errors[:base] << ("You must choose whether you want to participate in our research.") if user.consented.nil?
  end

	has_many :assessments
	has_many :verifications

  #This was for the L@S paper. 
	def experimental_condition
		# if id%5 == 0
		# 	return "baseline"
		# elsif id%2 == 0
		# 	return "verify"
		# else
		# 	return "identify"
		# end	
    if !self.experimental_group.blank?
      return self.experimental_group
    end

    if id%5==0
      self.experimental_group = "waitlist"
      self.save!
    elsif id%2 == 0
      self.experimental_group =  "fastlane"
      self.save!
    else
      self.experimental_group = "normal"
      self.save!
    end

    return self.experimental_group
 	end



 	class ImportJob <  Struct.new(:file_text)
    def perform
      print "STARTing job"
      spreadsheet = CSV.parse(file_text, {:headers => :first_row})
      spreadsheet.each do |row|
        owning_user = User.find_by_email(row["email"].downcase)
        if owning_user.nil?
        #this is a dummy password
          owning_user = User.new :password => Devise.friendly_token[0,20], :email=> row["email"]
        end
        
        owning_user.cid= row["coursera_id"]
        owning_user.save!
        # print "Answer saved"
      end

      print "FINISHing job"
    end
  end

  def self.import(file)
    raise "Unknown file type" if File.extname(file.original_filename) != ".csv"
    Delayed::Job.enqueue ImportJob.new(file.read)
  end 
end
