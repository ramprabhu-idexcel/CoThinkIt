class Todo < ActiveRecord::Base
	belongs_to :task
	belongs_to :user
  belongs_to :project
	has_many :events ,:as => :resource, :dependent=>:destroy		
	has_many :comments ,:as => :commentable, :dependent=>:destroy
  has_many :todo_users, :dependent=>:destroy		
	has_many :email_notifications ,:as => :resource, :dependent=>:destroy
	
	validates_presence_of :title ,:message => "Please enter a title for the to-do"	
	after_save :create_event
	after_save :mail_subscribe	
  
  def self.todos_in_date(project_ids,date)
    Todo.find(:all,:conditions=>['tasks.project_id IN (?) AND DATE(todos.due_date)=? AND todos.is_completed=?',project_ids,date,false],:include=>:task)
  end
	
	def create_event
		#~ self.task.project_id.nil? ? Event.update_event(self,nil,self.task.user_id) :
		Event.update_event(self,self.task.project_id,self.task.user_id) 
		 
	end	



	def self.send_mail_to_todo_assignee
		todos = Todo.find_all_by_email_notify(true)
			for todo in todos
				#todo_users = todo.todo_users
				notify_users=EmailNotification.find(:all, :conditions=>['resource_id=? and resource_type=? and is_notify=?', todo.id, "Todo", true])
				for notify in notify_users
								user= User.find_by_id(notify.user_id)
								each_user=TodoUser.find_by_user_id_and_todo_id(notify.user_id,todo.id)
				#~ for each_user in todo_users
					#~ user= User.find_by_id(each_user.user_id)
					if user && user.id!=todo.user_id && todo.is_notify==true
							UserMailer.deliver_todo_assign_mail(todo.task.project,todo,todo.user,user,"#{todo.task.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"," ")
					end						
				end		
				todo.update_attributes(:email_notify=>false)
			end	
		end	
		
		def mail_subscribe
			
			EmailNotification.subscribe_list_for_todo(self, self.todo_users,self.task.user_id) 
		end
	
def self.change_status_todo
	
	time=Time.now.gmtime
	date=time.to_date
	@todos=Todo.find(:all, :conditions=>['due_date<? and todo_status!=?', date, "Late"])
	@todos.each do |todo|
		todo.update_attributes(:todo_status=>"Late")
	end
end

  def self.late_tasks(project_ids,login_time)
    find(:all, :conditions=>['todo_status=? AND todos.is_completed=? AND todos.created_at>=? AND tasks.project_id IN (?)', "Late", false,login_time,convert_array(project_ids)],:include=>:task)
  end
  
  def self.pending_tasks(project_ids,login_time)
    find(:all, :conditions=>['todo_status=? AND todos.is_completed=? AND todos.created_at>=? AND tasks.project_id IN (?)', "Not Started", false,login_time,convert_array(project_ids)],:include=>:task)
  end
  
  def self.task_in_progress(project_ids,login_time)
    find(:all, :conditions=>['todo_status=? AND todos.is_completed=? AND todos.created_at>=? AND tasks.project_id IN (?)', "In Progress", false,login_time,convert_array(project_ids)],:include=>:task)
  end
  
  def self.global_tasks(project_ids,login_time,status)
    find(:all, :conditions=>['todo_status=? AND todos.is_completed=? AND todos.created_at>=? AND tasks.project_id IN (?)', status, false,login_time,convert_array(project_ids)],:include=>:task)
  end
  
  def self.convert_array(project_ids)
    project_ids.is_a?(Array) ? project_ids : [projects_ids]
  end

end
