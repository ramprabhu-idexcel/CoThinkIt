class AddCredentialsToAdmins < ActiveRecord::Migration
  def self.up
    add_column :admins, :crypted_password, :string,:limit =>40
    add_column :admins, :salt, :string,:limit =>40
    remove_column :admins,:password
    admin = Admin.create!(:username=>"CF-Admin", :password=>"railsfactory", :password_confirmation=> "railsfactory")
    admin.save!
  end

  def self.down
    remove_column :admins, :salt
    remove_column :admins, :crypted_password
    add_column :admins,:password,:string,:default=>"railsfactory"
  end
end
