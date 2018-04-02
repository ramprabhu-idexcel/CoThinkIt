class AddEmailToProjectUsers < ActiveRecord::Migration
  def self.up
    add_column :project_users, :email, :string
  end

  def self.down
    remove_column :project_users, :email
  end
end
