class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # layout :layout_by_resource
  impersonates :user

  before_filter :ensure_user_is_not_banned
  # require 'oauth/request_proxy/action_controller_request'

	def authenticate_user_is_admin!
    return true if Rails.env.development?
		unless user_signed_in?
			authenticate_user!
		end
    sign_out_and_redirect(current_user) unless (current_user.admin?)
	end

  def authenticate_user_is_instructor!(course)
    return true if Rails.env.development?
    unless user_signed_in?
      authenticate_user!
    end
    sign_out_and_redirect(current_user) unless (current_user.instructor_for?(course))
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

  def toggle_view_mode
    authenticate_user!
    if current_user.view_mode=="student"
      current_user.view_mode="staff"
      current_user.save
    else
      current_user.view_mode="student"
      current_user.save
    end

    redirect_to :back
  end

  def ensure_user_is_not_banned
    if user_signed_in? and current_user.banned?
      render text: "We're currently unable to handle your request. Error: U7tuAgRwq", status: 410
      return
    end
  end

end
