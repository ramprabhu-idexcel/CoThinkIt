class Projects::TasksController < ApplicationController
	include ApplicationHelper
	include Projects::TasksHelper
		before_filter :login_required
	before_filter :current_project,:except => "completed_task"
	before_filter :online_users, :only=>['index','show']

	before_filter :ensure_domain
	before_filter :check_guest_user_permission ,:only => ['new','create']
		before_filter :check_site_address, :only=>['show','index']
	layout 'base'
	def index
		sidebar_details
    get_task_details	
		
				@my_tasks=[]
				@containment=[]
		if !@tasks.empty?
		@tasks.each do |task|
		
				@my_tasks<<task.id
		@containment<<"tbody_for_task_#{task.id}"
	end
	
	
		@my_tasks=@my_tasks.flatten
		
		end
	end	
	
	def new
		@task = Task.new	
    @users = User.find(:all)	
		@current_date=find_current_zone_date		
		@year = @current_date.year
		@month = @current_date.month
	end

  def create
		@task = Task.new(params[:task])
		@task.user_id = current_user.id
		@task.project_id = @project.id
		@task.is_completed = false		
		max_position = @project.tasks.find(:all,:select => "max(position) as max_position")
		@task.position =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1
    first_task=@project.tasks.empty?


				
		render :update do |page|
			if @task.save
        task_id =  @task.id
        if first_task
          page.redirect_to project_tasks_path(@project.url,@project) 
        else
          page.call "close_control_model"				
          #@tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position asc")
          get_task_details
					@my_tasks=[]
				@containment=[]
		if !@tasks.empty?
		@tasks.each do |task|
		
				@my_tasks<<task.id
		@containment<<"tbody_for_task_#{task.id}"
	end
	
	
		@my_tasks=@my_tasks.flatten
		
		end
          page.replace_html 'task_list',:partial => "tasks_list"		
          page.hide "task-#{task_id}"
          page.visual_effect :appear, "task-#{task_id}", :duration => 1,:startcolor=>"#FFFF66"	
        end
			else
				#~ for each_error in @task.errors.entries
					#~ page.replace_html 'task_title_error',each_error[1] if each_error[0] == "title"
				#~ end	
				 page.alert "#{@task.errors.entries.first[1]}"					
			end	
		end
	end	
	
	def show
		check_bandwidth_usage
		@task = @project.tasks.find_by_id(params[:id])
		if @task
			@comments = @task.comments		
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@task_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) if !@comments.empty?
			change_task_comment_status_in_show(@comments)
		else
			 	redirect_to '/global'
		end	
	end	
	
	def update_status_path
			if request.xhr?
				@task = Task.find_by_id(params[:id]) if !params[:id].nil?
				@comment = Comment.find_by_id(params[:comment_id])
				@comment.status = params[:status]				
				@comment.save				
				history_update_for_comment(@comment, "set status to #{params[:status]}")									
				render :update do |page|
					page.replace_html "set_status_#{@comment.id}", :partial => "/todos/status_update" , :locals => {:comment => @comment,:parent => params[:parent] }		
					page.replace_html "history_#{@comment.id}", :partial => "/todos/history" , :locals => {:comment => @comment,:parent => params[:parent] }		
					page.call 'check_visible_for_comment_history', @comment.id
				end			
			end
		end	
		
	def post_comment
		get_owner_projects
		@task = Task.find_by_id(params[:id])
		@comment = Comment.new(params[:comment])
		@comment.commentable = @task
		@comment.user_id = current_user.id
		@comment.status_flag = @comment.status_flag.nil? ?  0 : 1	
		@comment.project_id=@project.id
		#@comment.comment = params[:comment_comment_value]
		@comment.comment = auto_link_urls(@comment.comment)
		@comment.email_notify=true
		@size=[]
		@is_valid_file=true
		post_content_type_file_size_validation if params[:attachment]
		if @is_valid_file		&& @is_valid_file==true	
			total_current_post_size=find_current_post_storage(@size.sum)
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
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
				comment_history_create  if  @comment.status_flag == true				
				responds_to_parent do
					render :update do |page|			
						if @comment.save
							store_task_comments_details_to_the_user(@comment)
							process_file_uploads(@comment)
							@comments = @task.comments	
							@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
							@task_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 					
							page.replace "file_upload",:partial => "projects/tasks/todos/remove_upload_files"					
							page.replace_html  "comments_list" ,:partial => "list_comments",:locals=>{:parent => 'task'}
							page.replace_html  "task_files" ,:partial => "task_files"
							page.call "remove_content_date_task_todo"					
							#page.visual_effect(:highlight,"comment_#{@comment.id}", :duration => 2.5,:startcolor=>"#FFFF66")					
							page.hide "comment_#{@comment.id}"
							page.visual_effect :appear, "comment_#{@comment.id}", :duration => 0.5,:startcolor=>"#FFFF66"
							page.show "comments_list"
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
	
	def change_reorder_page
		#@tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position asc")
		get_task_details
		render :update do |page|
			if params[:reorder]				
				page.replace_html 'task_list',:partial => "reorder_tasks"
			else
  			page.replace_html 'task_list',:partial => "tasks_list"	
			end
			page.replace 'reorder-tasks',:partial => "reorder_link_display"	
    end		
	end

  def reorder_task
		i= @project.tasks.count
		for task_id in params[:task_list]
			task = Task.find_by_id(task_id)
			task.update_attribute(:position,i) if !task.nil?
			i=i - 1
		end	
		render :text => "success"
	end	
	
	def completed_task
		@project = Project.find_by_id(params[:project_id])	
		@task = Task.find_by_id(params[:id])
		if params[:dashboard].nil?
				if params[:checked] and params[:checked] == "true"
					@task.update_attributes(:is_completed => false) if !@task.nil?
					change_status_of_todos(@task.todos,false)
				else
					@task.update_attributes(:is_completed => true) if !@task.nil?
					change_status_of_todos(@task.todos,true)
				end		
		else
			if @task.is_completed == true
				@task.update_attributes(:is_completed => false) 
				change_status_of_todos(@task.todos,false)				
			else
				@task.update_attributes(:is_completed => true)
				change_status_of_todos(@task.todos,true)
			end	
		end	
		#@tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position asc")
		get_task_details
		render :update do |page|			
		  if params[:checked].nil?
					page.visual_effect :fade, "task-#{@task.id}", :duration => 1
					#page.replace_html "task_list", :partial => "tasks_list"	
					sidebar_function_for_task(page)			
			end	
			if params[:dashboard] 								
         #~ if finding_tasks_list.count > 0				
				   #~ page.visual_effect :fade, "task_#{@task.id}", :duration => 1				
				 #~ else
					 #~ page.visual_effect :fade, "dashboard_tasks_list", :duration => 1	
         #~ end	
				 #~ @todos =finding_todos_list
         #~ if @todos.count > 0
					  #~ page.replace_html 'dashboard_todos_list',:partial => "home/todo_list_in_dashboard"	
         #~ else					 
					  #~ page.visual_effect :fade, "dashboard_todos_list", :duration => 1	
         #~ end   
				 if @task.is_completed == true
					 page.call "completed_think","label_task_#{@task.id}","label_task_#{@task.id}"
					 completed_todo = @task.todos.find(:all,:conditions=>['todos.due_date=? AND todos.is_completed=?', @task.due_date, true])
					for todo in completed_todo
					 page.call "completed_think","label_todo_#{todo.id}","todo_com_#{todo.id}" 
					 end
				 else
					 page.call  "uncompleted_think","label_task_#{@task.id}","label_task_#{@task.id}"
					  completed_todo = @task.todos.find(:all,:conditions=>['todos.due_date=? AND todos.is_completed=?', @task.due_date, false])
					  for todo in completed_todo
					 page.call  "uncompleted_think","label_todo_#{todo.id}","todo_com_#{todo.id}"
					 end
				 end 
			end	
		end				
	end		
	
	def achieved_todo
		@task = Task.find_by_id(params[:id])
		if params[:achieve]
			@todos_com = @task.todos.find_all_by_is_completed(true,:order => "position asc")
    end			
		render :update do |page|
			page.replace "view_completed_#{params[:id]}", :partial => "achieve_link"
			page.replace "view_achieved_todos_#{params[:id]}",:partial => "view_achieved_todos"
		end
	end
	
  def task_filter
    #~ @filters = ["View All","Due Today","Assigned to me","Unassigned"]
    #~ @filters = @filters - [params[:filter_option]]
    
    #~ render :update do |page|
      #~ page.replace "posts-filter",:partial => "filter_list"
    #~ end  
    get_task_details
    render :update do |page|
      page.replace_html "task_list", :partial => "tasks_list"	
    end     
  end
	
	def destroy_comment
			comment_id = 	params[:comment_id]
			delete_comment
			@task = Task.find_by_id(params[:id])
			@comments = @task.comments
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@task_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 				
			render :update do |page|				
			#	page.replace_html "comments_list",:partial => "list_comments",:locals=>{:parent => 'task'}
				page.replace_html  "task_files" ,:partial => "task_files"
				
				if @comments.count == 0
					page.visual_effect :fade, "comments_list", :duration => 1
				else	
					page.visual_effect :fade, "comment_#{comment_id}", :duration => 1
					page.replace_html  "lastest_comment" ,:partial=>'/projects/tasks/todos/lastest_comment',:locals=>{:comments => @comments}				
				end						
			end				
  end	
    
  def download_tasks
    @task=Task.find_by_id(params[:id])
    unless @task.nil?
      contents=find_task_content(@task)
      contents<<add_comments_in_files(@task)
			@attachment_size=contents.size
			download_bandwidth_calculation
			if @status==false
				responds_to_parent do	
					render :update do |page|	
						page.redirect_to :back
						page['account-limit-modal'].show
					end
				end
			else
				send_data(contents,:filename=>"Task #{file_time}.txt",:type=>"text/plain")
			end
		end
  end  
  
  def find_task_content(task)
    contents= file_headers(task)
    contents<<"Due date: #{task.due_date}" if task.due_date
    contents<<"Task: #{strip_tags(task.description)}\n"
    contents<< add_attachments_file(task)
  end
	
	
		def subscribe_and_unsubscribe_post
		@notify=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=?', params[:id], "Task", current_user.id])
		@project=Project.find_by_id(params[:project_id])
		@task=Task.find_by_id(params[:id])
	
		if params[:subscribe]=="false"
			@notify.update_attributes(:is_notify=>false) if @notify
		elsif params[:subscribe]=="true"
			if @notify
				@notify.update_attributes(:is_notify=>true)
			else
				EmailNotification.create(:resource_id=>params[:id], :resource_type=>"Task", :user_id=>current_user.id, :is_notify=>true)
			end
		end
		@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', params[:id], "Task", current_user.id, true])
		
		#~ @comments=@task.comments
		#~ @comments.each do |comment|
				#~ comment.update_attributes(:email_notify=>true)
		#~ end
		
		
		
		render :update do |page|
			page.replace_html "email_notification", :partial=>"task_email_notification"
		end
	end
	
	
	def edit_task_comment
				@comment=Comment.find_by_id(params[:id])
				@task=Task.find_by_id(params[:task_id])
			end
	
	def update_task_comment
		get_owner_projects
		@task=Task.find_by_id(params[:task_id])
		@comment=Comment.find_by_id(params[:id])
		
	
		status_flag=params[:comment][:status_flag] ? true : false
		
		status=status_flag==true ? @comment.status : nil
		if status_flag==true  && status.nil?
			status="pending"
		end
	comment_history_update  if  params[:comment][:status_flag]
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
            page.redirect_to project_task_path(@project.url, @project,@task)
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
   
	 	def delete_task_comment_attachment
		
		attach=Attachment.find_by_id(params[:id])
		@comment=Comment.find_by_id(attach.attachable_id)
		attach.destroy
		render :update do |page|
			page.replace_html 'existing_files', :partial=>"comment_existing_files"
		end
	end
  
	private
	def sidebar_details
		@recent_todos = Todo.find(:all,:conditions => ["todos.task_id = tasks.id and tasks.project_id=? and todos.is_completed=?",@project.id,false],:select => "distinct todos.*",:order => "id desc",:limit => 5,:from => "tasks,todos")
		@current_tasks = Task.find_all_by_project_id_and_is_completed(@project.id,false,:order => "position asc",:limit => 3)
		@completed_tasks = Task.find_all_by_project_id_and_is_completed(@project.id,true,:order => "position asc")
	end	
	
	def change_status_of_todos(todos , status)
		for todo in todos
			 todo.update_attributes(:is_completed => status)
		end	
	end
	
end
