class ReviewMailer < ActionMailer::Base
  default from: "hello@peerstudio.org"

	def reviewed_email(user)
		@user = user
		@reviewed_work = 'https://www.peerstudio.org' #change this!!!! 
		mail(to: @user.email, subject: 'Someone reviewed your work!')

	end

  # def welcome_email(user)
  #   @user = user
  #   @url  = 'http://example.com/login'
  #   mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  # end
end
