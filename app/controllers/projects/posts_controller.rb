class Projects::PostsController < ApplicationController
	before_filter :login_required
	include ApplicationHelper
	include Projects::PostsHelper
	layout 'base'
	before_filter :current_project, :except=>['status_update','delete_post_attachment']
	before_filter :online_users, :only=>['index','show','new']
	

	before_filter :check_guest_user_permission ,:only => ['new','create']
	before_filter :s3_connect ,:only => ['create','download_post','post_update']
	before_filter :check_site_address, :only=>['show','new','index']

	def index
		check_bandwidth_usage
		if params[:status]
			@posts = @project.posts.find(:all,:conditions=>['status = ?', params[:status]],:order =>"updated_at desc")
		else
			@posts = @project.posts.find(:all,:order =>"updated_at desc")
		end
		
	end

	def new
		@post = Post.new
		list_email_notification_for_post
	end
	
	def create
		get_owner_projects
		@post = Post.new(params[:post])
		list_email_notification_for_post
		@post.user_id = current_user.id
		@post.project_id = @project.id
		@post.email_notify = true
		#@post.content = params[:post_content_value]
		@post.content = auto_link_urls(@post.content)
		@size=[]
		@is_valid_file=true
		post_content_type_file_size_validation if params[:attachment]
		if @is_valid_file		&& @is_valid_file==true	
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			total_current_post_size=find_current_post_storage(@size.sum)
			total_storage=@plan_limits.max_storage_in_MB
			used_storage = @plan_limits.storage_used.to_f
			used_storage=used_storage+total_current_post_size
			total_bandwidth_in_MB=@plan_limits.max_bandwidth_in_MB #total band width converted into MB
			if @plan_limits.download_bandwidth_in_MB.nil?
				upload_download_bandwidth= used_storage.to_f 
			else
				upload_download_bandwidth= @plan_limits.download_bandwidth_in_MB + used_storage.to_f 
			end
			if @plan_limits
				@plan_limits.update_attributes(:storage_used=>used_storage, :bandwidth_used=>upload_download_bandwidth)
				@month_limits=MonthLimit.find_by_month_and_year(Time.now.month, Time.now.year)
				if @month_limits
					existing_storage=@month_limits.storage + total_current_post_size
					existing_bandwidth=@month_limits.bandwidth  + total_current_post_size
					@month_limits.update_attributes(:storage=>existing_storage, :bandwidth=>existing_bandwidth)
				else
					@month_limits=MonthLimit.create(:month=>Time.now.month, :year=>Time.now.year, :storage=>total_current_post_size, :bandwidth=>total_current_post_size)
				end
			end
			if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB > upload_download_bandwidth.to_f))
				status_flag_update
				
				email_list= params[:email_notice].join(",").split(",").uniq.join(",") if params[:email_notice]
				if email_list
					@post.email_notification=email_list+",#{current_user.id}"
				else
					@post.email_notification=current_user.id
				end
				responds_to_parent do	
					render :update do |page|				
						if @post.save
							store_post_details_to_the_user(@post)
              process_file_uploads(@post)
							#~ if !@post.email_notification.nil? and !@post.email_notification.blank?
								#~ email_nofitications = User.find_all_by_id(@post.email_notification.split(","))
								#~ for email in email_nofitications									
									#~ UserMailer.deliver_new_post_notification(current_user.first_name,email,@post,@project,request.env['HTTP_HOST'],request.env['SERVER_NAME'])  rescue ''
								#~ end
							#~ end
							page.redirect_to project_posts_path
						else
							page.alert "#{@post.errors.entries.first[1]}"			
						end
					end
				end
			else
				responds_to_parent do	
          render :update do |page|	
            page['account-limit-modal'].show
          end
				end
			end
		end
	end
	
	def edit
	end
	
	def update
	end
	
	def show
		check_bandwidth_usage
		@post = @project.posts.find_by_id(params[:id])
		change_post_status_in_show(@post)
		@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', @post.id, "Post", current_user.id, true])
		if @post
			@comments = @post.comments
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@post_files=[]
			@post_files<<Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) if !@comments.empty?		
			@post_files<<Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Post' and attachable_id IN (?)",@project.id,@post.id]) if @post		
			@post_files=@post_files.flatten
			change_post_comment_status_in_show(@comments) if @comments
		else
			redirect_to '/global'
		end			
	end	
	
	def status_update
		if request.xhr?
			render :update do |page|
				@post = Post.find_by_id(params[:post_id])
				if @post and @post.status != params[:status]
						@post.status = params[:status]
						@post.save
						history_update(@post, "set status to #{params[:status]}")
				end
				page.replace_html "set_status", :partial => "status_update" , :locals => {:post => @post}		
				page.replace_html "history", :partial => "history" , :locals => {:post => @post}
				page.call 'check_visible'
			end			
		end
	end
	
	def history
		if request.xhr?
			render :update do |page|
				@post = Post.find_by_id(params[:post_id])
				page.replace_html "history-link", :partial => "history_link" , :locals => {:post => @post}
				page.replace_html "history", :partial => "history" , :locals => {:post => @post}
				if params[:show_history]
					page.show "history_display"
				else
					page.hide "history_display"
				end				
			end			
		end		
	end
	
	def download
		attachment = Attachment.find_by_id(params[:id])
		@attachment_size=attachment.size
		download_bandwidth_calculation
		@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
		download_file(attachment) if attachment		
	end	
	
	def download_post
		@post=Post.find_by_id(params[:id])
		unless @post.nil?
			contents=find_post_contents(@post)
			contents<<add_comments_in_files(@post)
			@attachment_size=contents.size
		end
		download_bandwidth_calculation
		@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
		send_data(contents,:filename=>"Post #{file_time}.txt",:type=>"text/plain")
	end

	def find_post_contents(post)
		contents= file_headers(post)
		contents<<"\n\nStatus: #{post.status}\n\n" if @post.status
		contents<<"Post: #{strip_tags(post.content)}\n"
		contents<< add_attachments_file(post)
	end
	
	def edit_post
		list_email_notification_for_post
		@post=Post.find_by_id(params[:post_id])
	end
	
	def post_update
		get_owner_projects
		@post=Post.find_by_id(params[:id])
		list_email_notification_for_post
		email_notification = params[:email_notice].join(",").split(",").uniq.join(",") if params[:email_notice]
		@size=[]
		@is_valid_file=true
		post_content_type_file_size_validation if params[:attachment]
		if @is_valid_file		&& @is_valid_file==true	
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			total_current_post_size=find_current_post_storage(@size.sum)
			total_storage=@plan_limits.max_storage_in_MB
			used_storage = @plan_limits.storage_used.to_f
			used_storage=used_storage+total_current_post_size
			total_bandwidth_in_MB=@plan_limits.max_bandwidth_in_MB #total band width converted into MB
			if @plan_limits.download_bandwidth_in_MB.nil?
				upload_download_bandwidth= used_storage.to_f 
			else
				upload_download_bandwidth= @plan_limits.download_bandwidth_in_MB + used_storage.to_f 
			end
			if @plan_limits
				@plan_limits.update_attributes(:storage_used=>used_storage, :bandwidth_used=>upload_download_bandwidth)
				@month_limits=MonthLimit.find_by_month_and_year(Time.now.month, Time.now.year)
				if @month_limits
					existing_storage=@month_limits.storage + total_current_post_size
					existing_bandwidth=@month_limits.bandwidth  + total_current_post_size
					@month_limits.update_attributes(:storage=>existing_storage, :bandwidth=>existing_bandwidth)
				else
					@month_limits=MonthLimit.create(:month=>Time.now.month, :year=>Time.now.year, :storage=>total_current_post_size, :bandwidth=>total_current_post_size)
				end
			end
			if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB > upload_download_bandwidth.to_f))
		status_flag_update
		
		@post.update_attributes(:title=>params[:post][:title], :content=>params[:post][:content],:email_notification=>email_notification,:email_notify=>true)
		
		process_file_uploads(@post)
		post_history_update
		responds_to_parent do
			render :update do |page|
				if !@post.errors.entries.blank?
					page.alert "#{@post.errors.entries.first[1]}"		
				else
					page.redirect_to project_posts_path(@project.url, @project)
				end
			end
		end
		else
        responds_to_parent do	
          render :update do |page|	
            page['account-limit-modal'].show
          end
        end
      end
		end
	end
		
	def delete_post_attachment		
		attach=Attachment.find_by_id(params[:id])
		@post=Post.find_by_id(attach.attachable_id)
		attach.destroy
		render :update do |page|
			page.replace_html 'existing_files', :partial=>"delete_existing_files"
		end
	end
	
	def delete_post_comments
		@post=Post.find_by_id(params[:id])
		@comments=@post.comments
		@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
		@comments.each do |comment|
			comment.destroy
		end
		@post.destroy
		render :update do |page|
			page.redirect_to project_posts_path(@project.url, @project)
		end
	end
	
	def subscribe_and_unsubscribe_post
		@notify=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=?', params[:id], "Post", current_user.id])
		@project=Project.find_by_id(params[:project_id])
		@post=Post.find_by_id(params[:id])
		if params[:subscribe]=="false"
			@notify.update_attributes(:is_notify=>false) if @notify
		elsif params[:subscribe]=="true"
			if @notify
				@notify.update_attributes(:is_notify=>true)
			else
				EmailNotification.create(:resource_id=>params[:id], :resource_type=>"Post", :user_id=>current_user.id, :is_notify=>true)
			end
		end
		@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', params[:id], "Post", current_user.id, true])
		#@post.update_attributes(:email_notify=>true)
		#~ @comments=@post.comments
		#~ @comments.each do |comment|
				#~ comment.update_attributes(:email_notify=>true)
		#~ end
		render :update do |page|
			page.replace_html "email_notification", :partial=>"email_notification"
		end
	end
  

	private
	def status_flag_update
		if @post.status_flag.nil? 
			@post.status_flag = false
		else
			@post.status_flag = true
			if @post.status.nil?
				@post.status = "pending"
			end
		end		
	end
	
	def post_history_update
		history = HistoryPost.new
		history.user_id = current_user.id
		history.action = "edited post"
		@post.history_posts << history
	end
	
end
