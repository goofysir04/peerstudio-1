class RenameRevisionNameToBaseRevisionNameInAnswers < ActiveRecord::Migration
  def change
  	rename_column :answers, :revision_name, :base_revision_name
  end
end
