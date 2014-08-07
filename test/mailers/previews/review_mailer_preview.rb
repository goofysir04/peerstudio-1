class ReviewMailerPreview < ActionMailer::Preview
	def reviewed_email
		ReviewMailer.reviewed_email(Answer.last)
	end
end