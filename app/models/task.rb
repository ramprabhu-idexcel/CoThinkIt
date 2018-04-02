class Task < ActiveRecord::Base
	has_many :attachments ,:as => :attachable, :dependent=>:destroy
	belongs_to :project	
	belongs_to :user
	has_many :todos , :dependent=>:destroy
	has_many :events ,:as => :resource, :dependent=>:destroy	
	has_many :comments ,:as => :commentable, :dependent=>:destroy	
	
	validates_presence_of :title ,:message => "Please enter a title for the task"
	after_save :create_event
 	
  def self.tasks_in_date(project_ids,date)
    find(:all,:conditions=>['project_id in (?) AND DATE(due_date)=? AND is_completed=?',project_ids,date,false])
  end
	
	def create_event
		Event.update_event(self,self.project_id,self.user_id)
	end	
	
end
