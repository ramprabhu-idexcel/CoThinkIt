class Post < ActiveRecord::Base
		has_many :attachments ,:as => :attachable, :dependent=>:destroy
		belongs_to :project
		belongs_to :user
		has_many :history_posts ,:as => :resource, :dependent=>:destroy, :order => 'created_at desc'
		has_many :events ,:as => :resource, :dependent=>:destroy		
		has_many :comments ,:as => :commentable, :dependent=>:destroy	
		has_many :email_notifications ,:as => :resource, :dependent=>:destroy		

		after_create :create_event,:post_history_create
		after_save :mail_subscribe
		
		validates_presence_of :title ,:message => "Please enter a title for your post"
	
		def create_event

			Event.create_event(self,self.project_id,self.user_id)
		end			
				
		def self.send_email_notify_to_post_creation
			posts = Post.find_all_by_email_notify(true)
			for post in posts
		#		if !post.email_notification.nil? and !post.email_notification.blank?
						#email_nofitications = User.find_all_by_id(post.email_notification.split(","))
							notify_users=EmailNotification.find(:all, :conditions=>['resource_id=? and resource_type=? and is_notify=?', post.id, "Post", true])
							for notify in notify_users
									email = User.find_by_id(notify.user_id) 			
									if email.id != post.user_id
									UserMailer.deliver_new_post_notification(post.user.first_name,email,post,post.project,"#{post.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"," ")  
									end
							end
							post.update_attributes(:email_notify=>false)
			#	end
			end
			
		end	
		
		def mail_subscribe
			EmailNotification.subscribe_list(self, self.email_notification,self.user_id) if !self.email_notification.nil?
		end
    
	def post_history_create
    history = HistoryPost.new(:user_id=>self.user_id,:action=>"created post")
		self.history_posts << history
  end
		
end
