class ChangesInTodoTable < ActiveRecord::Migration
  def self.up
		add_column(:todos ,:assignee_type,:string)
  end

  def self.down
		remove_column(:todos ,:assignee_type)
  end
end
