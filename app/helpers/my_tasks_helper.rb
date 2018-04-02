module MyTasksHelper
  def get_my_task_details
    
    filter = params[:filter_option]
    @name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
    if filter.nil? or filter.blank? or filter == "View All"
      @my_tasks = Task.find_all_by_is_completed_and_project_id_and_user_id(false,nil,current_user.id,:order=>"position Desc")
      @project_tasks=Task.find(:all, :conditions=> ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and project_id IS NOT NULL",current_user.id,@name,"%#{'All of'}%",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
      @tasks=[]
      @tasks<<@my_tasks
      @tasks<<@project_tasks
      @tasks=@tasks.flatten
      @tasks=@tasks.group_by{|e| e.project_id}
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse
        find_all_tasks
    elsif filter == "Due Today"

           @my_tasks = Task.find(:all, :conditions=> ["todos.user_id=? and todos.is_completed=? and todos.due_date=? and project_id IS NULL",current_user.id,false,Date.today.strftime('%Y-%m-%d')],:include=>:todos, :select => "distinct tasks.*")      
      @project_tasks=Task.find(:all, :conditions=> ["todos.due_date=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and tasks.project_id IS NOT NULL ",Date.today.strftime('%Y-%m-%d'),current_user.id,@name,"%#{'All of'}%", false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
      @tasks=[]
      @tasks<<@my_tasks
      @tasks<<@project_tasks
      @tasks=@tasks.flatten
            @tasks=@tasks.group_by{|e| e.project_id}
                       
              find_all_tasks
            
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse

    elsif filter == "Due This Week"
weekend=Date.today
weekend=weekend+6


           @my_tasks = Task.find(:all, :conditions=> ["todos.user_id=? and todos.is_completed=? and todos.due_date>=? and todos.due_date<=? and project_id IS NULL",current_user.id,false,Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d')],:include=>:todos, :select => "distinct tasks.*")      
      @project_tasks=Task.find(:all, :conditions=> ["todos.due_date>=? and todos.due_date<=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and project_id IS NOT NULL ",Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d'),current_user.id,@name, "%#{'All of'}%",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")        
            @tasks=[]
      @tasks<<@my_tasks
      @tasks<<@project_tasks
      @tasks=@tasks.flatten
            @tasks=@tasks.group_by{|e| e.project_id}
            
              find_all_tasks
            
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse

    #~ elsif filter == "Unassigned"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.assignee_type=? and todos.is_completed=?","Unassigned",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
	  #~ elsif filter == "Not started"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")  
    #~ elsif filter == "In progress"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
    #~ elsif filter == "Late"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   			
    end  
  end   
  
  def get_my_todo_details(task_id)
     @task = Task.find_by_id(task_id)
         @name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
    filter = params[:filter_option]
    if filter.nil? or filter.blank? or filter == "View All"
      @todos=[]
               @todos << @task.todos.find(:all,:conditions => ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=?",current_user.id,@name,"%#{'All of'}%",false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")  
        @todos<<@task.todos.find(:all,:conditions => ["user_id=? and is_completed=?",current_user.id,false],:order=>"position asc") if @task.project.nil?
      @todos=@todos.flatten

            #~ @todos = @task.todos.find(:all,:conditions => ["((todos.user_id=? OR todo_users.user_id=?) and is_completed=?)",current_user.id,current_user.id,false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id")  
      #~ @todos << @task.todos.find(:all,:conditions => ["todo_users.user_id=? and todos.is_completed=?",current_user.id,false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")  


    elsif filter == "Due Today"
      
      @todos=[]
        #~ @todos << @task.todos.find(:all,:conditions => ["todos.due_date=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?)))  and todos.is_completed=?",Date.today.strftime('%Y-%m-%d'),current_user.id,@name,"%#{'All of'}%", false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")  
        @todos<<@task.todos.find(:all,:conditions => ["due_date=? and (assignee_type=? or assignee_type LIKE (?)) and is_completed=?",Date.today.strftime('%Y-%m-%d'),@name,"%#{'All of'}%",false],:order=>"position asc")
        
        @todos=@todos.flatten
    elsif filter == "Due This Week"
            @todos=[]
      weekend=Date.today
weekend=weekend+6
      #~ @todos << @task.todos.find(:all,:conditions => ["due_date>=? and due_date<=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?)))  and todos.is_completed=?",Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d'),current_user.id,@name,"%#{'All of'}%", false],:order=>"position asc",:joins => "inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct todos.*")      
              @todos<<@task.todos.find(:all,:conditions => ["due_date>=? and due_date<=? and (assignee_type=? or assignee_type LIKE (?)) and is_completed=?",Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d'),@name,"%#{'All of'}%",false],:order=>"position asc")
        @todos=@todos.flatten

    #~ elsif filter == "Unassigned"
      #~ @todos = @task.todos.find(:all,:conditions => ["todos.assignee_type=? and todos.is_completed=?","Unassigned",false],:order=>"position asc",:select => "distinct todos.*") 
    #~ elsif filter == "Not started"
      #~ @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*") 
    #~ elsif filter == "In progress"
      #~ @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*")    
    #~ elsif filter == "Late"
      #~ @todos = @task.todos.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position asc",:select => "distinct todos.*") 	     
    end  
  end
  
  def find_all_tasks
     @name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
    
      @my_tasks1 = Task.find_all_by_is_completed_and_project_id_and_user_id(false,nil,current_user.id,:order=>"position Desc")
      @project_tasks1=Task.find(:all, :conditions=> ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and project_id IS NOT NULL",current_user.id,@name,"%#{'All of'}%",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
      @tasks1=[]
      @tasks1<<@my_tasks1
      @tasks1<<@project_tasks1
      @tasks1=@tasks1.flatten
      @tasks1=@tasks1.group_by{|e| e.project_id}

  end

	 def show_status_flag_my_task(todo)		
		 project = todo.task.project
		  link=!project.nil? ? change_todo_status_path(project.url,project,todo.task,todo,:status =>todo.todo_status )	: change_mytodo_status_path(:id=>todo.id, :status=>todo.todo_status)
			return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-pending',:id => "todo_status_#{todo.id}"})  if todo.todo_status.nil?
			if  todo.todo_status == "Not Started"			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-pending',:id => "todo_status_#{todo.id}",  :title=>"Not Started" })
			elsif todo.todo_status == "In Progress"			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-inprogress',:id => "todo_status_#{todo.id}",  :title=>"In Progress"})
			else	 			
				return link_to_remote( "<span>flag</span>",{:url => link,:method =>:get},{:class => 'flag-overdue',:id => "todo_status_#{todo.id}",  :title=>"Late"})
			end	 
    end 
    
    
    
     def get_only_my_task_details
    
    filter = params[:filter_option]
    @name="#{current_user.first_name.capitalize} #{current_user.last_name.first.capitalize}."
    if filter.nil? or filter.blank? or filter == "View All"
      @my_tasks = Task.find_all_by_is_completed_and_project_id_and_user_id(false,nil,current_user.id,:order=>"position Desc")
      #~ @project_tasks=Task.find(:all, :conditions=> ["(todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and project_id IS NOT NULL",current_user.id,@name,"%#{'All of'}%",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
      @tasks=[]
      @tasks<<@my_tasks
      #~ @tasks<<@project_tasks
      @tasks=@tasks.flatten
      @tasks=@tasks.group_by{|e| e.project_id}
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse
        find_all_tasks
    elsif filter == "Due Today"

           @my_tasks = Task.find(:all, :conditions=> ["todos.user_id=? and todos.is_completed=? and todos.due_date=? and project_id IS NULL",current_user.id,false,Date.today.strftime('%Y-%m-%d')],:include=>:todos, :select => "distinct tasks.*")      
      #~ @project_tasks=Task.find(:all, :conditions=> ["todos.due_date=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and tasks.project_id IS NOT NULL ",Date.today.strftime('%Y-%m-%d'),current_user.id,@name,"%#{'All of'}%", false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")      
      @tasks=[]
      @tasks<<@my_tasks
      #~ @tasks<<@project_tasks
      @tasks=@tasks.flatten
            @tasks=@tasks.group_by{|e| e.project_id}
                       
              find_all_tasks
            
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse

    elsif filter == "Due This Week"
weekend=Date.today
weekend=weekend+6


           @my_tasks = Task.find(:all, :conditions=> ["todos.user_id=? and todos.is_completed=? and todos.due_date>=? and todos.due_date<=? and project_id IS NULL",current_user.id,false,Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d')],:include=>:todos, :select => "distinct tasks.*")      
      #~ @project_tasks=Task.find(:all, :conditions=> ["todos.due_date>=? and todos.due_date<=? and (todo_users.user_id=? and (todos.assignee_type=? or todos.assignee_type LIKE (?))) and todos.is_completed=? and project_id IS NOT NULL ",Date.today.strftime('%Y-%m-%d'),weekend.strftime('%Y-%m-%d'),current_user.id,@name, "%#{'All of'}%",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id inner join todo_users on todos.id = todo_users.todo_id",:select => "distinct tasks.*")        
            @tasks=[]
      @tasks<<@my_tasks
      #~ @tasks<<@project_tasks
      @tasks=@tasks.flatten
            @tasks=@tasks.group_by{|e| e.project_id}
            
              find_all_tasks
            
      #~ @tasks=@tasks1.sort{|a,b| a<=>b}.reverse

    #~ elsif filter == "Unassigned"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.assignee_type=? and todos.is_completed=?","Unassigned",false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
	  #~ elsif filter == "Not started"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")  
    #~ elsif filter == "In progress"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   
    #~ elsif filter == "Late"
      #~ @tasks = @project.tasks.find(:all,:conditions => ["todos.todo_status=? and todos.is_completed=?",filter,false],:order=>"position Desc",:joins => "inner join todos on tasks.id = todos.task_id",:select => "distinct tasks.*")   			
    end  
  end   
end
