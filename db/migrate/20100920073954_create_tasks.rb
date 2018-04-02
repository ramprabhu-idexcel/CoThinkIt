class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
			t.integer :user_id
			t.integer :project_id
			t.string :title
			t.text :description
			t.date :due_date
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
