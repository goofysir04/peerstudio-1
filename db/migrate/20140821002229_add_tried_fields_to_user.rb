class AddTriedFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :tried_answering, :boolean
    add_column :users, :tried_reviewing, :boolean
  end
end
