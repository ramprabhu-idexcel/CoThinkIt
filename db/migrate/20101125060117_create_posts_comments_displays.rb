class CreatePostsCommentsDisplays < ActiveRecord::Migration
  def self.up
    create_table :posts_comments_displays do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :comment_id
      t.boolean :is_post_viewed, :defalut=>false
      t.boolean :is_comment_viewed, :default=>false
      t.boolean :is_post, :default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :posts_comments_displays
  end
end
