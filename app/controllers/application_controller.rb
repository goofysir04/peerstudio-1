class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  	def authenticate_user_is_admin!
  		unless user_signed_in?
  			authenticate_user!
  		end
      sign_out_and_redirect(current_user) unless (current_user.admin?)
	end
end
