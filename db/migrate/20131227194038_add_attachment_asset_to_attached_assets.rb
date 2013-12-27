class AddAttachmentAssetToAttachedAssets < ActiveRecord::Migration
  def self.up
    change_table :attached_assets do |t|
      t.attachment :asset
    end
  end

  def self.down
    drop_attached_file :attached_assets, :asset
  end
end
