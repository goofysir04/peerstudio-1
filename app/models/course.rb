class Course < ActiveRecord::Base
  belongs_to :user
  has_many :assignments
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  has_many :enrollments
  has_many :students, through: :enrollments, source: :user
  def ended?
  	!self.open_enrollment
  end

  def regenerate_consumer_secret
  	SecureRandom.base64(32)
  end
  
  def regenerate_consumer_secret!
  	self.consumer_secret = self.regenerate_consumer_secret #Generate a secure 32-byte string
  	self.save!
  end

  def enroll_with_lti(request)
  	provider = IMS::LTI::ToolProvider.new(self.consumer_key, self.consumer_secret, request.params)  	

  	if provider.valid_request?(request)
	# success
		if provider.outcome_service?
			user = User.find_for_authentication(email: provider.lis_person_contact_email_primary)
			if user.nil?
				user = User.new(name: provider.lis_person_name_full,
					email:provider.lis_person_contact_email_primary,
					provider:"LTI:#{provider.tool_consumer_instance_guid}",
					consented: nil,
					password: Devise.friendly_token[0,20])
				user.save!
			end
			# sign_in(:user, user)
			if self.students.exists?(user.id).nil?
				#the student is not enrolled, so try and enroll them first. 
				enrollment = Enrollment.new(user: user, course: self,
					roles: provider.roles,
					lti_user_id: provider.user_id,
					lis_result_sourcedid: provider.lis_result_sourcedid, 
					raw_lti_params: request.params.to_s)
				return user
			else 
				return user
			end
		else 
			return nil
		end
	else
	  # handle invalid OAuth
	  raise provider.inspect
	end
  end

end
