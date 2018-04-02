class CreateHistoryPosts < ActiveRecord::Migration
  def self.up
    create_table :history_posts do |t|
			t.integer :resource_id
			t.string :resource_type
			t.string :action
			t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :history_posts
  end
end
