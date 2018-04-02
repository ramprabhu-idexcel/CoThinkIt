module Projects::TasksHelper

	def sidebar_function_for_task(page)
		@current_tasks = Task.find_all_by_project_id_and_is_completed(@project.id,false,:order => "position asc",:limit => 3)
		@completed_tasks = Task.find_all_by_project_id_and_is_completed(@project.id,true,:order => "position asc")
			page.replace_html 'current_tasks', :partial => "current_task",:locals=>{:current_tasks => @current_tasks}	
			page.replace_html 'completed_tasks',:partial => "completed_tasks",:locals=>{:completed_tasks => @completed_tasks}					
  end		
  
  def get_task_details
    filter = params[:filter_option]
    if filter.nil? or filter.blank? or filter == "View All"
      @tasks = @project.tasks.find_all_by_is_completed(false,:order=>"position Desc")
    elsif filter == "Due Today"
      @tasks = @project.tasks.find(:all,:conditions => ["todos.due_date=? and todos.is_completed=?",Date.today.strftime('%Y-%m-%d'),false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")
    elsif filter == "Assigned to me"
			name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
      @tasks = @project.tasks.find(:all,:conditions => ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=?",current_user.id,name,"%#{'All of'}%", false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
    elsif filter == "Unassigned"
      @tasks = @project.tasks.find(:all,:conditions => ["todos.assignee_type=? and todos.is_completed=?","Unassigned",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
	  elsif filter == "Not started"
      @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")  
    elsif filter == "In progress"
      @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
    elsif filter == "Late"
      @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
elsif filter == "Assigned to mytask"
			name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
      @tasks = @project.tasks.find(:all,:conditions => ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=?",current_user.id,name,"%#{'All of'}%", false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      			
    end  
  end   
  
  def get_todo_details(task_id)
    @task = Task.find_by_id(task_id)
    filter = params[:filter_option]
    if filter.nil? or filter.blank? or filter == "View All"
      @todos = @task.todos.find_all_by_is_completed(false,:order=>"position asc")
    elsif filter == "Due Today"
      @todos = @task.todos.find(:all,:conditions => ["todos.due_date=? and todos.is_completed=?",Date.today.strftime('%Y-%m-%d'),false],:order=>"position asc",:select => "distinct todos.*")
    elsif filter == "Assigned to me"
			name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
      @todos = @task.todos.find(:all,:conditions => ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=?",current_user.id, name,"%#{'All of'}%", false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")      
    elsif filter == "Unassigned"
      @todos = @task.todos.find(:all,:conditions => ["todos.assignee_type=? and todos.is_completed=?","Unassigned",false],:order=>"position asc",:select => "distinct todos.*") 
    elsif filter == "Not started"
      @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*") 
    elsif filter == "In progress"
      @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*")    
    elsif filter == "Late"
      @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*") 	    
    elsif filter == "Assigned to mytask"
			name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
			@now_todo=@task.todos.last 
			@todos=[]
      @todos << @task.todos.find(:all,:conditions => ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=?",current_user.id, name,"%#{'All of'}%", false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")      			
			@todos=@todos.flatten
			@todos << @task.todos.last if !@todos.include?(@now_todo)
			@todos=@todos.flatten
    end  
  end  

  def delete_comment
		@comment = Comment.find_by_id(params[:comment_id])
		@comment.destroy if @comment		
	end	
	
	def comment_history_create		
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = "added a comment"
			@comment.history_posts << history	
      @comment.status = "pending"			
		end	
		
	def comment_history_update
			history = HistoryPost.new
			history.user_id = current_user.id
			history.action = "edited a comment"
			@comment.history_posts << history	
  end	

  def check_guest_user_permission
		if !check_role_for_guest
			redirect_to project_tasks_path(@project.url,@project)
		end	
	end	
	
	def today_task_list_for_current_project	
		@project.tasks.find(:all,:conditions=>['due_date=? AND is_completed=?', find_current_zone_date.to_date, false])
	end
	
	def today_task_list_for_all_project		
		list_current_user_projects
		@projects.each do |project|
      @tasks<<project.tasks.find(:all,:conditions=>['due_date=? AND is_completed=?', find_current_zone_date.to_date, false])
		end	
    @tasks.flatten		
	end	
	
	def today_todo_list_for_current_project
		@project.todos.find(:all,:conditions=>['todos.due_date=? AND todos.is_completed=?', find_current_zone_date.to_date, false])
	end

	def today_todo_list_for_all_project
		list_current_user_projects
		@projects.each do |project|
      @todos<<project.todos.find(:all,:conditions=>['todos.due_date=? AND todos.is_completed=?', find_current_zone_date.to_date, false])
		end
    @todos.flatten		
	end
		
	
	def finding_tasks_list
		 @project.nil? ? today_task_list_for_all_project : today_task_list_for_current_project			
  end
	 
	def finding_todos_list
		 @project.nil? ? today_todo_list_for_all_project : today_todo_list_for_current_project			
	 end	
	 
	 def show_status_flag(todo)		
		  link=change_todo_status_path(@project.url,@project,@task,todo,:status =>todo.todo_status )			
			return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-pending',:id => "todo_status_#{todo.id}"})  if todo.todo_status.nil?
			if  todo.todo_status == "Not Started"			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-pending',:id => "todo_status_#{todo.id}",:title=>"Not Started" })
			elsif todo.todo_status == "In Progress"			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-inprogress',:id => "todo_status_#{todo.id}",:title=>"In Progress"})
			else	 			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-overdue',:id => "todo_status_#{todo.id}",:title=>"Late"})
			end	 
	 end 

   def check_unread_comments(todo)
		 check= TodoCommentsDisplay.find(:all,:conditions =>["todo_id =? and user_id = ? and is_viewed = ?",todo.id,current_user.id,false])		 
		 return check.empty?  ? "read" : ""
	 end 
	 
	def store_task_comments_details_to_the_user(comment) 
			project = comment.project
			@project_users = ProjectUser.find_all_by_project_id(project.id)
			for project_user in @project_users
				if !project_user.user_id.nil? 
					status = (project_user.user_id == current_user.id) ? true : false
					PostsCommentsDisplay.create(:user_id => project_user.user_id,:comment_id => comment.id,:is_task_comment_viewed=>status, :is_task=>true)
				end						
			end							
		end	
		
				def change_task_comment_status_in_show(comments)			
			PostsCommentsDisplay.update_all( "is_task_comment_viewed = true", ["user_id =? and comment_id IN (?) and is_task =?  ",current_user.id,comments.map(&:id),true])
			end	
		
end  
