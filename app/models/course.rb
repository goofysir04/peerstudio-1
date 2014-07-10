class Course < ActiveRecord::Base
  belongs_to :user
  has_many :assignments
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  has_many :enrollments
  has_many :students, through: :enrollments, source: :user
  def ended?
  	!self.open_enrollment
  end

  def regenerate_consumer_secret
  	SecureRandom.base64(32)
  end
  def regenerate_consumer_secret!
  	self.consumer_secret = self.regenerate_consumer_secret #Generate a secure 32-byte string
  	self.save!
  end
end
