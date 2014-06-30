class AddForumLinkToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :forum_link, :text
  end
end
