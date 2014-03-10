class AddDeletedFlagToAttachedAssets < ActiveRecord::Migration
  def change
    add_column :attached_assets, :deleted, :boolean, default: false
  end
end
