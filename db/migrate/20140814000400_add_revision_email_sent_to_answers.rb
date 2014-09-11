class AddRevisionEmailSentToAnswers < ActiveRecord::Migration
  def change
  	add_column :answers, :revision_email_sent, :boolean, :default => false
  end
end
