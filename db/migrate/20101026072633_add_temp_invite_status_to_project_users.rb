class AddTempInviteStatusToProjectUsers < ActiveRecord::Migration
  def self.up
    add_column :project_users, :temp_invite_status, :boolean, :default=>0
  end

  def self.down
    remove_column :project_users, :temp_invite_status
  end
end
