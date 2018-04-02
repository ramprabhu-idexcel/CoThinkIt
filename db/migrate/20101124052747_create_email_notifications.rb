class CreateEmailNotifications < ActiveRecord::Migration
  def self.up
    create_table :email_notifications do |t|
      t.integer :resource_id
      t.string :resource_type
      t.integer :user_id
      t.boolean :is_notify

      t.timestamps
    end
  end

  def self.down
    drop_table :email_notifications
  end
end
