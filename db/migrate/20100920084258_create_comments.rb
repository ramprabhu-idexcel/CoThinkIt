class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
			t.integer :commentable_id
			t.string :commentable_type
			t.text :comment
			t.boolean :status_flag
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
