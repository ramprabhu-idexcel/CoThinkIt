class CreatePlanLimits < ActiveRecord::Migration
  def self.up
    create_table :plan_limits do |t|
      t.integer :user_id
      t.integer :max_storage_in_MB
      t.integer :max_bandwidth_in_MB
      t.integer :download_bandwidth_in_MB
      t.integer :no_of_users
      t.integer :no_of_projects

      t.timestamps
    end
  end

  def self.down
    drop_table :plan_limits
  end
end
