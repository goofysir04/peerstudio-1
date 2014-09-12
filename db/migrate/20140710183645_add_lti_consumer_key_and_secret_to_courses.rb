class AddLtiConsumerKeyAndSecretToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :consumer_key, :text
    add_column :courses, :consumer_secret, :text
  end
end
