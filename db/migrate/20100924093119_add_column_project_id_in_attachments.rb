class AddColumnProjectIdInAttachments < ActiveRecord::Migration
  def self.up
		add_column :attachments, :project_id, :integer
  end

  def self.down
		remove_column :attachments, :project_id
  end
end
