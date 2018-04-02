class AddStatusColumnInPostAndComments < ActiveRecord::Migration
  def self.up
		add_column :posts, :status, :string
		add_column :comments, :status, :string
  end

  def self.down
		remove_column :posts, :status
		remove_column :comments, :status
  end
end
