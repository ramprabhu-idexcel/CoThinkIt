class CreateTodoCommentsDisplays < ActiveRecord::Migration
  def self.up
    create_table :todo_comments_displays do |t|
      t.integer :user_id
			t.integer :todo_id
			t.integer :comment_id
			t.boolean :is_viewed,:default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :todo_comments_displays
  end
end
