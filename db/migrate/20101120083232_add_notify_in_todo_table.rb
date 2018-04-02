class AddNotifyInTodoTable < ActiveRecord::Migration
  def self.up
		add_column(:todos,:is_notify,:boolean,:default => false)
  end

  def self.down
		remove_column(:todos,:is_notify)
  end
end
