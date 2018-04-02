# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'rubygems'
require 'aws/s3'
require 'fileutils' 
require 'sanitize'
class ApplicationController < ActionController::Base
# include SslRequirement


	include AuthenticatedSystem
	include ActionView::Helpers::TagHelper
  include AWS::S3
  helper :all #include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	#before_filter :authenticate
  POST_BUCKET="postfiles"
	rescue_from(ActionController::RoutingError) { redirect_to "http://#{APP_CONFIG[:site][:name]}/global" }
	rescue_from(ActionController::UnknownAction) { redirect_to "http://#{APP_CONFIG[:site][:name]}/global" }
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  #~ ActiveMerchant::Billing::Base.gateway_mode = :test 
  #~ include ActiveMerchant::Billing

  #~ rescue_from ActionController::RoutingError, :with=>:not_found
  
   def ssl_required?
     true
   end 
	 
  def not_found
    render :status=>404
  end
  
  def ensure_domain
    #~ if current_user
      #~ http_host = request.env['HTTP_HOST']
      #~ http_host_split = http_host.split(".")
      #~ company_name = http_host_split.first
      #~ if @project && @project.owner.site_address!=company_name
        #~ redirect_to '/not_found'
      #~ end
    #~ else
      #~ redirect_to '/login'
    #~ end
  end
  
  #for the pages before login
  def change_domain		
		if !current_user
			host = request.env['HTTP_HOST'].split('.')
			path=request.env['REQUEST_URI']
			if host.count>2
				redirect_to APP_CONFIG[:site_url].to_s+path and return
			end
		end
  end
  
	def current_project
		
		#~ @project = Project.find_by_id_and_project_status(params[:project_id],true)		
		#~ @project_user=ProjectUser.find_by_user_id_and_project_id(current_user.id,params[:project_id])
		#~ @projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		@project = Project.find_by_id(params[:project_id])
		@project_user=ProjectUser.find_by_user_id_and_project_id(current_user.id,params[:project_id])
		@projects=current_user.projects.all(:conditions=>['status=? and is_completed=?', true,false],:select => "distinct projects.*", :order=>"name") if current_user
		@site = request.env['HTTP_HOST'].split('.').first
		@project_name = params['project_name']
		@project_owner=	ProjectUser.find(:first, :conditions=>['project_id=? and is_owner =?', @project.id, true])

     if @project_owner
				@owner = User.find_by_id(@project_owner.user_id)			
			 @owner_site=@owner.site_address if @owner
		 end 
		 
			flag = (!@owner_site.nil? and @site == @owner_site)  ? false : true
		 #~ logger.info("#{request.env['HTTP_HOST']}")
		  #~ logger.info("#{request.inspect}")
		 #~ logger.info("project_name => #{@project_name} && Project_URL => #{@project.url}")
		 #~ logger.info("Owner==>#{@owner_site} && site ==> #{@site}")
		 #~ logger.info("Testing")
		 #~ logger.info("Check site address==> #{flag}")
		 #~ logger.info("Testing project name ==> #{@project_name != @project.url}")
		 #~ logger.info("final value => #{@project.nil? or @project_user.nil? or flag  or @project_name != @project.url}")
		
		 if @project.nil? or @project_user.nil? #or flag  or @project_name != @project.url
	 	 redirect_to "http://#{APP_CONFIG[:site][:name]}/global"
	 end
  end	
	
	def check_site_address
		@project = Project.find_by_id(params[:project_id])
		@site = request.env['HTTP_HOST'].split('.').first
		@project_name = params['project_name']
		@project_owner=	ProjectUser.find(:first, :conditions=>['project_id=? and is_owner =?', @project.id, true])
		  if @project_owner
				@owner = User.find_by_id(@project_owner.user_id)			
			 @owner_site=@owner.site_address if @owner
		 end 
		 	flag = (!@owner_site.nil? and @site == @owner_site)  ? false : true
		 #~ logger.info("#{request.env['HTTP_HOST']}")
		  #~ logger.info("#{request.inspect}")
		 #~ logger.info("project_name => #{@project_name} && Project_URL => #{@project.url}")
		 #~ logger.info("Owner==>#{@owner_site} && site ==> #{@site}")
		 #~ logger.info("Testing")
		 #~ logger.info("Check site address==> #{flag}")
		 #~ logger.info("Testing project name ==> #{@project_name != @project.url}")
		 #~ logger.info("final value => #{@project.nil? or @project_user.nil? or flag  or @project_name != @project.url}")
		  if flag  or @project_name != @project.url
	 	 redirect_to "http://#{APP_CONFIG[:site][:name]}/global"
	 end
	 
	end
	
	
	def online_users
		
		if params[:project_id]
			@project = Project.find_by_id(params[:project_id])		
		end

		send_users_offline

		@project_user=ProjectUser.find(:last, :conditions=>['user_id=? AND project_id=?', current_user.id, @project.id]) if @project
		@project_user.update_attributes(:online_status=>true) if @project_user && @project 
		@online_users=ProjectUser.find(:all, :conditions=>['project_id=? AND online_status=? AND user_id!=? AND updated_at>=?', @project.id, true, current_user.id, Time.now.gmtime-1800]) if @project
	end
	
	def online_users_on_global
		@projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
		@first_project_users=[]
		@projects.each do |project|
			proj_user=ProjectUser.find(:all, :conditions=>['project_id=? AND online_status=? AND user_id!=? AND updated_at>=?', project.id, true, current_user.id, Time.now.gmtime-1800])
			if proj_user && !proj_user.nil?
				@first_project_users<<proj_user
			end
		end
		@first_project_users=@first_project_users.flatten
		@first_project_users=@first_project_users.group_by{|d| d.project_id}
	end
 
 def send_users_offline
	 @project_user=ProjectUser.find(:all, :conditions=>['user_id=?', current_user.id])
	 @project_user.each do |user|
		 user.update_attributes(:online_status=>false)
	 end
	 
	end

	def process_file_uploads(attachable_model)		
		params[:attachment].each do |key, value|
			if value and value != ''
				@attachment = Attachment.new(Hash['uploaded_data' => value])
				@attachment.project_id = @project.id
				attachable_model.attachments << @attachment
			end
		end if params[:attachment]
	end
	
  #sending invitation for the exisiting members
  def send_invitations(user_ids,project)
		
    user_ids.each do |id|
      unless current_user.id==id.to_i
				user=User.find_by_id id
        @project_user= ProjectUser.create(:user_id=>id,:status=>false,:project_id=>project.id,:role_id=>Role.team_member_id, :is_owner=>false,:email=>user.email,:first_name=>user.first_name,:last_name=>user.last_name)
        @project_user.make_invite_code
        UserMailer.deliver_invitation(@project_user,current_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
      end
    end unless user_ids.nil?
  end  
	
	def new_member_invitation
		
		@project_user =ProjectUser.find(:last, :conditions=>['((email=? OR user_id=?) AND invitation_code=? AND temp_invite_status=?)', current_user.email, current_user.id, session[:invite_code],true])
		if @project_user
				@project_user.delete_invite_code
				@project_user.update_attributes(:user_id=>current_user.id, :status=>true, :temp_invite_status=>false)
				@site_url="https://#{@project_user.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
				create_todo_comment_count_show_details(@project_user)
				redirect_to @site_url + project_dashboard_index_path(@project_user.project.url,@project_user.project)
		end				
	end
	
	def  create_todo_comment_count_show_details(project_user)
		project = Project.find_by_id(project_user.project_id)
		task_list = Task.find_all_by_project_id_and_is_completed(project.id,false) if project
		todos = Todo.find(:all,:conditions => ["todos.is_completed =? and todos.task_id IN (?)",false,task_list.map(&:id)]) if !task_list.nil? and !task_list.empty?
		if !todos.nil? and !todos.empty?
			for todo in todos
				comments = todo.comments
				for comment_de in comments
					TodoCommentsDisplay.create(:todo_id => todo.id,:user_id=> current_user.id,:comment_id => comment_de.id,:is_viewed => false )
				end
			end	
		end				
	end	
	
	def check_current_user_exist
		if params[:source]
			render :action => 'index'
		elsif current_user			
			redirect_to "http://#{APP_CONFIG[:site][:name]}/global" and return
		end		
	end	

	def download_file(attachment)
		if RAILS_ENV=="development"  
				send_file "#{RAILS_ROOT}/public"+attachment.public_filename
		else
				s3_connect
				s3_file=S3Object.find(attachment.public_filename.split("/#{S3_CONFIG[:bucket_name]}/")[1],"#{S3_CONFIG[:bucket_name]}")
				send_data(s3_file.value,:url_based_filename=>true,:filename=>attachment.filename,:type=>attachment.content_type)			
		end			
	end		
		
	def find_current_zone_date(zone=nil)
		time= (zone.nil?) ? find_time_zone.split('(GMT') : zone.split('(GMT')
		time=time.to_s
		if time.include?('GMT ')
			time=time.split('GMT ')
			time=time[1]
		end
		time=time.split(':')
		current_date=Time.now.gmtime
		current_date=current_date+(time[0].to_f*60*60 + time[1].to_f*60)
		current_date
		end		

	def find_current_zone_difference(zone)	  
		if zone
				time=zone.split('(GMT')
				time=time.to_s
				if time.include?('GMT ')
					time=time.split('GMT ')
					time=time[1]
				end
				time=time.split(':')
				seconds=time[0].to_f*60*60 + time[1].to_f*60
	
		else
				seconds =0
    end		
		
		
	end		
	
	def find_time_zone
		if current_user 			
			time_zone=current_user.time_zone.split(')')[0]			
	 	end
	 end
	 
	def post_content_type_file_size_validation
		
		(0..10).each{|x| 
		
		if params[:attachment]['file_'+x.to_s] && params[:attachment]['file_'+x.to_s] != ""
			p = Hash["image"=>{"uploaded_data"=>""}]
			p["image"]["uploaded_data"] = params[:attachment]["file_"+x.to_s]
			attach = Attachment.new(p["image"])
			if attach.valid?
				 @size << File.size(attach.temp_path) 
				 
			else
        a=attach.filename.split('.')
        @file_type=a[1]
				@is_valid_file=false
				break
			end
			x += 1
		end
		 }
		 
   end
	 
	 def post_content_type_for_file_tab
		 if params[:file1] && params[:file1] != ""
			p = Hash["image"=>{"uploaded_data"=>""}]
			p["image"]["uploaded_data"] = params[:file1]
			attach = Attachment.new(p["image"])
			if attach.valid?
				 @size << File.size(attach.temp_path) 
			else
        a=attach.filename.split('.')
        @file_type=a[1]
				@is_valid_file=false
				break
			end
			end
	 end
	 
   def get_owner_projects
	 @project_owner=ProjectUser.find_by_project_id_and_is_owner(@project.id, true)
	 
			@user=User.find_by_id(@project_owner.user_id)
			@all_project_users=ProjectUser.find(:all, :conditions=>['user_id=? AND is_owner=?', @user.id, true])
			@all_projects=[]
			@all_project_users.each do |proj_user|
				@all_projects<<Project.find(proj_user.project_id)
			end
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			if !@plan_limits || @plan_limits.nil?
				@plan_limits=PlanLimits.new(:user_id=>@user.id, :max_storage_in_MB=>10, :max_bandwidth_in_MB=>50)
				@plan_limits.save
			end
			@all_projects=@all_projects.flatten
		end
		
		def get_owner_projects_mytask
	 @project_owner=ProjectUser.find_by_user_id_and_is_owner(current_user.id, true)
	 
			@user=User.find_by_id(@project_owner.user_id)
			@all_project_users=ProjectUser.find(:all, :conditions=>['user_id=? AND is_owner=?', @user.id, true])
			@all_projects=[]
			@all_project_users.each do |proj_user|
				@all_projects<<Project.find(proj_user.project_id)
			end
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			if !@plan_limits || @plan_limits.nil?
				@plan_limits=PlanLimits.new(:user_id=>@user.id, :max_storage_in_MB=>10, :max_bandwidth_in_MB=>50)
				@plan_limits.save
			end
			@all_projects=@all_projects.flatten
		end
		
  	def get_storage_stats
		#@project_owner=ProjectUser.find_by_project_id_and_is_owner(@project.id, true)
		@plan_limits=PlanLimits.find_by_user_id(current_user.id)
		@billing_information=BillingInformation.find_by_user_id(current_user.id)
		if @billing_information && !@billing_information.nil? && @billing_information.plan_id && !@billing_information.plan_id.nil?
			@plan=Plan.find(@billing_information.plan_id)	
		else
		@plan=Plan.find_by_name("Trial")
		end
		if @plan_limits
		max_storage=@plan_limits.max_storage_in_MB
		max_bandwidth=@plan_limits.max_bandwidth_in_MB
		used_storage=@plan_limits.storage_used
		if !@plan_limits.download_bandwidth_in_MB.nil?
		download_bandwidth=@plan_limits.download_bandwidth_in_MB 
		else
			download_bandwidth=0
		end
		used_bandwidth=@plan_limits.bandwidth_used.to_i#+download_bandwidth.to_i
		if @plan && @plan.name!="Trial"
			@used_storage_in_GB=used_storage.to_f / 1024
			@used_bandwidth_in_GB=used_bandwidth.to_f / 1024
			@format="GB"
		else
			@used_storage_in_GB=used_storage.to_f
			@used_bandwidth_in_GB=used_bandwidth.to_f
			@format="MB"
		end
		@per_storage=(used_storage.to_f/max_storage.to_f)*100
		@per_bandwidth=(used_bandwidth.to_f/max_bandwidth.to_f)*100
		if (@per_storage >=90 || @per_bandwidth>=90)
			@plan_limits.update_attributes(:is_90exceed=>true)
		elsif (@per_storage >=100 || @per_bandwidth>=100)
			@plan_limits.update_attributes(:is_100exceed=>true)
		end
		return @per_storage, @per_bandwidth, @used_storage_in_GB, @used_bandwidth_in_GB, @format, @plan_limits
		
		end
	end
	
  def find_current_post_storage(total_byte)
		total_kb = total_byte/1024 if !total_byte.nil?
		@total_mb = total_kb.to_f/1024 if !total_kb.nil?
		return "%0.2f"% @total_mb.to_f
	end
  
  def s3_connect
    Base.establish_connection!(:access_key_id => S3_CONFIG[:access_key_id],:secret_access_key => S3_CONFIG[:secret_access_key])
  end
  def room_storage_space(all_projects)
			size = []
			
			all_projects.each do |proj|
				proj.posts.each do |p|
					s=""
					s += p.title  if p.title  && !p.title .empty?
					s += p.content  if p.content  && !p.content .empty?
					char_len= s.to_s.length 
					size << char_len
					atts = p.attachments
					atts.each do |att|
						size << att.size.to_f if att.size
					end	
					p.comments.each do |c|
						x=""
						x += c.comment if c.comment && !c.comment.empty?
						x_len= x.to_s.length 
						size << x_len
						c.attachments.each do |attach|
							size << attach.size.to_f if attach.size
  					end	
					end
				end
				proj.tasks.each do |t|
					todos=t.todos
					todos.each do |tdo|
						tdo.comments.each do |ct|
							comm=""
							comm += ct.comment if ct.comment && !ct.comment.empty?
							comm_len= comm.to_s.length 
							size << comm_len
							ct.attachments.each do |attach_comm|
								size << attach_comm.size.to_f if attach_comm.size
							end	
						end
					end
				end
				all_files=Attachment.find(:all,:conditions => ["project_id=?",proj.id])	
				all_files.each do |f|
					size << f.size.to_f if f.size
				end
				all_chat=Chat.find(:all, :conditions=>["project_id=?", proj.id])
				all_chat.each do |ch|
					chat=""
					chat += ch.message if ch.message && !ch.message.empty?
					chat_len=chat.to_s.length
					size << chat_len
					ch.attachments.each do |attach_chat|
						size << attach_chat.size.to_f if attach_chat.size
					end
				end
			end
			total_byte = size.sum
			total_kb = total_byte/1024 if !total_byte.nil?
		  total_mb = total_kb/1024 if !total_kb.nil?
		  return total_mb.to_f
		end
			def find_current_post_storage(total_byte)
			total_mb=0
			total_kb=0
			total_kb = total_byte/1024 if total_byte && !total_byte.nil? 
			total_mb = total_kb.to_f/1024 if !total_kb.nil?
			return total_mb.to_f
		end
		
  def update_plan_limits
		@plan_limits=PlanLimits.find_by_user_id(current_user.id)
		@plan=Plan.find(@billing_info.plan_id)
		storage=@plan.storage
		bandwidth=@plan.transfer
		if storage.include?('GB')
			storage=storage.split('GB')
			storage=storage[0].to_i
			storage=storage*1024
		else
			storage=storage.split('MB')
			storage=storage[0].to_i
		end
		if bandwidth.include?('GB')
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
			bandwidth=bandwidth*1024
		else
			bandwidth=bandwidth.split('MB')
			bandwidth=bandwidth[0].to_i
		end
		if !@plan_limits || @plan_limits.nil?
			@plan_limits=PlanLimits.new(:user_id=>current_user.id, :max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
			@plan_limits.save
		else
			@plan_limits.update_attributes(:max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		end
	end
	
  def update_beta_limits(user)
    @plan_limits=user.plan_limits
    if @plan_limits
      @plan_limits.update_attributes(:max_storage_in_MB=>nil,:max_bandwidth_in_MB=>nil)
    else
      PlanLimits.create(:max_storage_in_MB=>nil,:max_bandwidth_in_MB=>nil,:user_id=>user.id)
    end
  end
  
	def download_bandwidth_calculation
		total_kb = @attachment_size / 1024.00
		total_mb = total_kb / 1024.00 
		total_mb = "%0.2f"% total_mb
		get_owner_projects
		if @plan_limits.download_bandwidth_in_MB.nil?
			@bandwidth_in_MB=0
		else
			@bandwidth_in_MB=@plan_limits.download_bandwidth_in_MB
			
		end
		download_bandwidth_in_MB=@bandwidth_in_MB + total_mb.to_f 
		@total_bandwidth_in_MB=@bandwidth_in_MB+@plan_limits.bandwidth_used
		if !@plan_limits.max_bandwidth_in_MB.nil?
			if @total_bandwidth_in_MB <=  @plan_limits.max_bandwidth_in_MB
				@plan_limits.update_attributes(:download_bandwidth_in_MB=>download_bandwidth_in_MB)
				@month_limits=MonthLimit.find_by_month_and_year(Time.now.month, Time.now.year)
				if @month_limits
					existing_bandwidth=@month_limits.bandwidth  + total_mb.to_f
					@month_limits.update_attributes(:bandwidth=>existing_bandwidth)
				end
				@status=true
			else
				@status=false
			end
		else
			@status=true
		end
		
		project_owner=ProjectUser.find_by_project_id_and_is_owner(@project.id, true) if @project
		@user=User.find(project_owner.user_id)
		@bill_info = BillingInformation.find_by_user_id(project_owner.user_id) if project_owner
		if @bill_info && !@bill_info.nil?
			@plan=Plan.find(@bill_info.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
		if @plan && @plan.name!="Beta" && @plan.name !="Genius"
			@next_plan=Plan.find(@plan.id-1)
		end
		if !@next_plan
			@next_plan=Plan.find(:first)
		end
		if !@bill_info.nil? and !@bill_info.plan.nil? and @bill_info.plan.name=="Beta"
			@status = true
		end	

		if @status==false
			UserMailer.deliver_storage_bandwidth_exceed(@user, @plan, @next_plan)
		end
	end
	
	def check_bandwidth_usage
		get_owner_projects
		if @plan_limits.download_bandwidth_in_MB.nil? || @plan_limits.bandwidth_used.nil?
			@bandwidth_in_MB=0
		else
			@bandwidth_in_MB=@plan_limits.download_bandwidth_in_MB + @plan_limits.bandwidth_used
		end
		download_bandwidth_in_MB=@bandwidth_in_MB 
		if !@plan_limits.max_bandwidth_in_MB.nil?
			if download_bandwidth_in_MB <=  @plan_limits.max_bandwidth_in_MB
				@status=true
			else
				@status=false
			end
		else
			@status=true
		end
		
		project_owner=ProjectUser.find_by_project_id_and_is_owner(@project.id, true) if @project
		@user=User.find(project_owner.user_id)
		@bill_info = BillingInformation.find_by_user_id(project_owner.user_id) if project_owner
		if @bill_info && !@bill_info.nil?
			@plan=Plan.find(@bill_info.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
		if @plan && @plan.name!="Beta" && @plan.name !="Genius"
			@next_plan=Plan.find(@plan.id-1) if @plan.id!=1
		end
		if !@next_plan
			@next_plan=Plan.find(:first)
		end
		if !@bill_info.nil? and !@bill_info.plan.nil? and @bill_info.plan.name=="Beta"
			@status = true
		end	

		if current_user.id.to_i==@user.id.to_i
			@is_proj_owner=true
		else
			@is_proj_owner=false
		end

	end
	def check_bandwidth_usage_mytask
get_owner_projects_mytask
		if @plan_limits.download_bandwidth_in_MB.nil? || @plan_limits.bandwidth_used.nil?
			@bandwidth_in_MB=0
		else
			@bandwidth_in_MB=@plan_limits.download_bandwidth_in_MB + @plan_limits.bandwidth_used
		end
		download_bandwidth_in_MB=@bandwidth_in_MB 
		if !@plan_limits.max_bandwidth_in_MB.nil?
			if download_bandwidth_in_MB <=  @plan_limits.max_bandwidth_in_MB
				@status=true
			else
				@status=false
			end
		else
			@status=true
		end
		
		project_owner=ProjectUser.find_by_user_id_and_is_owner(current_user.id, true) 
		@user=User.find(project_owner.user_id)
		@bill_info = BillingInformation.find_by_user_id(project_owner.user_id) if project_owner
		if @bill_info && !@bill_info.nil?
			@plan=Plan.find(@bill_info.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
		if @plan && @plan.name!="Beta" && @plan.name !="Genius"
			@next_plan=Plan.find(@plan.id-1) if @plan.id!=1
		end
		if !@next_plan
			@next_plan=Plan.find(:first)
		end
		if !@bill_info.nil? and !@bill_info.plan.nil? and @bill_info.plan.name=="Beta"
			@status = true
		end	

		if current_user.id.to_i==@user.id.to_i
			@is_proj_owner=true
		else
			@is_proj_owner=false
		end

	end


	def display_user_name(user)
		if user
			"#{user.first_name.capitalize} #{user.last_name.first.capitalize}."
		end
	end
  
  def strip_tags(html)     
    return html if html.blank?
    if html.index("<")
      text = ""
      tokenizer = HTML::Tokenizer.new(html)
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        text << node.to_s if node.class == HTML::Text  
      end
      text.gsub(/<!--(.*?)-->[\n]?/m, "") 
    else
      html
    end 
  end
		
  def time_in_files(time)
    current_user.user_time(time).strftime("%I:%M%P on %A, %B %e, %Y")
  end
  
  def add_comments_in_files(model)
    comments=model.comments
    contents=""
    comments.each do |com|
      contents<<  "\n\n==Comment by #{com.user.full_name} at #{time_in_files(com.created_at)}==\n"
      contents<<  "\n\nStatus: #{com.status}\n\n" if com.status
      contents<<  "Comment: #{strip_tags(com.comment.gsub(/&nbsp;/,''))}\n"
      unless com.attachments.empty?
        contents<< "File(s):"
        com.attachments.each do |attachment|
          contents<< "#{attachment.filename} (http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{attachment.filename})\n\t\t\t\t"
        end
      end 
    end unless comments.empty?  
    contents
  end
  
  def add_attachments_file(model)
    contents=""
    unless model.attachments.empty?
      contents= "File(s):"
      model.attachments.each do |attachment|
        contents<< "#{attachment.filename} (#{attachment.public_filename})\n\t\t\t\t"
      end
    end 
    contents
  end
  
  def file_headers(post)
    contents= "Title: #{post.title}\n"
    contents<<"Posted by: #{post.user.full_name}\n"
    contents<<"Time: #{time_in_files(post.created_at)}\n"
  end
  
  def file_time
    current_user.user_time(Time.now).strftime("%m%d%y-%H%M").strip
  end
  
	def pass_icon_filename(content_type)
		type = content_type.split("/").last
		default_content_types = APP_CONFIG[:content][:type].split(',') #content types are specified in settings.yml
		default_content_types.each do |default_content_type|
			if default_content_type == type
				if File.exists?("#{RAILS_ROOT}/public/images/doctype_icons/document-#{type}.png")
					return "document-#{type}.png"
				else
					return "document.png"
				end		
			end
		end
		return "document.png"		
	end	
	
	#~ def admin_login_required
    #~ if session[:user_name].blank?
	  	#~ redirect_to '/adminpanel'
		#~ end
	#~ end
	
	def modified_captialize_call(s)
		s.first.upcase+s[1..s.length] if !s.nil?
	end
	
		def delete_user(user)
		projectusers=user.project_users.find(:all)#, :conditions => ["is_owner = ?", true])
		projectusers.each do |projectuser|
		if projectuser.is_owner == true	
			project=Project.find_by_id(projectuser.project_id)
			project.destroy
		end
		projectuser.destroy
	end

		user.update_attribute(:email,nil)
		user.update_attribute(:site_address,nil)
		user.update_attribute(:status,nil)
	end
	
	
	def user_status(status)
		if status==true
			"Active"
		elsif status == false
			"Suspend"
			else
				"Delete"
		end
		
	end



def auto_link_urls(text, html_options = {}, options = {})
	  
	auto_link_re		=	%r{ (?: ([\w+.:-]+:)// | www\. ) [^\s<]+ }x #AUTO_LINK_RE
	auto_link_cre		=	[/<[^>]+$/, /^[^>]*>/, //i, /<\/a>/i]   #AUTO_LINK_CRE
	auto_email_re		=	/[\w.!#\$%+-]+@[\w-]+(?:\.[\w-]+)+/   #AUTO_EMAIL_RE
	brackets		=	{ ']' => '[', ')' => '(', '}' => '{' }	 #BRACKETS
		 
  link_attributes = html_options.stringify_keys
  text.gsub(auto_link_re) do
    scheme, href = $1, $&
    punctuation = []
		#~ puts "$1 => #{$1}"
		#~ puts "$& => #{$&}"
		#~ puts "$` => #{$`}"
		#~ puts "$' => #{$'}"


    if (auto_linked?($`, $'))
			#~ puts "111"
      # do not change string; URL is already linked
      href
    else
			#~ puts "222"
      # don't include trailing punctuation character as part of the URL
      while href.sub!(/[^\w\/-]$/, '')
        punctuation.push $&
        if opening = brackets[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
          href << punctuation.pop
          break
        end
      end

      link_text = block_given?? yield(href) : href
      href = 'http://' + href unless scheme

      unless options[:sanitize] == false
        link_text = Sanitize.clean(link_text)
        href      =  Sanitize.clean(href)
      end
      content_tag(:a, link_text, link_attributes.merge('href' => href), !!options[:sanitize]) + punctuation.reverse.join('')
    end
  end
end

def auto_linked?(left, right)
	
	
auto_link_re	=	%r{ (?: ([\w+.:-]+:)// | www\. ) [^\s<]+ }x
auto_link_cre	=	[/<[^>]+$/, /^[^>]*>/, //i, /<\/a>/i]
auto_email_re	=	/[\w.!#\$%+-]+@[\w-]+(?:\.[\w-]+)+/
brackets	=	{ ']' => '[', ')' => '(', '}' => '{' }

#~ puts left.inspect
#~ puts right.inspect
#~ puts $'
#~ puts "*************************"
#~ puts left =~ auto_link_cre[0] 
#~ puts right =~ auto_link_cre[1]
#~ puts left.rindex(auto_link_cre[2])
#~ puts $' !~ auto_link_cre[3]
#~ puts "***************************"
#~ puts  ((left =~ auto_link_cre[0] and right =~ auto_link_cre[1]) or (left.rindex(auto_link_cre[2]) and $' =~ auto_link_cre[3]))

 return  ((left =~ auto_link_cre[0] and right =~ auto_link_cre[1]) or (left.rindex(auto_link_cre[2]) and $' =~ auto_link_cre[3]))
 end
	
	
	  def update_plan_limits_admin(user)
		@plan_limits=PlanLimits.find_by_user_id(user.id)
		#@plan=Plan.find(@billing_info.plan_id)
		storage=@plan.storage
		bandwidth=@plan.transfer
		if storage.include?('GB')
			storage=storage.split('GB')
			storage=storage[0].to_i
			storage=storage*1024
		else
			storage=storage.split('GB')
			storage=storage[0].to_i
		end
		if bandwidth.include?('GB')
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
			bandwidth=bandwidth*1024
		else
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
		end
		if @plan_limits && !@plan_limits.nil?
			@plan_limits.update_attributes(:max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		else
			@plan_limits=PlanLimits.create(:user_id=>user.id, :max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		end
	end
	
  def time_zone_select
    @time_zone=["(GMT-11:00) Midway","(GMT-10:00) Hawaii Standard Time","(GMT-09:30) Marquesas","(GMT-09:00) Alaska Standard Time","(GMT-09:00) Alaska Daylight Time","(GMT-08:00) Pacific Standard Time","(GMT-07:00) Pacific Daylight Time","(GMT-07:00) Mountain Standard Time","(GMT-06:00) Mountain Daylight Time","(GMT-06:00) Belize","(GMT-06:00) Costa Rica","(GMT-06:00) Central Standard Time","(GMT-05:00) Central Daylight Time","(GMT-05:00) Eastern Standard Time","(GMT-04:00) Eastern Daylight Time","(GMT-04:00) Aruba","(GMT-04:00) Atlantic Time - Halifax","(GMT-04:00) La Paz","(GMT-04:00) Bermuda"," (GMT-03:30) Newfoundland Time - St. Johns","(GMT-03:00) Buenos Aires"," (GMT-03:00) Sao Paulo"," (GMT-02:00) South Georgia"," (GMT-01:00) Azores","(GMT+00:00) Reykjavik"," (GMT+00:00) Dublin"," (GMT+00:00) Lisbon","(GMT+00:00) London","(GMT+01:00) Amsterdam" ,"(GMT+01:00) Andorra" ,"(GMT+01:00) Central European Time - Belgrade" ,"(GMT+01:00) Berlin" ,"(GMT+01:00) Brussels" ,"(GMT+01:00) Budapest" ,"(GMT+01:00) Copenhagen" ,"(GMT+01:00) Luxembourg" ,"(GMT+01:00) Madrid" ,"(GMT+01:00) Monaco","(GMT+01:00) Oslo","(GMT+01:00) Paris" ,"(GMT+01:00) Central European Time - Prague" ,"(GMT+01:00) Rome" ,"(GMT+01:00) Stockholm" ,"(GMT+01:00) Vienna","(GMT+01:00) Warsaw","(GMT+01:00) Zurich" ,"(GMT+02:00) Cairo" ,"(GMT+02:00) Johannesburg","(GMT+02:00) Jerusalem","(GMT+02:00) Athens",
"(GMT+02:00) Helsinki","(GMT+02:00) Istanbul","(GMT+02:00) Kiev","(GMT+03:00) Nairobi","(GMT+03:00) Baghdad" ,"(GMT+03:00) Kuwait","(GMT+03:00) Qatar" ,"(GMT+03:00) Riyadh","(GMT+03:00) Moscow+00","(GMT+03:30) Tehran","(GMT+04:00) Dubai","(GMT+04:30) Kabul","(GMT+05:00) Maldives " ,"(GMT+05:30) India Standard Time " ,"(GMT+05:45) Katmandu" ,
"(GMT+06:00) Moscow+03 - Omsk, Novosibirsk ","(GMT+06:30) Rangoon","(GMT+07:00) Bangkok","(GMT+07:00) Jakarta" ,"(GMT+08:00) Hong Kong " ,"(GMT+08:00) Manila ","(GMT+08:00) China Time - Beijing" ,"(GMT+08:00) Singapore " ,"(GMT+08:00) Taipei","(GMT+08:00) Western Time - Perth","(GMT+09:00) Seoul","(GMT+09:00) Tokyo","(GMT+09:30) Central Time - Adelaide" ,"(GMT+10:00) Eastern Time - Brisbane","(GMT+10:00) Eastern Time - Melbourne, Sydney","(GMT+11:00) Noumea " ,"(GMT+11:30) Norfolk   ","(GMT+12:00) Auckland","(GMT+12:00) Fiji ","(GMT+13:00) Enderbury" ]		
	end	
  
  def upload_profile_image(image)
    unless image.nil?
      @attach=Attachment.new(:uploaded_data=>image) 
      @attach.attachable = current_user
      img=Attachment.find(:first,:conditions=>['attachable_id = ? AND project_id is NULL',current_user.id]) 
      img.destroy if img
      @attach.save
    end
  end
  
	protected
	def authenticate
		authenticate_or_request_with_http_basic("") do |username, password|
			username == "jesse" && password == "railsfactory"
		end
	end
	
	
	
	
	
end
