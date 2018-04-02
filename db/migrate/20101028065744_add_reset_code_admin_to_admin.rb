class AddResetCodeAdminToAdmin < ActiveRecord::Migration
  def self.up
    add_column :admins, :reset_code_admin, :string
  end

  def self.down
    remove_column :admins, :reset_code_admin
  end
end
