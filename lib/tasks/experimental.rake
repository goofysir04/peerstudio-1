require 'csv'

namespace :experimental do
	namespace :grading do
		desc "push grades based on csv file"
		task :push_grades, [:filename] => :environment do |task, args|
			logger = Rails.logger
			API_KEY = "8e5a1f15406f9e777c70743b1c2bfd78505b70e3300109efe93d0556ce83c73b50a0ce0a3a705f3a9e783a72d0adf6c816ce06cb41228a28325d88ecd2e302c0"
			CSV.foreach(Rails.root.join("experimental",args.filename), {:headers => :first_row}) do |row|
				uri = URI.parse "https://class.coursera.org/organalysis-002/assignment/api/update_score"
				http = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl = true
				http.ca_file = Rails.root.join("config/cacert.pem").to_s
				http.verify_mode = OpenSSL::SSL::VERIFY_PEER
				puts "Pushing grades for #{row['email']} (#{row['coursera_user_id']})"
					begin
						feedback_str="You attended #{row['attended']} discussion sessions. Your credit includes any sessions for which you were waitlisted"
						
						resp = http.post(uri.request_uri, "api_key=#{API_KEY}&user_id=#{row['coursera_user_id']}&assignment_part_sid=credit&score=#{row['normalizedAttended']}&feedback=#{CGI::escape(feedback_str)}")
					if resp.body == '{"status":"202"}'        
						logger.info "Success: Response #{resp.body}"
					else
						logger.error "Push failed for #{row['email']} (#{row['coursera_user_id']}); Response #{resp.body}"
					end
					rescue Exception => e
						logger.error "Push failed for #{row['email']} (#{row['coursera_user_id']}); Exception: #{e.inspect}"
						sleep(10)
						logger.error "Restarting after waiting 10s"
						next
					end
			end
		end
	end

	namespace :reviews do 
		desc "Dump reviews with comments"
		task :dump_comments => :environment do
			reviews = Review.where(active:true)
			file = CSV.generate({force_quotes: true}) do |csv|
				csv << ["id", "answer_id", "assignment_id", "accurate_rating", "concrete_rating", "recognize_rating", "other_rating_comments", "all_comments"]
				reviews.each do |r|
					csv << [r.id, r.answer_id, r.assignment_id, r.accurate_rating, r.concrete_rating, r.recognize_rating, r.other_rating_comments, r.all_comments.gsub(/\n|\r/,'')]
			  	end
			end
			print file
		end
	end
end