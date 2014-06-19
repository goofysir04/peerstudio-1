class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # layout :layout_by_resource
  impersonates :user

	def authenticate_user_is_admin!
    return true if Rails.env.development?
		unless user_signed_in?
			authenticate_user!
		end
    sign_out_and_redirect(current_user) unless (current_user.admin?)
	end

  before_filter :set_timezone 

  def set_timezone
    if user_signed_in?
      Time.zone = current_user.time_zone
    else
      Time.zone = "Pacific Time (US & Canada)"
    end
  end

  def after_sign_in_path_for(resource)
    session["user_return_to"] || request.env['omniauth.origin'] || root_path
  end
end
