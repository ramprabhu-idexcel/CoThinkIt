class Projects::Posts::CommentsController < ApplicationController
  include Projects::Posts::CommentsHelper
	before_filter :login_required
	before_filter :current_project,:current_post, :except=>['delete_comment_attachment']
	#before_filter :ensure_domain
  before_filter :s3_connect ,:only => ['create']
	layout 'base'
	
	def create
		#~ return unless request.post?
		#~ @post = Post.find_by_id(params[:post_id])		
		#~ @comment = Comment.new(params[:comment])
		#~ @comment.user_id = current_user.id
		#~ @comment.status_flag = @comment.status_flag.nil? ? 0 : 1
		#~ @post.comments << @comment		
		#~ #@post.events << 
		#~ process_file_uploads(@comment)		
		#~ redirect_to project_post_path(@project, params[:post_id])
		get_owner_projects
		@post = Post.find_by_id(params[:post_id])
		@comment = Comment.new(params[:comment])
		@comment.commentable = @post
		@comment.user_id = current_user.id
		@comment.project_id=@project.id
		@comment.status_flag = @comment.status_flag.nil? ?  0 : 1	
		@comment.email_notify = true
		#@comment.comment = params[:comment_comment_value]
		@comment.comment = auto_link_urls(@comment.comment)
		@size=[]
		@is_valid_file=true
	  post_content_type_file_size_validation if params[:attachment]
		if @is_valid_file		&& @is_valid_file==true	
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			total_current_post_size=find_current_post_storage(@size.sum)
			total_storage=@plan_limits.max_storage_in_MB
			used_storage = @plan_limits.storage_used.to_f
			used_storage=used_storage+total_current_post_size
			total_bandwidth_in_MB=@plan_limits.max_bandwidth_in_MB 
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
				comment_history_create_for_post  if  @comment.status_flag == true				
				responds_to_parent do
					render :update do |page|			
						if @comment.save
							@post.update_attributes(:updated_at => @comment.created_at)
								store_post_comments_details_to_the_user(@comment)
							process_file_uploads(@comment)
							#send_email_notify_to_post_comment_creation
							@comments = @post.comments	
							@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
							@post_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 						
							#  @task_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 					
							page.replace "file_upload",:partial => "projects/tasks/todos/remove_upload_files"					
							page.replace_html  "comments_list" ,:partial => "projects/posts/list_comments"
							#	page.replace_html  "task_files" ,:partial => "task_files"
							page.call "remove_content_date"					
							#page.visual_effect(:highlight,"comment_#{@comment.id}", :duration => 2.5,:startcolor=>"#FFFF66")					
							page.hide "comment_#{@comment.id}"
							page.visual_effect :appear, "comment_#{@comment.id}", :duration => 0.5,:startcolor=>"#FFFF66"
							page.show "comments_list"
							page.replace_html  "post_files" ,:partial => "/projects/posts/post_files"				
						else
							#~ for each_error in @comment.errors.entries
							#~ page.replace_html 'comment_error',each_error[1] if each_error[0] == "comment"
							#~ end
							page.alert "#{@comment.errors.entries.first[1]}"							
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
	
	def destroy		
		comment_id = params[:id]
		@comment = Comment.find_by_id(params[:id])
		@comment.destroy if !@comment.nil?
		@comments = @post.comments
		@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
		@post_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 
		render :update do |page|				
		#	page.replace_html "comments_list",:partial => "projects/posts/list_comments"
				if @comments.count == 0
					page.visual_effect :fade, "comments_list", :duration => 1
				else	
					page.visual_effect :fade, "comment_#{comment_id}", :duration => 1
					page.replace_html  "lastest_comment" ,:partial=>'/projects/tasks/todos/lastest_comment',:locals=>{:comments => @comments}				
				end	
        page.replace_html  "post_files" ,:partial => "/projects/posts/post_files"				
		end	
	end
	
	def update_status_path		
		if request.xhr?
			@comment = Comment.find_by_id(params[:comment_id])
			if @comment and @comment.status != params[:status]
					@comment.status = params[:status]				
					@comment.save				
					#~ add_in_file(@comment)

					history_update_for_comment(@comment, "set status to #{params[:status]}")	
			end			
			render :update do |page|
				page.replace_html "set_status_#{@comment.id}", :partial => "status_update_comment" , :locals => {:comment => @comment }		
				page.replace_html "history_#{@comment.id}", :partial => "history_comment" , :locals => {:comment => @comment }		
				page.call 'check_visible_for_comment_history', @comment.id
			end			
		end
	end	
	
	def history_display
		if request.xhr?
			render :update do |page|
				@comment = Comment.find_by_id(params[:comment_id])
				page.replace_html "history_link_#{@comment.id}", :partial => "history_link_comment" ,  :locals => {:comment => @comment,:parent => params[:parent] }		
				page.replace_html "history_#{@comment.id}", :partial => "history_comment" , :locals => {:comment => @comment,:parent => params[:parent] }		
				if params[:show_history]
					page.show "history_display_#{@comment.id}"
				else
					page.hide "history_display_#{@comment.id}"
				end				
			end			
		end		
	end
	
	def comment_history_create_for_post	
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = "added a comment"
			@comment.history_posts << history	
      @comment.status = "pending"			
		end
		
			def comment_history_update_for_post	
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = "edited a comment"
			@comment.history_posts << history	
    	end

    def current_post
			@post = Post.find_by_id(params[:post_id])
		end	
		
		def history_update_for_comment(resource,message)
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = message
			history.resource = resource
			history.save	
		end			
		
			def edit_comment
				check_bandwidth_usage
				@comment=Comment.find_by_id(params[:id])
			end
	
	def update_comment
    check_bandwidth_usage
    get_owner_projects
    @post=Post.find_by_id(params[:post_id])
    @comment=Comment.find_by_id(params[:id])
  
    status_flag=params[:comment][:status_flag] ? true : false
		status=status_flag==true ? @comment.status : nil
		if status_flag==true  && status.nil?
			status="pending"
		end
		  comment_history_update_for_post  if  params[:comment][:status_flag]
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
        @comment.update_attributes(:comment=>params[:comment][:comment],:status_flag=>status_flag,:email_notify=>true, :status=>status)
        process_file_uploads(@comment)
        responds_to_parent do
          render :update do |page|
            if !@comment.errors.entries.blank?
              page.alert "#{@comment.errors.entries.first[1]}"							
            else
              page.redirect_to project_post_path(@project.url, @project, @post)
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
   
	 	def delete_comment_attachment
		
		attach=Attachment.find_by_id(params[:id])
		@comment=Comment.find_by_id(attach.attachable_id)
		attach.destroy
		render :update do |page|
			page.replace_html 'existing_files', :partial=>"comment_existing_files"
		end
	end
	 
   #~ def add_in_file(comment)
    #~ base_path="#{RAILS_ROOT}/public/files/" 
    #~ Dir.mkdir(base_path) unless File.directory?(base_path)
    #~ file_name="Post#{comment.post_id.to_s}.txt"
    #~ file_path=base_path+file_name
    #~ File.open(file_path,"a+") do |line|
      #~ line<<"==Comment by #{comment.posted_by} at #{Time.now}==\n\n\n"
      #~ line<<"#{comment.content}\n"
    #~ end
  #~ end
 end
