class AddStatusToTaskAndProject < ActiveRecord::Migration
  def self.up
		add_column(:todos,:todo_status,:string,:default => "Not Started")
		add_column(:projects,:is_completed,:boolean,:default => false)
  end

  def self.down
		remove_column(:todos,:todo_status)
		remove_column(:projects,:is_completed)		
  end
end
