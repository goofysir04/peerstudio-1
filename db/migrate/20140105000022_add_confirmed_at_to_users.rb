class AddConfirmedAtToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
  	add_column :users, :unconfirmed_email, :string
  	# t.string   :unconfirmed_email # Only if using reconfirmable

  end
end
