class EmailNotificationForPost < ActiveRecord::Migration
  def self.up
		add_column :posts,:email_notification,:string
  end

  def self.down
		remove_column :posts,:email_notification
  end
end
