class AttachedAsset < ActiveRecord::Base
	  has_attached_file :asset, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
	  	:default_url => "/images/:style/missing.png", 
	  	:storage => :s3
	  	# :path => ":class/:attachment/:id/:style/:filename", 
	  	# :url => ':s3_domain_url'

	  before_post_process :proces_images_only

	  def proces_images_only
	  	%w(image/jpg image/png image/gif).include?(asset_content_type)
	  end

	def self.copy_and_delete(paperclip_file_path, raw_source)
		s3 = AWS::S3.new #create new s3 object
		destination = s3.buckets[ENV['S3_BUCKET_NAME']].objects[paperclip_file_path]
		sub_source = CGI.unescape(raw_source)
		sub_source.slice!(0) if sub_source.start_with? '/' # the attached_file_file_path ends up adding an extra "/" in the beginning. We've removed this.
		source = s3.buckets[ENV['S3_BUCKET_NAME']].objects["#{sub_source}"]
		source.move_to(destination, {acl: :public_read}) #move_to is a method originating from the aws-sdk gem. 
		# source.delete #delete temp file.
	end

	def move_file_in_place(current_location)
		filename = self.asset_file_name
		new_path = "attached_assets/assets/#{('%09d' % self.id).scan(/\d{3}/).join("/")}/original/#{filename}"
		AttachedAsset.copy_and_delete(new_path, current_location)
	end
end
