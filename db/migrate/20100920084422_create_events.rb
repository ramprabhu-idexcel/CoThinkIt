class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
			t.integer :resource_id
			t.string :resource_type
			t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
