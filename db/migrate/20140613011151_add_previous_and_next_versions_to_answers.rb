class AddPreviousAndNextVersionsToAnswers < ActiveRecord::Migration
  def change
    add_belongs_to :answers, :previous_version
  end
end
