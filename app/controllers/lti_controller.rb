class LtiController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:enroll_in_assignment]
  before_filter :authenticate_user!, only: :complete_enrollment

  def enroll_in_assignment
    # this workhorse method has to:
    # - accept incoming LTI connections
    # - Check if the target assignment is LTI-friendly
    # -- If the user logged in, store the LTI credentials in a user assignment join table
    # -- If not, save those credentials temporarily, and ask the user to create an account
    # --- But if the LTI request comes with email and name (e.g. from Coursera), 
    # we don't need to ask about accounts. If the account exists, we simply log in
    # If not, after log in, we store credentials
    #redirect to assignment
    @assignment = Assignment.find(lti_params[:id])
    @course = @assignment.course

    provider = IMS::LTI::ToolProvider.new(@course.consumer_key, 
      @course.consumer_secret, 
      lti_params)
    if provider.valid_request?(request, false)
      #Process
      if user_signed_in? 
        if @assignment.enroll_with_lti(current_user, lti_params)
          redirect_to @assignment, notice: "Welcome back, #{current_user.name}" and return
        else
          redirect_to @assignment, alert: "We couldn't get your credentials" and return
        end
      end
      if !provider.lis_person_contact_email_primary.blank?
        #at this point, they aren't logged in, but we have their email.
        user = User.find_for_authentication email: provider.lis_person_contact_email_primary
        if !user.nil?
          sign_in(:user, user)
          if @assignment.enroll_with_lti(current_user, lti_params)
            redirect_to @assignment, notice: "Welcome back, #{current_user.name}!" and return
          else
            redirect_to @assignment, alert: "We couldn't get your credentials" and return  
          end
        else
          session["user_return_to"] = complete_lti_enrollment_path(@assignment, lti_params)
          authenticate_user!  
        end
      else
        session["user_return_to"] = complete_lti_enrollment_path(@assignment, lti_params)
        authenticate_user!
      end
    else
      redirect_to root_path, alert: "Your LTI request was broken. If you're a student, please let your staff know."
    end
  end

	def test
		@course = Course.find(1)
		#coursera
		@lis_outcome_service_url = "https://api.coursera.org/lti/v1/grade"
		@lis_result_sourcedid = "970447::1::585446::mxAHNKDlx3Rp9THqlKmSDmUSGGA"


		#edx
		# @lis_outcome_service_url = "https://preview.class.stanford.edu/courses/Stanford/EXP1/Experimental_Assessment_Test/xblock/i4x:;_;_Stanford;_EXP1;_lti;_0392af58fbaf4415bbcc4fedb3220ea9/handler_noauth/grade_handler"
		# @lis_result_sourcedid = "Stanford/EXP1/Experimental_Assessment_Test:class.stanford.edu-i4x-Stanford-EXP1-lti-0392af58fbaf4415bbcc4fedb3220ea9:9fac061ede3489b6c1cac27c0b93a338"
		consumer = OAuth::Consumer.new(@course.consumer_key, @course.consumer_secret)
      	token = OAuth::AccessToken.new(consumer)
      	res = token.post(
              @lis_outcome_service_url,
              generate_request_xml(0.4, @lis_result_sourcedid),
              'Content-Type' => 'application/xml'
      	)

		render xml: res.body
	end

  def complete_enrollment
    @assignment = Assignment.find(lti_params[:id])

    if @assignment.enroll_with_lti(current_user, lti_params)
      redirect_to @assignment, notice: "Welcome back, #{current_user.name}" and return
    else
      redirect_to @assignment, alert: "We didn't get your LTI credentials. Try again." and return
    end
  end

	private

	def generate_request_xml(score, lis_result_sourcedid)
		return '<?xml version = "1.0" encoding = "UTF-8"?>
            <imsx_POXEnvelopeRequest xmlns = "some_link (may be not required)">
              <imsx_POXHeader>
                <imsx_POXRequestHeaderInfo>
                  <imsx_version>V1.0</imsx_version>
                  <imsx_messageIdentifier>'+SecureRandom.base64(32)+'</imsx_messageIdentifier>
                </imsx_POXRequestHeaderInfo>
              </imsx_POXHeader>
              <imsx_POXBody>
                <replaceResultRequest>
                  <resultRecord>
                    <sourcedGUID>
                      <sourcedId>' +lis_result_sourcedid +'</sourcedId>
                    </sourcedGUID>
                    <result>
                      <resultScore>
                        <language>en-us</language>
                        <textString>'+score.to_s+'</textString>
                      </resultScore>
                    </result>
                  </resultRecord>
                </replaceResultRequest>
              </imsx_POXBody>
            </imsx_POXEnvelopeRequest>'
	end

  def lti_params
    params.permit(:tool_consumer_info_product_family_code,
        :oauth_signature_method,
        :lis_outcome_service_url,
        :tool_consumer_info_version,
        :oauth_signature,
        :resource_link_title,
        :lti_message_type,
        :lis_result_sourcedid,
        :lis_person_name_full,
        :context_label,
        :oauth_consumer_key,
        :user_id,
        :oauth_version,
        :resource_link_id,
        :oauth_callback,
        :lis_person_contact_email_primary,
        :roles,
        :launch_presentation_locale,
        :context_title,
        :tool_consumer_instance_guid,
        :oauth_timestamp,
        :lti_version,
        :ext_basiclti_submit,
        :context_id,
        :oauth_nonce,
        :tool_consumer_instance_description,
        :id)
  end
end
