class Project < ActiveRecord::Base
	has_many :project_users, :dependent=>:destroy
	has_many :posts, :dependent=>:destroy
	has_many :tasks, :dependent=>:destroy	
	has_many :chats, :dependent=>:destroy	
	has_many :todos, :through=>:tasks
	has_many :events, :dependent=>:destroy
  belongs_to :user
  has_many :members,:through=>:project_users,:source => :user 
	has_many :comments
	has_many :attachments
  
  validates_presence_of :name,:message =>'Please give your project a name.'
  validates_length_of   :name,:maximum => 20,:message=>"Please enter a name that is less than twenty (20) characters."
  #~ validates_presence_of :url, :message =>'Please enter a URL for your project.'
  #~ validates_length_of   :url, :maximum => 20,:message =>'Please enter a URL that is less than twenty (20) characters.'
	validates_format_of :name, :with => /\A[a-zA-Z ]+([a-zA-Z ]|-|\d)*\Z/, :message=>"Improper value entered, special characters are not allowed" 

	validate :valid_project_name
	#~ validate :valid_url_name
  
  def active_members
    project_users.all(:conditions=>['status=?', true]).uniq
  end
  
  def chat_dates
    chats.find(:all,:select=>"DISTINCT Date(created_at) as date_s",:order => "created_at desc")
  end
  
  def owner
    project_user = project_users.find_by_is_owner(true)
		!project_user.nil? ? project_user.user : nil
  end
  
  def url_name 
    name.strip.downcase.gsub( /\s+/,'-')
  end
  
  def today_chats
    chats.find(:all,:conditions=>['Date(created_at)=?',Date.today],:order=>"created_at desc")
  end
	
	def find_last_four_dates
		chats.find(:all,:select=>"DISTINCT Date(created_at) as date_s",:order => "created_at desc",:limit => 4)
	end 
	
	def self.find_chat_logs
		@projects=self.find(:all)
		est_time=(Time.now.gmtime-18000).to_date
	
		days=[]
		days<<est_time
		days<<est_time-1
		days<<est_time+1
			est_time=est_time-1
		@projects.each do |project|
		project_owner=ProjectUser.find_by_project_id_and_is_owner(project.id, true)
		@chat=Chat.find(:all,:conditions=>['DATE(created_at) IN (?) AND project_id=? AND log_created=?', days,project.id,true], :order=>"created_at desc").group_by{|d| (d.created_at-18000).to_date}
		
		if @chat && !@chat.empty?
			@chat.each do |date, event|
		#		if date.to_s==est_time.to_s
					
					new_file=File.new("tmp/Chat-#{project.name}-#{est_time.strftime("%d-%m-%Y")}.txt", "w")
					new_file<<"Chat Log for #{est_time.strftime("%B %e, %Y")}\n\n\n"
					event.each do |chat|
						new_file<<"#{chat.user.first_name}:  #{chat.message} \n" if !chat.message.blank?
						if !chat.attachments.empty?
							chat.attachments.each do |attach|
								new_file<<"http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attach.id.to_s}/#{attach.filename}\n"
							end
						end
						chat.update_attributes(:log_created=> false)
					end
					new_file.close
					path="#{RAILS_ROOT}/tmp/"+"Chat-#{project.name}-#{est_time.strftime("%d-%m-%Y")}.txt"
					ActionController::UploadedTempfile.open("Chat-#{project.name}-#{est_time.strftime("%d-%m-%Y")}.txt") do |temp|
						temp.write(File.open(path).read)
						temp.original_path = path
						temp.content_type = "text/plain"
						d=Attachment.new
						d.uploaded_data = temp
						d.project_id=project.id
						d.attachable_type="User"
						d.attachable_id=project_owner.user.id
						d.save
						File.delete("tmp/Chat-#{project.name}-#{est_time.strftime("%d-%m-%Y")}.txt")
						end
					end
			#	end
			end
		end
	end
	
	def valid_project_name
		project=Project.find(:all,:conditions=>['name=? and project_users.is_owner=? AND project_users.user_id=?',self.name,true,project_users[0].user_id],:include=>:project_users)		
		if self.id.nil?
				project.empty? ? true : errors.add(:name,"Project name already taken.") 
		elsif !project.empty? 
			if  project.length >1
				 errors.add(:name,"Project name already taken.") 
			else
				 (project[0].id == self.id) ? true : errors.add(:name,"Project name already taken.") 
      end							
		end	
		false
  end
  
  def valid_url_name
    project=Project.find(:all,:conditions=>['url=? and project_users.is_owner=? AND project_users.user_id=?',self.url,true,project_users[0].user_id],:include=>:project_users)
		if self.id.nil?
				project.empty? ? true : errors.add(:url,"Project URL already taken.")
		elsif !project.empty? 
			if  project.length >1
				 errors.add(:url,"Project URL already taken.")
			else
				 (project[0].id == self.id) ? true : errors.add(:url,"Project URL already taken.")
      end							
		end	
		false
  end
  
  def pending_tasks(login_time)
    todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "Not Started", false,login_time])
  end
  
  def task_in_progress(login_time)
    todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "In Progress", false,login_time])
  end
  
  def late_tasks(login_time)
    todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "Late", false,login_time])
  end
	
	
		def self.project_suspend_and_delete
		@projects=self.find :all
		@projects.each do |proj|
			proj_user=ProjectUser.find_by_project_id_and_is_owner(proj.id,true)
			billing_hist=BillingHistory.find(:last, :conditions=>['user_id=?', proj_user.user_id]) if proj_user
			plan=Plan.find_by_name(billing_hist.plan_name) if billing_hist 
	
			if billing_hist && plan && plan.name!="Beta"
				d=Date.today
				proj_date=billing_hist.created_at
				proj_date=proj_date.to_date
				proj_date=proj_date+30
				proj_delete_date=proj_date+90
				if proj_date<d
					proj.update_attributes(:project_status=>false)
				end
				if proj_delete_date<d
					#~ proj.destroy
				end
				
			elsif !plan
				d=Date.today
				proj_date=proj.created_at
				proj_date=proj_date.to_date
				proj_date=proj_date+30
				proj_delete_date=proj_date+90
				if proj_date<d
					proj.update_attributes(:project_status=>false)
				end
				if proj_delete_date<d
					#~ proj.destroy
				end
				
			end
		end
		
		#for sending emails for 90 and 100 percent exceed
		@plan_limits=PlanLimits.find(:all, :conditions=>['is_90exceed=? or is_100exceed=?', true, true])
		@plan_limits.each do |plan|
			@billing_info=BillingInformation.find_by_user_id(plan.user_id)
			@user=User.find_by_id(plan.user_id)
			if @billing_info
				@now_plan=Plan.find_by_id(@billing_info.plan_id)
			else
				@now_plan=Plan.find_by_name("Trial")
			end
			if @now_plan.id!="1" && @now_plan.name!="Beta"
				if @now_plan.name=="Trial"
					@next_plan=Plan.find_by_id(4)
				else
				@next_plan=Plan.find_by_id(@now_plan.id-1)
			  end
				#~ UserMailer.deliver_exceed_90percent(@user, @now_plan, @next_plan) if plan.is_90exceed==true
				#~ UserMailer.deliver_exceed_100percent(@user, @now_plan, @next_plan) if plan.is_100exceed==true
				plan.update_attributes(:is_90exceed=>false,:is_100exceed=>false)
			end
		end
	end
	
	
end
