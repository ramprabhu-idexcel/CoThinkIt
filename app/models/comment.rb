class Comment < ActiveRecord::Base
		has_many :attachments ,:as => :attachable, :dependent=>:destroy
		has_many :history_posts ,:as => :resource, :dependent=>:destroy, :order => 'created_at desc'
		has_many :events ,:as => :resource, :dependent=>:destroy
	  belongs_to :commentable, :polymorphic => true			
		belongs_to :user
		belongs_to :project
		
		validates_presence_of :comment ,:message => "Please enter your comment"
		
		after_create :create_event	
		
		def create_event
      if self.commentable_type == "Post" or  self.commentable_type == "Task"	
				 Event.create_event(self,self.commentable.project_id,self.commentable.user_id)
			elsif self.commentable_type == "Todo"	
				 Event.create_event(self,self.commentable.task.project_id,self.commentable.task.user_id)
			end	
		end			
	
	
		
		def self.send_email_notification_for_comment_creation
			comments = Comment.find_all_by_email_notify(true)
			for comment in comments
					if comment.commentable_type == "Post"
						  post = comment.commentable
								#	if !post.email_notification.nil? and !post.email_notification.blank?
								#users = User.find_all_by_id(post.email_notification.split(",")) 
								notify_users=EmailNotification.find(:all, :conditions=>['resource_id=? and resource_type=? and is_notify=?', post.id, "Post", true])
								for notify in notify_users
									user = User.find_by_id(notify.user_id) 
									if user.id != comment.user_id
										
												UserMailer.deliver_post_comment_notify_mail(post.project,post,comment,post.user,user,"#{post.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"," ") 
									end	
								comment.update_attributes(:email_notify=>false)
							end					
					elsif comment.commentable_type == "Todo"
						
							todo = comment.commentable
							#todo_users = todo.todo_users
							notify_users=EmailNotification.find(:all, :conditions=>['resource_id=? and resource_type=? and is_notify=?', todo.id, "Todo", true])
							for notify in notify_users
								user= User.find_by_id(notify.user_id)
								each_user=TodoUser.find_by_user_id_and_todo_id(notify.user_id,todo.id)
								if user and user.id != comment.user_id and each_user
									UserMailer.deliver_todo_comment_notify_mail(each_user.todo.task.project,each_user,comment,each_user.user,user,"#{each_user.todo.task.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"," ")
								end	
									comment.update_attributes(:email_notify=>false)
								end	
								
								elsif comment.commentable_type == "Task"
						
							task = comment.commentable
						
							#todo_users = todo.todo_users
							notify_users=EmailNotification.find(:all, :conditions=>['resource_id=? and resource_type=? and is_notify=?', task.id, "Task", true])
							for notify in notify_users
								user= User.find_by_id(notify.user_id)
								#each_user=TodoUser.find_by_user_id_and_todo_id(notify.user_id,todo.id)
								if user and user.id != comment.user_id
									
									UserMailer.deliver_task_comment_notify_mail(task.project,task,comment,task.user,user,"#{task.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"," ")
								end	
									comment.update_attributes(:email_notify=>false)
								end	
								
					end
				end	
				
		end	
	
	
	
	
	
	
end
