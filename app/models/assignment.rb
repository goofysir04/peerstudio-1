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
  validates_presence_of :due_at, :title

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

end

