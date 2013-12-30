class AddAssignmentIdToAnswer < ActiveRecord::Migration
  def change
    add_reference :answers, :assignment
  end
end
