class MyTasksController < ApplicationController
	layout 'base'
	include ApplicationHelper
	include Projects::TasksHelper
	include Projects::Tasks::TodosHelper	
	include MyTasksHelper
	before_filter :login_required	
	
	def index
		sidebar_details
		@project_owner=ProjectUser.find_by_user_id(current_user.id,:conditions=>['is_owner=?', true])
    send_users_offline
    online_users_on_global
    get_storage_stats
    new_member_invitation
    time_zone=find_time_zone
    current_date=find_current_zone_date(time_zone)
    current_time=current_date
		@current_date=current_date.to_date
		@year=@current_date.year
    @month=@current_date.month
    
    @all_events=current_user.all_events(current_user.id).group_by{|d| (d.created_at+(find_current_zone_difference(time_zone))).to_date}
    @size=@all_events.keys.count
    @date=@all_events.keys[2]
		@progress_projects=current_user.projects.find_all_by_is_completed(false)
		@completed_projects=current_user.projects.find_all_by_is_completed(true)		
		
		get_my_task_details
		
		@my_tasks=[]
		@containment=[]
		if !@tasks.empty?
		@tasks.each do |pos,task|
			task.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
			end
		end
		@my_tasks=@my_tasks.flatten
		end
		
	end	
	
	def new_my_task
		@task = Task.new	
    @users = User.find(:all)	
		@current_date=find_current_zone_date		
		@year = @current_date.year
		@month = @current_date.month		
	end

  def create_my_task
		get_my_task_details
		    first_task=@tasks.empty?
				
		@task = Task.new(params[:task])
		@task.user_id = current_user.id		
		@task.is_completed = false		
		max_position = Task.find(:all,:select => "max(position) as max_position",:conditions => ["project_id IS NULL and user_id = ?",current_user.id])
		@task.position =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1

		render :update do |page|
			if @task.save
        task_id =  @task.id
        if first_task
          page.redirect_to my_tasks_path
        else
          page.call "close_control_model"				
          #@tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position asc")
          get_my_task_details
					@tasks.each do |pos, task1| 
if pos.nil?
								page.replace_html 'task_list_',:partial => "tasks_list", :locals => {:task1 => task1}
								else
  			page.replace_html "task_list_#{pos}",:partial => "tasks_list", :locals => {:task1 => task1}
				
				end
				end
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

  def new_my_todo
			@task=Task.find_by_id(params[:id])
			@todo = Todo.new			
			@current_date=find_current_zone_date		
			@year = @current_date.year
			@month = @current_date.month		
			@task_id=@task
		get_my_task_details
		
		@my_tasks=[]
		@containment=[]
		if !@tasks.empty?
		@tasks.each do |pos,task|
			task.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
			end
		end
		@my_tasks=@my_tasks.flatten
		end			
			if request.xhr?
				render :update do |page|
				if !@task.todos.empty?
					 get_my_todo_details(@task.id)					 					 
					page.replace_html "tbody_for_task_#{@task.id}", :partial=>"list_todo_details",:locals => {:task => @task}	
				end
					page["add_todo_link_for_#{@task.id}"].hide();
					page.replace "create_new_todo_#{@task.id}" ,:partial => "new"
				end	
			end	
	end

  def create_my_todo
		@task=Task.find_by_id(params[:task_id])
		@todo = Todo.new(params[:todo])
		@todo.user_id=current_user.id
		@todo.task_id = @task.id
		@todo.is_completed = false
		@todo.email_notify = true
	#	 store_assignee_details
	@todo.assignee_type="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
		 max_position = @task.todos.find(:all,:select => "max(position) as max_position")		 
		 @todo.position =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1	
		#	assignees_list
			@current_date=find_current_zone_date		
			@year = @current_date.year
			@month = @current_date.month		
					
		 render :update do |page|		 
			 if @todo.save				   
				 	 #@todos = @task.todos.find_all_by_is_completed(false)		
					 #~ get_my_todo_details(@task.id)			
get_only_my_task_details
		
		@my_tasks=[]
		@containment=[]
		#~ if !@tasks.empty?
		#~ @tasks.each do |pos,task|
			#~ task.each do |t|
				#~ @my_tasks<<t.id
					#~ @containment<<"tbody_for_task_#{t.id}"
			#~ end
		#~ end		end					 
				  # page[:todo_title_error].innerHTML = ""
          # page[:success_message].innerHTML = "Todo added successfully"
           #page.visual_effect(:highlight,'success_message', :duration => 2.5,:startcolor=>"#E5FDD0")
        #   page.visual_effect :fade,'success_message',:duration => 1									 
					 #page.alert("Todo added successfully")
					 @task_id=@task
					 		 
					 page.call "close_control_model"
					 		@tasks.each do |pos, task1| 
		task1.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
				end
				


							if pos.nil?
								page.replace_html 'task_list_',:partial => "tasks_list", :locals => {:task1 => task1}
							end
									@my_tasks=@my_tasks.flatten
			end
					 #~ page.replace_html "todos_list_task_#{@task.id}", :partial => "list_todo_details",:locals => {:task => @task}	
					 
					 page.hide "todo_item_#{@todo.id}"
					 page.visual_effect :appear, "todo_item_#{@todo.id}", :duration => 1,:startcolor=>"#FFFF66"	
					 page.replace "create_new_todo_#{@task_id.id}" ,:partial => "new"
					 
					# recent_todos(page)					 					 
#					 send_mail_to_todo_assignee					 
			 else	 
				#~ for each_error in @todo.errors.entries
					#~ page.replace_html 'todo_title_error',each_error[1] if each_error[0] == "title"
				#~ end				
         page.alert "#{@todo.errors.entries.first[1]}"				
			 end	 
		 end	
	end

  def edit_my_todo
		@todo = Todo.find_by_id(params[:id])
		@task=@todo.task
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

  def update_my_todo
		@todo = Todo.find_by_id(params[:todo_id])
		@task=@todo.task
		@todo.attributes = params[:todo]			
		@todo.todo_users.delete_all
		render :update do |page|
			if @todo.save					
				if @todo.todo_status == "Late" and !@todo.due_date.nil?
					if @todo.due_date >= Date.today
						@todo.update_attributes(:todo_status => "In Progress")
					end	
				end	
				#@todos = @task.todos.find_all_by_is_completed(false)				
				#~ get_my_todo_details(@task.id)
					@c=params[:alt]
				page.call "close_control_model"
						#~ page.replace "todo_item_#{@todo.id}", :partial => "my_tasks/todo_details"
			#	page.replace_html "todos_list_task_#{@task.id}", :partial => "list_todo_details",:locals => {:task => @task}
				page.hide "todo_item_#{@todo.id}"
				page.visual_effect :appear, "todo_item_#{@todo.id}", :duration => 1,:startcolor=>"#FFFF66"				
				get_only_my_task_details
				@my_tasks=[]
				@containment=[]
		 		@tasks.each do |pos, task1| 
				task1.each do |t|
					@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
				end
				@my_tasks=@my_tasks.flatten
					if pos.nil?
						page.replace_html 'task_list_',:partial => "tasks_list", :locals => {:task1 => task1}
					end
				end
										#page.visual_effect(:highlight,"todo_item_#{@todo.id}", :duration => 2.5,:startcolor=>"#000000")					
				#recent_todos(page)
			else
				#~ for each_error in @todo.errors.entries
				#~ page.replace_html 'todo_title_error',each_error[1] if each_error[0] == "title"
				#~ end		
        page.alert "#{@todo.errors.entries.first[1]}"							
			end	
		end		
	end
	
	def delete_my_todo
				@todo = Todo.find_by_id(params[:id])
				@todo.destroy if !@todo.nil?
				@task=@todo.task
				#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")				
				get_my_todo_details(@task.id)
				render :update do |page|
					page.replace_html "todos_list_task_#{@task.id}", :partial => "list_todo_details",:locals => {:task => @task}
					#recent_todos(page)
				end	
	end
	
	
	def completed_todo_my_task
				@todo = Todo.find_by_id(params[:id])
				@task=@todo.task
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
				get_my_todo_details(@task.id)
					get_my_task_details
		
		@my_tasks=[]
		@containment=[]
		if !@tasks.empty?
		@tasks.each do |pos,task|
			task.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
			end
		end
		@my_tasks=@my_tasks.flatten
		end
				@todos_com = @task.todos.find_all_by_is_completed(true,:order => "position asc")				
				render :update do |page|					
					if params[:no_update].nil?						
						if @todos_com.empty?							
							page.call 'hide_achieve_part' ,"achieve_list_de_#{@task.id}"
						else							
							page.call 'show_achieve_part' ,"achieve_list_de_#{@task.id}"
						end	
						page.replace_html "todos_list_task_#{@task.id}", :partial => "list_todo_details",:locals => {:task => @task}
						page.replace "view_achieved_todos_#{@task.id}",:partial => "view_achieved_todos"	

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
			
				def achieved_my_todo
		@task = Task.find_by_id(params[:id])
		if params[:achieve]
			@todos_com = @task.todos.find_all_by_is_completed(true,:order => "position asc")
    end			
		render :update do |page|
			page.replace "view_completed_#{params[:id]}", :partial => "achieve_link"
			page.replace "view_achieved_todos_#{params[:id]}",:partial => "view_achieved_todos"
		end
	end
	
		def change_mytodo_status
			
		todo = Todo.find_by_id(params[:id])
		
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
			page.replace "todo_status_#{todo.id}", show_status_flag_my_task(todo)		
		end	
	end	
	
		def completed_mytask
		@task = Task.find_by_id(params[:id])
		if params[:dashboard].nil?
			if params[:checked] and (params[:checked] == "true" or params[:checked] == true)
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
get_my_task_details


		render :update do |page|			
		  if params[:checked].nil?
					page.visual_effect :fade, "task-#{@task.id}", :duration => 1
					#page.replace_html "task_list", :partial => "tasks_list"	
					#	sidebar_function_for_task(page)			
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
	
	def change_status_of_todos(todos , status)
		for todo in todos
			 todo.update_attributes(:is_completed => status)
		end	
	end
	
  def mytask_filter

			get_my_task_details

		
		@my_tasks=[]
		@containment=[]
		if !@tasks.empty?
		@tasks.each do |pos,task|
			task.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
			end
		end
		@my_tasks=@my_tasks.flatten
		end
			render :update do |page|
					#~ page.redirect_to my_tasks_path
				#~ page.replace_html "task_list", :partial => "tasks_list"	
				
				@array=[]
				@tasks1.each do |pos, task1| 
						@array<<pos
				end
				
				@array1=[]
				if @tasks.empty?
					@tasks.each do |pos, task1| 
						@array1<<pos
				 end
			 end
			 
			 new_array=@array-@array1
			 new_array.each do |array|
				 
			 end
				if !new_array.empty?
					new_array.each do |array|
											if array.nil?
						page.hide "task_list_"
					else
						page.hide "main-padder_#{array}"
					end
					end
				end
				if @tasks.empty?
					@tasks1.each do |pos, task1| 
					if pos.nil?
						page.hide "task_list_"
					else
						page.hide "main-padder_#{pos}"
					end
					end
				else
					@tasks.each do |pos, task1| 
					if pos.nil?
						page.show "task_list_"
						page.replace_html "task_list_",:partial => "tasks_list", :locals => {:task1 => task1}
					else
							page.show "main-padder_#{pos}"
						page.replace_html "task_list_#{pos}",:partial => "tasks_list", :locals => {:task1 => task1}
				end
			end
			end
			end     
		end
		
			
	def change_reorder_mytask_page
		#@tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position asc")
		get_my_task_details
		render :update do |page|
			if params[:reorder]				
				page.replace_html 'task_list_',:partial => "reorder_tasks"
			else

						@tasks.each do |pos, task1| 
		
							if pos.nil?
								page.replace_html 'task_list_',:partial => "tasks_list", :locals => {:task1 => task1}
								else
  			page.replace_html "task_list_#{pos}",:partial => "tasks_list", :locals => {:task1 => task1}
				
				end
				end
				#~ page.redirect_to my_tasks_path
			end
			page.replace 'reorder-tasks',:partial => "reorder_link_display"	
    end		
	end

  def reorder_mytask
		
		get_my_task_details
		i= @tasks.count
		for task_id in params[:task_list_]
			task = Task.find_by_id(task_id)
			task.update_attribute(:position,i) if !task.nil?
			i=i - 1
		end	
		render :text => "success"
	end	
	
	def post_my_task_comment
		get_owner_projects_mytask

			@todo = Todo.find_by_id(params[:id])	
			@comment = Comment.new(params[:comment])
			@comment.commentable = @todo
			@comment.project_id=nil
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
						#		store_todo_details_to_the_user(@todo,@comment) 
#								send_comment_nofication_mail_to_todo_assignee						
								@comments = @todo.comments		
								@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
								@task=@todo.task
								@todo_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
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
					@project_owner=ProjectUser.find_by_is_owner_and_user_id(true, current_user.id)
					responds_to_parent do	
					if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
						if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your transfer limits."
						else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
						end
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your storage limits."
							else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					else
						render :update do |page|	
							if @project_owner
									page.alert "Please upgrade your plan on your account page to raise your transfer limits."
							else
									page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					end
				end
			end
		end
	end
	
			def show_my_task
					@project_owner=ProjectUser.find_by_user_id_and_is_owner(current_user.id, true)
					if @project_owner
						check_bandwidth_usage_mytask
					else
						@status=false
					end 
  @projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
			#~ check_bandwidth_usage
			@todo = Todo.find_by_id(params[:id])	
			@task=@todo.task
								@email_notification=EmailNotification.find(:first, :conditions=>['resource_id=? and resource_type=? and user_id=? and is_notify=?', @todo.id, "Todo", current_user.id, true])
								
			if @todo
					@comments = @todo.comments			
					@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
					@todo_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
					
					change_todo_comments_status_in_show(@comments,@todo) if !@comments.empty?
			else
					redirect_to '/global'
			end	
		end
		
				def download
			attachment = Attachment.find_by_id(params[:id])
			#~ @attachment_size=attachment.size
			#~ download_bandwidth_calculation
			#~ @project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
			download_file(attachment) if attachment		
		end	
		
		def destroy_mytask_comment
			comment_id = 	params[:comment_id]
			delete_comment
			@todo = Todo.find_by_id(params[:id])	
			@comments = @todo.comments	
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@task=@todo.task
			@todo_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
			render :update do |page|
				#page.replace_html "comments_list",:partial => "list_comments",:locals=>{:parent => 'todo'}
				page.replace_html  "todo_files" ,:partial => "todo_files"
				if @comments.count == 0
					page.visual_effect :fade, "comments_list", :duration => 1
				else	
					page.visual_effect :fade, "comment_#{comment_id}", :duration => 1
					page.replace_html  "lastest_comment" ,:partial=>'lastest_comment',:locals=>{:comments => @comments}				
				end				
			end	
		end		
			
			def edit_mytask_comment
				@projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
				@comment=Comment.find_by_id(params[:id])
				@todo=Todo.find_by_id(params[:todo_id])
			end
			
			def update_mytask_comment
				get_owner_projects_mytask
			@comment=Comment.find_by_id(params[:comment_id])
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
			@comment.update_attributes(:comment=>params[:comment][:comment])
				process_file_uploads(@comment)
				responds_to_parent do
			render :update do |page|
				if !@comment.errors.entries.blank?
					page.alert "#{@comment.errors.entries.first[1]}"							
				else
					page.redirect_to my_tasks_path
				end
			end
		end
			else
					@project_owner=ProjectUser.find_by_is_owner_and_user_id(true, current_user.id)
					responds_to_parent do	
					if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
						if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your transfer limits."
						else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
						end
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your storage limits."
							else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					else
						render :update do |page|	
							if @project_owner
									page.alert "Please upgrade your plan on your account page to raise your transfer limits."
							else
									page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					end
				end
			end
		end
		
	end
	
	
	# for tasklist comments
	
	def post_my_tasklist_comment
		
			get_owner_projects_mytask
			@task = Task.find_by_id(params[:id])	
			@comment = Comment.new(params[:comment])
			@comment.commentable = @task
			@comment.project_id=nil
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
						#		store_todo_details_to_the_user(@todo,@comment) 
#								send_comment_nofication_mail_to_todo_assignee						
								@comments = @task.comments		
								@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
								
								@todo_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
								page.replace "file_upload",:partial => "remove_upload_files"	
								page.replace_html  "comments_list" ,:partial => "list_tasklist_comments",:locals=>{:parent => 'task'}
								page.visual_effect(:highlight,"comment_#{@comment.id}", :duration => 2.5,:startcolor=>"#FFFFFF")
								page.replace_html  "task_files" ,:partial => "task_files"
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
					@project_owner=ProjectUser.find_by_is_owner_and_user_id(true, current_user.id)
					responds_to_parent do	
					if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
						if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your transfer limits."
						else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
						end
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your storage limits."
							else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					else
						render :update do |page|	
							if @project_owner
									page.alert "Please upgrade your plan on your account page to raise your transfer limits."
							else
									page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					end
				end
			end
		end
	end
	
		def show_my_tasklist
			@project_owner=ProjectUser.find_by_user_id_and_is_owner(current_user.id, true)
			if @project_owner
				check_bandwidth_usage_mytask
			else	
				@status=false
			end 
			@projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
			#~ check_bandwidth_usage
			@task = Task.find_by_id(params[:id])	

								
			if @task
					@comments = @task.comments			
					@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
					@task_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
			change_task_comment_status_in_show(@comments)			
			
			else
					redirect_to '/global'
			end	
		end
		

		def destroy_mytasklist_comment
			comment_id = 	params[:comment_id]
			delete_comment
			@task = Task.find_by_id(params[:id])	
			@comments = @task.comments	
			@comments=@comments.sort  { |a,b| a.updated_at <=> b.updated_at }			
			@task_files = Attachment.find(:all,:conditions => ["project_id IS NULL and attachable_type='Comment' and attachable_id IN (?)",@comments.map(&:id)]) if !@comments.empty?
			render :update do |page|
				#page.replace_html "comments_list",:partial => "list_comments",:locals=>{:parent => 'todo'}
				page.replace_html  "task_files" ,:partial => "task_files"
				if @comments.count == 0
					page.visual_effect :fade, "comments_list", :duration => 1
				else	
					page.visual_effect :fade, "comment_#{comment_id}", :duration => 1
					page.replace_html  "lastest_comment" ,:partial=>'lastest_comment',:locals=>{:comments => @comments}				
				end				
			end	
		end		
			
			def edit_mytasklist_comment
				@projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
				@comment=Comment.find_by_id(params[:id])
				@task=Task.find_by_id(params[:task_id])
			end
			
			def update_mytasklist_comment
				get_owner_projects_mytask
			@comment=Comment.find_by_id(params[:comment_id])
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
			@comment.update_attributes(:comment=>params[:comment][:comment])
				process_file_uploads(@comment)
				responds_to_parent do
			render :update do |page|
				if !@comment.errors.entries.blank?
					page.alert "#{@comment.errors.entries.first[1]}"							
				else
					page.redirect_to my_tasks_path
				end
			end
		end
		
			else
					@project_owner=ProjectUser.find_by_is_owner_and_user_id(true, current_user.id)
					responds_to_parent do	
					if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
						if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your transfer limits."
						else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
						end
					end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							if @project_owner
								page.alert "Please upgrade your plan on your account page to raise your storage limits."
							else
								page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					else
						render :update do |page|	
							if @project_owner
									page.alert "Please upgrade your plan on your account page to raise your transfer limits."
							else
									page.alert "This project has reached its storage and/or transfer limit. Please notify the Project Owner that he or she should upgrade his or her cothinkit plan on the Account Page."
							end
						end
					end
				end
			end
		end
			end
	
	    
		def reorder_mytodo
			i=1
			if params["tbody_for_task_#{params[:task_id]}"]
			for todo_id in params["tbody_for_task_#{params[:task_id]}"]
				todo = Todo.find_by_id(todo_id)

				todo.update_attributes(:task_id=>params[:task_id], :position=>i) if !todo.nil?
				i=i+1
			end	
			end
			@task=Task.find_by_id(params[:task_id])
			#@todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")
			get_my_todo_details(@task.id)
					get_my_task_details
		
		@my_tasks=[]
		@containment=[]
		if !@tasks.empty?
		@tasks.each do |pos,task|
			task.each do |t|
				@my_tasks<<t.id
					@containment<<"tbody_for_task_#{t.id}"
			end
		end
		@my_tasks=@my_tasks.flatten
		end
		
			render :update do |page|
				page.replace_html "todos_list_task_#{@task.id}", :partial => "my_tasks/list_todo_details",:locals => {:task => @task}
			end	
		end	
		
		private
	def sidebar_details
		@recent_todos = Todo.find(:all,:conditions => ["todos.task_id = tasks.id and todos.user_id=? and todos.is_completed=?",current_user.id,false],:select => "distinct todos.*",:order => "id desc",:limit => 5,:from => "tasks,todos")
	
		
		
			@completed_tasks=[]
			@completed_tasks<<Task.find(:all, :conditions=> ["tasks.user_id=? and tasks.is_completed=? and project_id IS NULL",current_user.id,true],:include=>:todos, :select => "distinct tasks.*")
			
    	@completed_tasks<<Task.find(:all, :conditions=> ["todo_users.user_id=? and tasks.is_completed=? and tasks.project_id IS NOT NULL ",current_user.id,true],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
		  @completed_tasks=@completed_tasks.flatten
			
			@current_tasks=[]
			@current_tasks<<Task.find(:all, :conditions=> ["tasks.user_id=? and tasks.is_completed=? and project_id IS NULL",current_user.id,false],  :limit=>3, :include=>:todos, :select => "distinct tasks.*") 
			@current_tasks<<Task.find(:all, :conditions=> ["todo_users.user_id=? and tasks.is_completed=? and tasks.project_id IS NOT NULL ",current_user.id,false],:order=>"position Desc",:limit=>3, :joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
		  @current_tasks=@current_tasks.flatten

			
	end	
	
	
end
