class AddRevisionNameToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :revision_name, :string
  end
end
