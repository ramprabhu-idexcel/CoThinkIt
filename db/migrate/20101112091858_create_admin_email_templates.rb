class CreateAdminEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :admin_email_templates do |t|
      t.string :key
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_email_templates
  end
end
