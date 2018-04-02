class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
			t.integer :user_id
			t.integer :project_id
			t.string :title
			t.text :content
			t.boolean :status_flag
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
