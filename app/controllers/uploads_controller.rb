class UploadsController < ApplicationController
  require 'securerandom'
  def create
	sha1  = OpenSSL::Digest::Digest.new('sha1')
  	name = params[:name]
  	mimetype = params[:type]

  	s3 = AWS::S3.new
#   	AWS_ACCESS_KEY_ID:          AKIAJURV2I6AJSU4NOAQ
# AWS_SECRET_ACCESS_KEY:      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
# S3_BUCKET_NAME:             ucsdhutchins
# AWS_HOST_NAME:              s3-us-west-2.amazonaws.com
	#Don't trust user names. Can inject scripts etc.
	name_string = SecureRandom.uuid + File.extname(name)
	
	new_object = s3.buckets[ENV['S3_BUCKET_NAME']].objects[name_string]
	return_url = new_object.url_for(:put, secure: true, acl:'public_read', content_type: mimetype)
  	respond_to do |format|
  		format.js {render text: return_url}
  	end
  end

  private
  def upload_params
  	params.permit(:name,:type)
  end
end
