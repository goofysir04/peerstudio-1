class AttachedAsset < ActiveRecord::Base
	  has_attached_file :asset, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png", :storage => :s3, :path => ":class/:attachment/:id/:style/:filename", :url => ':s3_domain_url'

	  before_post_process :proces_images_only

	  def proces_images_only
	  	%w(image/jpg image/png image/gif).include?(asset_content_type)
	  end
end
