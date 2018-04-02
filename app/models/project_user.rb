require 'digest/sha1'
class ProjectUser < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	belongs_to :role
  belongs_to :member
  
  def make_invite_code
    self.invitation_code=Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save(false)
  end
	
	 def delete_invite_code  
   self.attributes = {:invitation_code => nil}  
   save(false)  
 end 
end
