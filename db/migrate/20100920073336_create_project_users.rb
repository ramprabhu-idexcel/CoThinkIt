class CreateProjectUsers < ActiveRecord::Migration
  def self.up
    create_table :project_users do |t|
			t.integer :user_id
			t.integer :project_id
			t.integer :role_id
			t.boolean :is_owner
			t.boolean :status
			t.boolean :online_status
      t.timestamps
    end
  end

  def self.down
    drop_table :project_users
  end
end
