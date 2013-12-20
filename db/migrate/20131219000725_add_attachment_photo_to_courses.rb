class AddAttachmentPhotoToCourses < ActiveRecord::Migration
  def self.up
    change_table :courses do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :courses, :photo
  end
end
