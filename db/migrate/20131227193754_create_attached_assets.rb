class CreateAttachedAssets < ActiveRecord::Migration
  def change
    create_table :attached_assets do |t|
      t.references :attachable, polymorphic: true
      t.timestamps
    end
  end
end
