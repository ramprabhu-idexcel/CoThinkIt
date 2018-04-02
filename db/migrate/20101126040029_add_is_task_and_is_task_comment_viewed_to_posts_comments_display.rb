class AddIsTaskAndIsTaskCommentViewedToPostsCommentsDisplay < ActiveRecord::Migration
  def self.up
    add_column :posts_comments_displays, :is_task, :boolean, :default=>false
    add_column :posts_comments_displays, :is_task_comment_viewed, :boolean, :default=>false
  end

  def self.down
    remove_column :posts_comments_displays, :is_task_comment_viewed
    remove_column :posts_comments_displays, :is_task
  end
end
