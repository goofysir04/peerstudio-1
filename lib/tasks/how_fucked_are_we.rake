namespace :analysis do
	task :how_fucked_are_we => :environment do
		logger = Rails.logger
		@assignment = Assignment.find(9)
		@answers = Answer.where(assignment: @assignment, submitted: true)
		@answers.each do |a|
			feedback_items_by_rubric_item = a.feedback_items_by_rubric_item
			conservative_ok = true
			aggressive_ok = true
			@assignment.rubric_items.each do |r|
				r.answer_attributes.each do |a_attr| 
					reviews_including_attr = 0 
					reviews_excluding_attr = 0
					next if feedback_items_by_rubric_item[r.id].nil?
					feedback_items_by_rubric_item[r.id].each do |f|
						if f.answer_attributes.include?(a_attr)
							reviews_including_attr += 1
						else
							reviews_excluding_attr += 1
						end
					end
					if reviews_excluding_attr != reviews_including_attr
						conservative_ok = false
					end

					if ((reviews_excluding_attr == 0 and reviews_including_attr > 0) or (reviews_excluding_attr > 0 and reviews_including_attr==0))
						aggressive_ok = false
					end
				end
			end

			puts "#{a.id}, #{a.user_id}, #{conservative_ok}, #{aggressive_ok}"
		end
	end
end