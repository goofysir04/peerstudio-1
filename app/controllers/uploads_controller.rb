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

  def authenticate_asset
    unless user_signed_in?
      redirect_to ActionController::Base.helpers.image_path("sign-in-required.png") and return
    end

    s3 = AWS::S3.new
    new_object = s3.buckets[ENV['S3_BUCKET_NAME']].objects[upload_params[:obj]]
    return_url = (new_object.url_for(:get, secure: true, expires: 1*60)).to_s
    redirect_to return_url
  end

  private
  def upload_params
  	params.permit(:name,:type, :obj)
  end
end
