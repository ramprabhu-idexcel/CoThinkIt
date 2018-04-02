class AddProjectOwnerToRoles < ActiveRecord::Migration
  def self.up
    Role.create(:name=>"Project Owner")
  end

  def self.down
    
  end
end
