class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token, :only => [:coursera]
  before_filter :set_return_path_on_sign_in_page

  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
  def coursera
    
    @user = User.find_by_email(request.env["omniauth.auth"]["info"]["email"]) || current_user
    if !@user.nil?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Coursera"
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    else
      session["devise.openid_data"] = request.env["omniauth.auth"]["info"].merge(
        {:provider=> request.env["omniauth.auth"]["provider"],
         :uid => request.env["omniauth.auth"]["uid"]})
      redirect_to start_openid_registration_url
    end
  end

  private

  def set_return_path_on_sign_in_page
    request.env['omniauth.origin'] = session[:user_return_to] unless  session[:user_return_to].nil? 
  end
end