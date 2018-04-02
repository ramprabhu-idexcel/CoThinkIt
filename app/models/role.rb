class Role < ActiveRecord::Base
	has_many :project_users, :dependent=>:destroy
  def self.find_value(array)
    find(:all,:conditions=>['name NOT IN(?)',array])
  end
  
  def self.owner_id
    owner=find_by_name("Project Owner") 
    owner ? owner.id : 1
  end
  
  def self.guest_id
    guest=find_by_name("Guest")
    guest ? guest.id : 4
  end
	
  def self.team_member_id
    team_member=find_by_name("Team Member")
    team_member ? team_member.id : 4
  end	
end
