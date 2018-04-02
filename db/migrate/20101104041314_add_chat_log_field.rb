class AddChatLogField < ActiveRecord::Migration
  def self.up
		add_column(:chats,:log_created,:boolean,:default => true)
  end

  def self.down
		remove_column(:chats,:log_created)
  end
end
