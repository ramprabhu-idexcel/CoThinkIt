class AddProjectToTokenizedUrls < ActiveRecord::Migration
  def self.up
    add_column :tokenized_urls, :project_id, :integer
  end

  def self.down
    remove_column :tokenized_urls, :project_id
  end
end
