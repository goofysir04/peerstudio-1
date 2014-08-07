module ApplicationHelper
	def required_identifications
		return 4
	end

	def required_verifications
		return 12
	end

	def required_baseline
		return 4
	end

	#default devise resources
	def resource_name
		:user
	end

	def resource
		@resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

	def due_date(date)
		return "Due on " + date.strftime("%b %e, %l:%M %p") 
	end

	def non_pii_user_id
		if user_signed_in?
			Digest::MD5.hexdigest("#{ENV['ANALYTICS_USER_KEY']}\n\n#{current_user.id}")
		end
	end
end
