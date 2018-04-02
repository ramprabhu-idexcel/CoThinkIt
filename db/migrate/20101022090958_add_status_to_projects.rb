class AddStatusToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :project_status, :boolean,:default => "1"

  end

  def self.down
    remove_column :projects, :project_status
  end
end
