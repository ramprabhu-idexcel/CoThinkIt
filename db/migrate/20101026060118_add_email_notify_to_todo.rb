class AddEmailNotifyToTodo < ActiveRecord::Migration
  def self.up
    add_column :todos, :email_notify, :boolean
    add_column :posts, :email_notify, :boolean
    add_column :comments, :email_notify, :boolean
  end

  def self.down
    remove_column :todos, :email_notify
    remove_column :posts, :email_notify
    remove_column :comments, :email_notify
  end
end
