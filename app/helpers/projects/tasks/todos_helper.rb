module Projects::Tasks::TodosHelper

    def store_assignee_details(user)
			if !params[:todo_users].nil? and !params[:todo_users].blank?
				index = params[:todo_users].index(":")
				users = params[:todo_users][0..index-1]
				type =params[:todo_users][index+1..params[:todo_users].length]
				@todo.assignee_type = type
				for user_id in users.split(",")
					@todo.todo_users << TodoUser.new(Hash[:user_id =>user_id]) 
				end	
			else
        @todo.assignee_type = 'Unassigned'				
			end					
			
			#@todo.todo_users << TodoUser.new(Hash[:user_id => user,:todo_id=>@todo.id])
			
		end	
		
		def display_selected_assignee
			@assigned_user = []
			if !@todo.assignee_type.nil? and !@todo.assignee_type.empty? and @todo.assignee_type!="Unassigned"
				todo_users = @todo.todo_users
				if !todo_users.empty? 
					if todo_users.length > 1
						 index = @assignees.flatten.index(@todo.assignee_type)
						 @assigned_user = @assignees[index/2]
					elsif todo_users.length ==1
						 assign_user = todo_users[0].user
						 @assigned_user = ["#{assign_user.first_name.capitalize} #{assign_user.last_name.first.capitalize}.","#{assign_user.id}:#{assign_user.first_name.capitalize} #{assign_user.last_name.first.capitalize}."]	                  						
					end	
				end	
			else
 				@assigned_user =  ["Unassigned",""]		
			end				
		end	
		
		def assignees_list
			@users =@project.members
			@assignees = []	
			@assignees << ["All of #{@project.name}","#{@users.map(&:id).join(",")}:All of #{@project.name}"]	
			@company_list = @project.members.find(:all,:select => " company, count( * ) ",:from => "users",:group=> "company",:having =>"count( * ) > 1" )#_by_sql("SELECT  company, count( * ) FROM users GROUP BY company HAVING count( * ) > 1")
			for company in @company_list
				@assignees << ["All of #{company.company}","#{@users.find_all_by_company(company.company).map(&:id).join(",")}:All of #{company.company}"]		
			end			
			for user in @users
				@assignees << ["#{user.first_name.capitalize} #{user.last_name.first.capitalize}.","#{user.id}:#{user.first_name.capitalize} #{user.last_name.first.capitalize}."]		
			end			
			@assignees << ["Unassigned",""]		     
		end	
		
		def recent_todos(page)
			@recent_todos = Todo.find(:all,:conditions => ["todos.task_id = tasks.id and tasks.project_id=? and todos.is_completed=?",@project.id,false],:select => "distinct todos.*",:order => "id desc",:limit => 5,:from => "tasks,todos")
			page.replace_html 'recent_todos',:partial => "projects/tasks/recent_todos",:locals=>{:recent_todos => @recent_todos}
		end		
		
		def send_mail_to_todo_assignee
			todo_users = @todo.todo_users
			for each_user in todo_users
				user= User.find_by_id(each_user.user_id)
				if user 
					UserMailer.deliver_todo_assign_mail(@project,@todo,current_user,user,request.env['HTTP_HOST'],request.env['SERVER_NAME']) rescue ''
				end	
			end	
		end	
		
		def send_comment_nofication_mail_to_todo_assignee
			todo_users = @todo.todo_users
			for each_user in todo_users
				user= User.find_by_id(each_user.user_id)
				if user 					
					UserMailer.deliver_todo_comment_notify_mail(@project,@todo,@comment,current_user,user,request.env['HTTP_HOST'],request.env['SERVER_NAME']) rescue ''
				end	
			end	
		end		

    def store_todo_details_to_the_user(todo,comment) 
			project = todo.task.project
			@project_users = ProjectUser.find_all_by_project_id(project.id)
			for project_user in @project_users
				if !project_user.user_id.nil? 
					status = (project_user.user_id == current_user.id) ? true : false
					TodoCommentsDisplay.create(:user_id => project_user.user_id,:todo_id => todo.id,:comment_id => comment.id,:is_viewed => status)
				end						
			end							
		end	
		
		def change_todo_comments_status_in_show(comments,todo)
			TodoCommentsDisplay.update_all( "is_viewed = true", [" user_id =? and comment_id IN (?) and todo_id =?  ",current_user.id,comments.map(&:id),todo.id])
		end	
    
end
