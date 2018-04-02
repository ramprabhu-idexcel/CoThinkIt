class Event < ActiveRecord::Base
		belongs_to :project
	  belongs_to :resource, :polymorphic => true		
  
  #project_ids should be an array
  def self.project_events(project_ids,user) 
		a=[]
    #~ a<<find_all_by_project_id(project_ids,:order=>"created_at DESC")
		#~ a<<self.find(:all, :conditions=>['project_id IS NULL and user_id=?', user], :order=>"created_at DESC")
		a=self.find(:all, :conditions=>["((project_id IN (?)) or (project_id IS NULL and user_id=#{user}))", project_ids], :order=>"created_at DESC", :select=>"distinct events.*")
		a=a.flatten
return a
		
  end
  
  def self.events_in_date(project_ids,date)
    find_all_by_project_id(project_ids,:conditions=>['date(created_at)=?',date],:order=>"created_at DESC")
  end
  
    def self.events_in_date_project(project_id,date)
    find_all_by_project_id(project_id,:conditions=>['DATE(created_at)=?',date],:order=>"created_at DESC")
  end
  
  def self.project_dashboard_events(project_id) 
    find_all_by_project_id(project_id,:order=>"created_at DESC")
  end
	
	def self.create_event(resource,project_id,user_id)
		event = Event.new
		event.resource = resource
		event.project_id = project_id
		event.user_id=user_id
		event.save
	end	
	
	def self.update_event(resource,project_id,user_id)
 if project_id.nil?
	 event=Event.find(:first,:conditions => ["project_id is NULL and resource_id=? and resource_type=?",resource.id,resource.class.to_s])
else
		event = Event.find(:first,:conditions => ["project_id=? and resource_id=? and resource_type=?",project_id,resource.id,resource.class.to_s])
end
    event.destroy if event
    create_event(resource,project_id,user_id)		
	end
	
end
