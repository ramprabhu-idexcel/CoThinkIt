class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :chats
  end
end
