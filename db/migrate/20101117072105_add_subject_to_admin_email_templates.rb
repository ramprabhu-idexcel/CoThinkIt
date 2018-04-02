class AddSubjectToAdminEmailTemplates < ActiveRecord::Migration
  def self.up
    add_column :admin_email_templates, :from, :string
    add_column :admin_email_templates, :subject, :string
  end

  def self.down
    remove_column :admin_email_templates, :subject
    remove_column :admin_email_templates, :from
  end
end
