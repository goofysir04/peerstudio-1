class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :answers, :dependent => :destroy
  has_many :rubric_items, :dependent => :destroy
  accepts_nested_attributes_for :rubric_items, :allow_destroy => true, reject_if: proc { |attributes| attributes['short_title'].blank? and attributes['title'].blank? }

  acts_as_taggable_on :milestones
  accepts_nested_attributes_for :taggings, :allow_destroy => true
  scope :active, -> { where("due_at > ?", Time.now)}

  has_many :lti_enrollments
  validates_presence_of :due_at, :title, :review_due_at

  def task_list
    task_list = []
  	taggings = Tagging.where("taggable_id = ?", self.id)
  	for tagging in taggings
      if self.milestone_list.include?(tagging.tag_name)
        unless tagging.close_at.blank?
          task = { :name => tagging.tag_name, :open_at => tagging.open_at, :close_at => tagging.close_at, :review_open_at => tagging.review_open_at, :review_close_at => tagging.review_close_at }
          task_list << task
        end
      end
  	end
    return task_list
  end

  def ended?
    self.due_at < Time.now
  end

  def enroll_with_lti(user, lti_params)
    enrollment = self.lti_enrollments.find_or_initialize_by_user_id(user.id)
    enrollment.lti_user_id = lti_params[:user_id]
    enrollment.lis_result_sourcedid = lti_params[:lis_result_sourcedid]
    enrollment.lis_outcome_service_url = lti_params[:lis_outcome_service_url]

    return enrollment.save
  end

  def lti_user(lti_params)
    enrollment = self.lti_enrollments.find_or_initialize_by_lti_user_id(lti_params[:user_id])
    if enrollment.nil?
      return nil
    else
      return enrollment.user
    end
  end


  def push_grades(user_id, max_push_count)
    answers = Answer.where("user_id = ? and push_count <= ?", user_id, max_push_count)
    uri = URI.parse "https://class.coursera.org/hci-004/assignment/api/update_score"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ca_file = Rails.root.join("config/cacert.pem").to_s
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # req = Net::HTTP::Post.new(uri.request_uri)
    answers.each do |a|
      # raise user_id.inspect
      if a.state != "graded" #special case qn 1
        a.current_score = a.new_get_grade
        a.save
      end
      post_args = {'api_key' => API_KEY, 'user_id' => user_id.cid,
        'assignment_part_sid' => "question#{a.question_id}",
        'score' => a.current_score}

      # req.set_form_data post_args
      begin
        resp = http.post(uri.request_uri, "api_key=#{API_KEY}&user_id=#{user_id.cid}&assignment_part_sid=question#{a.question_id}&score=#{a.current_score}&feedback=#{CGI::escape("For detailed feedback, please <a href='http://www.peergrademe.com/grading/my_grades'>click here</a>.")}")
      rescue Exception => e
        logger.error "Push failed for answer id=#{a.id}; Exception: #{e.inspect}"
        sleep(10)
        logger.error "Restarting after waiting 10s"
        next
      end

      if resp.body == '{"status":"202"}'
        logger.info "Success: Response #{resp.body}"
        a.increment!(:push_count)
      else
        logger.error "Push failed for answer id=#{a.id}; Response #{resp.body}"
      end
    end
  end

  #begin vineet
  def push_grades_edx(user)
      puts "user_id is #{user.id}"
      puts "starting pushing grades for user #{user.email}"

      answers = Answer.where("user_id = ?", user.id)
      puts "ansers are #{answers}"

    if !answers.nil?
      answers.each do |a|
        # raise user_id.inspect
        if a.state != "graded" #special case qn 1
          #todo - fix current_score
          a.current_score = 1#a.new_get_grade
          puts "ans current score is #{a.current_score}"
          a.save
        end

          #coursera
        #@lis_outcome_service_url = "https://api.coursera.org/lti/v1/grade"
        #@lis_result_sourcedid = "970447::1::585446::mxAHNKDlx3Rp9THqlKmSDmUSGGA"

        @course = Course.find(1) #or self.course
        @enrollment = self.lti_enrollments.find(user.id) #todo - when is lti_enrollment set up
        puts "#{@enrollment.lis_outcome_service_url}"
        #edx
        #@lis_outcome_service_url = "https://preview.class.stanford.edu/courses/Stanford/EXP1/Experimental_Assessment_Test/xblock/i4x:;_;_Stanford;_EXP1;_lti;_bc7feed267bb404bbf6da1e8749ef45a/handler_noauth/grade_handler"
        #@lis_result_sourcedid = "Stanford/EXP1/Experimental_Assessment_Test:class.stanford.edu-i4x-Stanford-EXP1-lti-bc7feed267bb404bbf6da1e8749ef45a:9fac061ede3489b6c1cac27c0b93a338"
        consumer = OAuth::Consumer.new(@course.consumer_key, @course.consumer_secret)
        token = OAuth::AccessToken.new(consumer)
        begin
          res = token.post(
              @enrollment.lis_outcome_service_url,#@lis_outcome_service_url,#@lis_result_sourcedid,
              a.current_score,#generate_request_xml2(0.4, @lis_result_sourcedid),
              'Content-Type' => 'text/plain'#'Content-Type' => 'application/xml' #vineet - fix xml
          )

          puts "#{res.code}"
        rescue Exception => e
          puts "Connect failed. Exception: #{e.inspect}"
        end #end of begin

        if res.body = "200" #res.body == '{"status":"200"}'
          puts "Success: Response #{res.body}"
          #a.increment!(:push_count)
        else
          puts "Push failed for answer id=#{a.id}; Response #{res.body}"
        end

        puts "finished pushing grades for user #{user.email}"
      end #end of do
    end # end of if answer.nil
  end #end of def method
  #end vineet


  def regrade!
    ###
    # setup variables
    ###
    milestone_credit = 0
    exchange_review_credit = 1
    paired_review_credit = 2 #half for each half of the pair
    final_review_credit = 3
    paired_review_threshold = 1
    final_review_threshold = 1

    return if self.grades_frozen?
    logger.info "Regrading Assignment #{self.id}"
    assignment = self
    AssignmentGrade.destroy_all(assignment_id: assignment.id)
    admins = assignment.course.instructors
    Enrollment.where(course: assignment.course).each do |enrollment|
      student = enrollment.user
      next if student.nil?
      answers = self.answers.where(user_id: student.id, submitted: true).order('submitted_at desc')
      answers.each do |answer|
        regrade_submission(answer)
      end #answer
    end #enrollment
  end #def

  def regrade_submission(answer)
    assignment = self
    return if AssignmentGrade.where(answer_id: answer.id, overridden: true).count > 0 or assignment.grades_frozen?
    AssignmentGrade.destroy_all(assignment_id: assignment.id, answer_id: answer.id)
    admins = assignment.course.instructors
    student = answer.user
    if !answer.nil?
      final_reviews = Review.where(review_type: "final", active: true, answer_id: answer.id, review_method: "normal")
      staff_reviews = Review.where(review_type: "final", review_method: "normal", active: true, answer_id: answer.id, user_id: admins)
      grade_type = "Peer grade"
      if !staff_reviews.blank?
        final_reviews = staff_reviews
        grade_type = "Staff grade"
      end
      assignment.rubric_items.each do |rubric|
        rubric.answer_attributes.each do |answer_attribute|
          if answer_attribute.attribute_type == "binary"
            marked_count = answer_attribute.feedback_items.where(review_id: final_reviews.pluck(:id)).select("review_id").distinct.count

            attribute_score = answer_attribute.score.nil? ? 0 : answer_attribute.score
            attribute_credit = (if final_reviews.count >= 3
                       marked_count >= 2 ? attribute_score : 0
                      elsif final_reviews.count > 0 and final_reviews.count < 3
                       ((attribute_score * marked_count/final_reviews.count))
                      else
                        0
                      end)
          else
            #this is a non-binary score
            attribute_weights = FeedbackItemAttribute.where(
              answer_attribute: answer_attribute,
              feedback_item_id: answer_attribute.feedback_items.where(review_id: final_reviews.pluck(:id))
              ).pluck(:weight)
            if attribute_weights.empty?
              attribute_credit = 0
            else
              attribute_credit= attribute_weights.median * answer_attribute.score
            end
            marked_count = attribute_weights.length
          end

          AssignmentGrade.create(user: student, assignment: assignment,
            answer: answer,
            is_final: answer.is_final?,
            grade_type: "#{rubric.short_title}: #{answer_attribute.description} (#{grade_type})",
            credit: attribute_credit,
            marked_reviews: marked_count,
            total_reviews: final_reviews.count,
            rubric_item_id: rubric.id,
            experimental: false,
            source: grade_type)
        end #answer_attribute
      end #rubric

      final_reviews_count = final_reviews.count
      if final_reviews_count > 0
        how_exceptional = final_reviews.where(out_of_box_answer: true).count/final_reviews_count
        if how_exceptional > 0.5
              AssignmentGrade.create(user: student, assignment: assignment,
              answer: answer,
              is_final: answer.is_final?,
              grade_type: "Exceptionally good submission (bonus)",
              credit: 1,
              marked_reviews: 1,
              total_reviews: final_reviews.count,
              rubric_item_id: nil,
              experimental: false,
              source: grade_type)
        end
      end
    end  #!answer.nil?
  end

  def experimental_grade!
    ###
    # setup variables
    ###
    milestone_credit = 0
    exchange_review_credit = 1
    paired_review_credit = 2 #half for each half of the pair
    final_review_credit = 3
    paired_review_threshold = 1
    final_review_threshold = 1


    logger.info "Regrading Assignment #{self.id}"
    assignment = self
    admins = assignment.course.instructors
    Enrollment.where(course: assignment.course).each do |enrollment|
      student = enrollment.user
      next if student.nil?
      answers = self.answers.where(user_id: student.id, submitted: true).order('submitted_at desc')
      answers.each do |answer|
        if !answer.nil?
          final_reviews = Review.where(review_type: "final", active: true, answer_id: answer.id, review_method: "normal")

          staff_reviews = Review.where(review_type: "final", review_method: "normal", active: true, answer_id: answer.id, user_id: admins)
          grade_type = "Peer grade"

          regrade_with_type(answer,assignment, final_reviews, grade_type, student)
          if !staff_reviews.blank?
            grade_type = "Staff grade"
            regrade_with_type(answer,assignment, staff_reviews, grade_type, student)
          end
        end  #!answer.nil?
      end #answer
    end #enrollment
  end #def

  def regrade_with_type(answer,assignment, final_reviews, grade_type, student)
    return if final_reviews.count == 0
    assignment.rubric_items.each do |rubric|
      rubric.answer_attributes.each do |answer_attribute|
        marked_count = answer_attribute.feedback_items.where(review_id: final_reviews.pluck(:id)).select("review_id").distinct.count

        attribute_score = answer_attribute.score.nil? ? 0 : answer_attribute.score
        attribute_credit = (if final_reviews.count >= 3
                   marked_count >= 2 ? attribute_score : 0
                  elsif final_reviews.count > 0 and final_reviews.count < 3
                   ((attribute_score * marked_count/final_reviews.count))
                  else
                    0
                  end)

        AssignmentGrade.create(user: student, assignment: assignment,
          answer: answer,
          is_final: answer.is_final?,
          grade_type: "#{rubric.short_title}: #{answer_attribute.description}",
          credit: attribute_credit,
          marked_reviews: marked_count,
          total_reviews: final_reviews.count,
          rubric_item_id: rubric.id,
          experimental: true,
          source: grade_type)
      end #answer_attribute
    end #rubric
  end

  handle_asynchronously :regrade!
end

class Array
  def median
    sorted = self.sort
    half_len = (sorted.length / 2.0).ceil
    (sorted[half_len-1] + sorted[-half_len]) / 2.0
  end
end
