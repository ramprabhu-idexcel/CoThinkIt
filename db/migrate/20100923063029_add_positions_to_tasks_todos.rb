class AddPositionsToTasksTodos < ActiveRecord::Migration
  def self.up
		add_column(:todos,:position,:integer)
		add_column(:tasks,:position,:integer)
  end

  def self.down
		remove_column(:todos,:position)
		remove_column(:tasks,:position)		
  end
end
