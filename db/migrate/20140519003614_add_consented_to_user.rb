class AddConsentedToUser < ActiveRecord::Migration
  def change
    add_column :users, :consented, :boolean
  end
end
