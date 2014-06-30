class WelcomeController < ApplicationController
  def index
    @courses = Course.where(hidden: false)
    render layout: "welcome"
  end
end
