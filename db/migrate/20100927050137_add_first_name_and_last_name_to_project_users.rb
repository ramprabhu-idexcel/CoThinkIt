class AddFirstNameAndLastNameToProjectUsers < ActiveRecord::Migration
  def self.up
    add_column :project_users, :first_name, :string
    add_column :project_users, :last_name, :string
  end

  def self.down
    remove_column :project_users, :last_name
    remove_column :project_users, :first_name
  end
end
