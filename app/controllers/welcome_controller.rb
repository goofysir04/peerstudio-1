class WelcomeController < ApplicationController
  def index
    @courses = Course.where(hidden: false)
    @user_count = User.count
    render layout: "welcome"
  end
end
