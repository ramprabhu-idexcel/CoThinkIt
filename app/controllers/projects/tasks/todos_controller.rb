class Projects::Tasks::TodosController < ApplicationController
		include ApplicationHelper
		include Projects::Tasks::TodosHelper
		include Projects::TasksHelper
			before_filter :login_required
		before_filter :current_project,:current_task
		before_filter :online_users, :only=>['index','show']
		before_filter :check_site_address, :only=>['show']
		layout 'base'
	
		before_filter :ensure_domain
		before_filter :check_guest_user_permission ,:only => ['new','create','edit','update']
		
		def index
		end

    def new
			@todo = Todo.new			
			assignees_list
			@current_date=find_current_zone_date		
			@year = @current_date.year
			@month = @current_date.month		
			get_task_details
			@containment=[]
			if !@tasks.empty?
				@tasks.each do |task|
					@containment<<"tbody_for_task_#{task.id}"
				end
			end		
			#~ session[:task]=nil
			#~ session[:task_id]=nil
			#~ session[:task]=@task
			#~ session[:task_id]=@task.id
			@task_id=@task
			if request.xhr?
				render :update do |page|
						if !@task.todos.empty?
					 get_todo_details(@task.id)					 					 
					page.replace_html "todos_list_task_#{@task.id}", :partial=>"projects/tasks/list_todo_details",:locals => {:task => @task}	
				end
					page["add_todo_link_for_#{@task.id}"].hide();
					page.replace "create_new_todo_#{@task.id}" ,:partial => "new"
				end	
			end	
		end
 
		def create		
     @todo = Todo.new(params[:todo])
		 @todo.user_id=current_user.id
		 @todo.task_id = @task.id
		 @todo.is_completed = false
		 @todo.email_notify = true
		 store_assignee_details(current_user.id)
		 max_position = @task.todos.find(:all,:select => "max(position) as max_position")		 
		 @todo.position =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1	
			assignees_list
			@current_date=find_current_zone_date		
			@year = @current_date.year
			@month = @current_date.month		
		 render :update do |page|		 
			 if @todo.save				   
				 	 #@todos = @task.todos.find_all_by_is_completed(false)		
	
			
				#~ get_todo_details(@task.id)
			get_task_details
			@containment=[]
			if !@tasks.empty?
			@tasks.each do |task|
			@containment<<"tbody_for_task_#{task.id}"
			end	
			end
			
				  # page[:todo_title_error].innerHTML = ""
          # page[:success_message].innerHTML = "Todo added successfully"
           #page.visual_effect(:highlight,'success_message', :duration => 2.5,:startcolor=>"#E5FDD0")
        #   page.visual_effect :fade,'success_message',:duration => 1									 
					 #page.alert("Todo added successfully")
					 page.call "close_control_model"
					 @task_id=@task
					#~ page.replace_html "todos_list_task_#{@task.id}", :partial => "projects/tasks/list_todo_details",:locals => {:task => @task}	
				 	page.replace_html 'task_list',:partial => "/projects/tasks/tasks_list"	
					page.hide "todo_item_#{@todo.id}"
  	 			page.visual_effect :appear, "todo_item_#{@todo.id}", :duration => 1,:startcolor=>"#FFFF66"	
   		  	 page.replace "create_new_todo_#{@task_id.id}" ,:partial => "new"
				   recent_todos(page)						 
			
#					 send_mail_to_todo_assignee					 
			 else	 
				#~ for each_error in @todo.errors.entries
					#~ page.replace_html 'todo_title_error',each_error[1] if each_error[0] == "title"
				#~ end				
         page.alert "#{@todo.errors.entries.first[1]}"				
			 end	 
		 end	
		end 

		def show

			check_bandwidth_usage
			@todo = @task.todos.find_by_id(params[:id])	
								@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', @todo.id, "Todo", current_user.id, true])
								
			if @todo
					@comments = @todo.comments			
					@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
					@todo_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) if !@comments.empty?
					change_todo_comments_status_in_show(@comments,@todo) if !@comments.empty?
			else
					redirect_to '/global'
			end	
		end
		
		def edit
			
			@todo = Todo.find_by_id(params[:id])
			assignees_list
			display_selected_assignee
			@current_date=find_current_zone_date		
			if @todo.due_date
					@year = @todo.due_date.year
					@month = @todo.due_date.month			
			else
					@year = Date.today.year
					@month = Date.today.month		
			end	
			if request.xhr?
				render :update do |page|
					@c=params[:alt]
					page.replace_html "todo_item_#{@todo.id}" ,:partial => "edit"
				end	
			end	
				
		end

    def update
			
			@todo = Todo.find_by_id(params[:id])
			@todo.attributes = params[:todo]			
			@todo.todo_users.delete_all
			store_assignee_details(current_user.id)
			render :update do |page|
				if @todo.save					
					if @todo.todo_status == "Late" and !@todo.due_date.nil?
						if @todo.due_date >= Date.today
							@todo.update_attributes(:todo_status => "In Progress")
						end	
						
					end	
					#@todos = @task.todos.find_all_by_is_completed(false)				
					#~ get_todo_details(@task.id)
							get_task_details
				#~ @my_tasks=[]
				@containment=[]
		if !@tasks.empty?
		@tasks.each do |task|
		
				#~ @my_tasks<<task.id
		@containment<<"tbody_for_task_#{task.id}"
	end
	
	
		#~ @my_tasks=@my_tasks.flatten
		
		end
		
					page.call "close_control_model"
					#~ page.replace_html "todos_list_task_#{@task.id}", :partial => "projects/tasks/todo_details"
					@c=params[:alt]
					page.hide "todo_item_#{@todo.id}"
					#	page.replace "todo_item_#{@todo.id}", :partial => "projects/tasks/todo_details"
					page.visual_effect :appear, "todo_item_#{@todo.id}", :duration => 1,:startcolor=>"#FFFF66"						
					
					page.visual_effect(:highlight,"todo_item_#{@todo.id}", :duration => 2.5,:startcolor=>"#000000")				
page.replace_html "task_list", :partial => "projects/tasks/tasks_list"					
					recent_todos(page)
				else
					#~ for each_error in @todo.errors.entries
						#~ page.replace_html 'todo_title_error',each_error[1] if each_error[0] == "title"
					#~ end		
          page.alert "#{@todo.errors.entries.first[1]}"							
				end	
			end				
		end	
		
		def post_comment
			get_owner_projects
			@todo = Todo.find_by_id(params[:id])	
			
			@comment = Comment.new(params[:comment])
			@comment.commentable = @todo
			@comment.project_id=@project.id
			@comment.user_id = current_user.id
			@comment.status_flag = @comment.status_flag.nil? ?  0 : 1
			@comment.email_notify = true
			#@comment.comment = params[:comment_comment_value]
			@comment.comment = auto_link_urls(@comment.comment)
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
								process_file_uploads(@comment)
								store_todo_details_to_the_user(@todo,@comment) 
#								send_comment_nofication_mail_to_todo_assignee						
								@comments = @todo.comments		
								@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
								@todo_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) if !@comments.empty?
								page.replace "file_upload",:partial => "remove_upload_files"	
								page.replace_html  "comments_list" ,:partial => "list_comments",:locals=>{:parent => 'todo'}
								page.visual_effect(:highlight,"comment_#{@comment.id}", :duration => 2.5,:startcolor=>"#FFFFFF")
								page.replace_html  "todo_files" ,:partial => "todo_files"
								page.call "remove_content_date_task_todo"
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
					if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
						page['account-limit-modal'].show
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							page['account-limit-modal'].show
						end
					else
						render :update do |page|	
							page['account-limit-modal'].show
						end
					end
				end
			end
		end
	end
			
		
		def completed_todo
				@todo = Todo.find_by_id(params[:id])
				if params[:dashboard].nil?
					if params[:checked] and params[:checked] == "true"
						@todo.update_attributes(:is_completed => false) if !@todo.nil?
					else	
						@todo.update_attributes(:is_completed => true) if !@todo.nil?
					end
				else
					if @todo.is_completed == true
						@todo.update_attributes(:is_completed => false) 	
					else
						@todo.update_attributes(:is_completed => true) 	
					end	
				end	
				#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")
				get_todo_details(@task.id)
				@todos_com = @task.todos.find_all_by_is_completed(true,:order => "position asc")			
			get_task_details
			@containment=[]
			if !@tasks.empty?
				@tasks.each do |task|
					@containment<<"tbody_for_task_#{task.id}"
				end
			end		
				
				render :update do |page|					
					if params[:no_update].nil?						
						if @todos_com.empty?							
							page.call 'hide_achieve_part' ,"achieve_list_de_#{@task.id}"
						else							
							page.call 'show_achieve_part' ,"achieve_list_de_#{@task.id}"
						end	
						page.replace_html "todos_list_task_#{@task.id}", :partial => "projects/tasks/list_todo_details",:locals => {:task => @task}
						page.replace "view_achieved_todos_#{@task.id}",:partial => "projects/tasks/view_achieved_todos"	

            if params[:checked] and params[:checked] == "true"
							page.hide("todo_item_#{@todo.id}")
							page.visual_effect :appear, "todo_item_#{@todo.id}", :duration => 0.5,:startcolor=>"#FFFF00"									
						else
							page.hide("achieved_todo_#{@todo.id}")
							page.visual_effect :appear, "achieved_todo_#{@todo.id}", :duration => 0.5,:startcolor=>"#FFFF00"																
						end
            page.call 'set_visible_to_task' , @task.id		if !(params[:checked] and params[:checked] == "true")
					end
					if params[:dashboard] 
						 if @todo.is_completed == true
							page.call "completed_think","label_todo_#{@todo.id}","label_todo_#{@todo.id}"
						else
							page.call  "uncompleted_think","label_todo_#{@todo.id}","label_todo_#{@todo.id}"
						end 
						 #~ if finding_todos_list.count > 0				
							 #~ #page.visual_effect :fade, "todo_#{@todo.id}", :duration => 1				
						 #~ else
							#~ # page.visual_effect :fade, "dashboard_todos_list", :duration => 1	
						 #~ end					
					 end		
					 page.hide "view_achieved_todos_#{@task.id}"
				end			
		end	
		
		def destroy
				@todo = Todo.find_by_id(params[:id])
				@todo.destroy if !@todo.nil?
				#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")				
				get_todo_details(@task.id)
				render :update do |page|
					page.replace_html "todos_list_task_#{@task.id}", :partial => "projects/tasks/list_todo_details",:locals => {:task => @task}
					recent_todos(page)
				end	
		end	
    
		def reorder_todo
			i=1
				if params["tbody_for_task_#{params[:task_id]}"]
			for todo_id in params["tbody_for_task_#{params[:task_id]}"]
				todo = Todo.find_by_id(todo_id)
				todo.update_attributes(:task_id=>params[:task_id], :position=>i) if !todo.nil?

				i=i+1
			end	
			end
			#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")
			#~ get_todo_details(@task.id)
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
			render :update do |page|
				page.replace_html "task_list", :partial => "projects/tasks/tasks_list"
			end	
		end	
		
		def make_uncomplete
				@todo = Todo.find_by_id(params[:id])
				@todo.update_attributes(:is_completed => false) if !@todo.nil?
				#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")
				get_todo_details(@task.id)
				@todos_com = @task.todos.find_all_by_is_completed(true,:order => "position asc")
				render :update do |page|
					page.replace_html "todos_list_task_#{@task.id}", :partial => "projects/tasks/list_todo_details",:locals => {:task => @task}
					page.replace "view_achieved_todos_#{@task.id}",:partial => "projects/tasks/view_achieved_todos"
				end				
		end
		
		def destroy_comment
			comment_id = 	params[:comment_id]
			delete_comment
			@todo = Todo.find_by_id(params[:id])	
      @comments = @todo.comments	
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@todo_files = Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) if !@comments.empty?
			render :update do |page|
				#page.replace_html "comments_list",:partial => "list_comments",:locals=>{:parent => 'todo'}
				page.replace_html  "todo_files" ,:partial => "todo_files"
				if @comments.count == 0
					page.visual_effect :fade, "comments_list", :duration => 1
				else	
					page.visual_effect :fade, "comment_#{comment_id}", :duration => 1
					page.replace_html  "lastest_comment" ,:partial=>'/projects/tasks/todos/lastest_comment',:locals=>{:comments => @comments}				
				end				
			end	
		end			
		
		def update_status_path
			if request.xhr?
				@todo = Todo.find_by_id(params[:id]) if !params[:id].nil?
				@comment = Comment.find_by_id(params[:comment_id])
				@comment.status = params[:status]				
				@comment.save				
				history_update_for_comment(@comment, "set status to #{params[:status]}")									
				render :update do |page|
					page.replace_html "set_status_#{@comment.id}", :partial => "status_update" , :locals => {:comment => @comment,:parent => params[:parent] }		
					page.replace_html "history_#{@comment.id}", :partial => "history" , :locals => {:comment => @comment,:parent => params[:parent] }		
					page.call 'check_visible_for_comment_history', @comment.id
				end			
			end
		end	
		
		def get_history_details
			if request.xhr?
				render :update do |page|
					@comment = Comment.find_by_id(params[:comment_id])
					page.replace_html "history_link_#{@comment.id}", :partial => "history_link" ,  :locals => {:comment => @comment,:parent => params[:parent] }		
					page.replace_html "history_#{@comment.id}", :partial => "history" , :locals => {:comment => @comment,:parent => params[:parent] }		
					if params[:show_history]
						page.show "history_display_#{@comment.id}"
					else
						page.hide "history_display_#{@comment.id}"
					end				
				end			
			end		
		end	
		
		def download
			attachment = Attachment.find_by_id(params[:id])
			@attachment_size=attachment.size
			download_bandwidth_calculation
			@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
				if @status==false
				responds_to_parent do	
						render :update do |page|	
							page.redirect_to :back
							page.alert "Please upgrade your plan on your account page to raise your transfer limits." 
						end
					end
			else
			download_file(attachment) if attachment		
			end
		end	
    
  def download_todo
    @todo=Todo.find_by_id(params[:id])
    unless @todo.nil?
      contents= find_todo_contents(@todo)
      contents<<add_comments_in_files(@todo)
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
				send_data(contents,:filename=>"Todo #{file_time}.txt",:type=>"text/plain")
			end
    end
  end
		
  def find_todo_contents(todo)
    contents= file_headers(todo)
    contents<< "Due Date: #{todo.due_date}" if todo.due_date
    contents
  end
	
	def change_todo_status
		todo = @task.todos.find_by_id(params[:id])
		if todo.todo_status.nil? 
			status ="In Progress"
		elsif todo.todo_status == "Not Started"
      status ="In Progress"			
    elsif todo.todo_status == "In Progress"
			status ="Late"
    else 
			status ="Not Started"
    end			
		todo.update_attributes(:todo_status => status)
		render :update do |page|
			page.replace "todo_status_#{todo.id}", show_status_flag(todo)		
		end	
	end	
	
		def subscribe_and_unsubscribe_post
		@notify=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=?', params[:id], "Todo", current_user.id])
		@project=Project.find_by_id(params[:project_id])
		@task=Task.find_by_id(params[:task_id])
		@todo=Todo.find_by_id(params[:id])
		if params[:subscribe]=="false"
			@notify.update_attributes(:is_notify=>false) if @notify
		elsif params[:subscribe]=="true"
			if @notify
				@notify.update_attributes(:is_notify=>true)
			else
				EmailNotification.create(:resource_id=>params[:id], :resource_type=>"Todo", :user_id=>current_user.id, :is_notify=>true)
			end
		end
		@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', params[:id], "Todo", current_user.id, true])
		
		#~ @comments=@todo.comments
		#~ @comments.each do |comment|
				#~ comment.update_attributes(:email_notify=>true)
		#~ end
		
		TodoUser.create(:user_id=>current_user.id, :todo_id=>params[:id])
		
		render :update do |page|
			page.replace_html "email_notification", :partial=>"todo_email_notification"
		end
	end
	
	
	def edit_todo_comment
				@comment=Comment.find_by_id(params[:id])
				@todo=Todo.find_by_id(params[:todo_id])
			end
	
	def update_todo_comment
		get_owner_projects
		@todo=Todo.find_by_id(params[:todo_id])
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
					page.redirect_to project_task_todo_path(@project.url, @project, @task, @todo)
				end
			end
		end
	else
				@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
				responds_to_parent do	
					if ((total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
              page['account-limit-modal'].show
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							page['account-limit-modal'].show
						end
					else
						render :update do |page|	
							page['account-limit-modal'].show
						end
					end
				end
			end
		end


	end
   
	 	def delete_todo_comment_attachment
		
		attach=Attachment.find_by_id(params[:id])
		@comment=Comment.find_by_id(attach.attachable_id)
		attach.destroy
		render :update do |page|
			page.replace_html 'existing_files', :partial=>"comment_existing_files"
		end
	end
	
	
	
	
	
	
  
		private
		def current_task
			@task = Task.find_by_id(params[:task_id])
		end
		
		def history_update_for_comment(resource,message)
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = message
			history.resource = resource
			history.save	
		end	
	
end
