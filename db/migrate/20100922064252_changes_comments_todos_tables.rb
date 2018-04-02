class ChangesCommentsTodosTables < ActiveRecord::Migration
  def self.up
		add_column(:comments, :user_id, :integer)
		add_column(:todos, :is_completed, :boolean)
  end

  def self.down
		remove_column(:comments, :user_id)
		remove_column(:todos, :is_completed)		
  end
end
