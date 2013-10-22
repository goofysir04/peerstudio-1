class AddStateToAnswer < ActiveRecord::Migration
  def change
  	add_column :answers, :state, :string, default: "identify"
  end
end
