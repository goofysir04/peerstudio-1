class RegistrationsController < Devise::RegistrationsController

  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(params[:user])
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_without_password(params[:user])
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def start_openid
    @name = session["devise.openid_data"]["name"]
    @email = session["devise.openid_data"]["email"]
    @provider = session["devise.openid_data"]["provider"]
    if @provider.nil? or @email.nil?
      flash[:alert] = "Please enable cookies to login."
      redirect_to new_user_session_path and return
    end
    self.resource = resource_class.new()
    clean_up_passwords(self.resource)
  end

  def complete_openid
    @user = User.find_by_email(session["devise.openid_data"]["email"])
    if @user.nil?
      @user = User.new user_params().merge({
        :name=>session["devise.openid_data"]["name"],
        :email=>session["devise.openid_data"]["email"],
        :password => Devise.friendly_token[0,20], #this is a dummy password
        :provider => session["devise.openid_data"]["provider"],
        :uid => session["devise.openid_data"]["uid"]
        }
      )
    end
    if @user.save #if user is saved or unchanged
      sign_in_and_redirect @user, :event => :authentication
    else
      flash[:alert] = "There was a problem signing in. Please contact us, and mention your claimed id as #{session["devise.openid_data"]["id"]}"
      redirect_to start_openid_registration_path
    end
  end

  def impersonate
    unless true_user.admin?
      redirect_to root_path
    else
      if params[:email].nil?
        stop_impersonating_user
        redirect_to root_path, :notice=>"Stopped impersonation"
        return
      end
      u = User.find_by_email(params[:email])
      redirect_to root_path, :alert=>"No such user" and return if u.nil?

      impersonate_user u
      redirect_to root_path, :notice=>"Impersonating #{u.email}"
    end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end

  def user_params
     params.require(:user).permit(:name, :email, :password, :confirm_password, :time_zone, :gender)
   end
end
