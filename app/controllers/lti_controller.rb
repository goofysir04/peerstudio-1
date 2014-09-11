class LtiController < ApplicationController
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
end
