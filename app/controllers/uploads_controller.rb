class UploadsController < ApplicationController
  # require 'securerandom'
  def create
  	name = params[:name]
  	mimetype = params[:type]

  	s3 = AWS::S3.new
	name_string = SecureRandom.uuid + File.extname(name)
	
	new_object = s3.buckets[ENV['S3_BUCKET_NAME']].objects[name_string]
	return_url = (new_object.url_for(:put, secure: true, acl:'authenticated_read', content_type: mimetype)).to_s

  	respond_to do |format|
  		format.js {render text: URI.encode(return_url)}
  	end
  end

  private
  def upload_params
  	params.permit(:name,:type)
  end
end
