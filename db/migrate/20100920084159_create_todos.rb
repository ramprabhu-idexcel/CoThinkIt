class CreateTodos < ActiveRecord::Migration
  def self.up
    create_table :todos do |t|
			t.integer :task_id
			t.integer :user_id
			t.string :title
			t.date :due_date			
      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
