class AddInvitationCodeToProjectUsers < ActiveRecord::Migration
  def self.up
    add_column :project_users, :invitation_code, :string,:limit=>40
  end

  def self.down
    remove_column :project_users, :invitation_code
  end
end
