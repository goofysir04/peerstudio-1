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
end
