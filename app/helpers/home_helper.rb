module HomeHelper
  def show_unread_values(array)
    "<span class='shortcut-num'>#{array.count>99 ? '99+' : array.count}</span>"
  end
  
  def project_site_url(project)
    "https://#{project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
  end 
  
  def project_todo_site_url(comment)
    if comment.commentable_type=="Todo"
      "https://#{comment.commentable.task.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_people_path(comment.commentable.task.project.url,comment.commentable.task.project)
    else
      "https://#{comment.commentable.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_people_path(comment.commentable.project.url,comment.commentable.project)
    end
  end
  
	def todo_project_index(comment)
		if comment.commentable_type=="Todo"
      "https://#{comment.commentable.task.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(comment.commentable.task.project.url,comment.commentable.task.project)
    else
      "https://#{comment.commentable.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(comment.commentable.project.url,comment.commentable.project)
    end
	end
  
  	def post_project_index(post)
		     "https://#{post.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_people_path(post.project.url,post.project)
       end
       
       def post_index(post)
                "https://#{post.project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(post.project.url,post.project)
       end
       
	
  def comment_link(comment)
    case comment.commentable_type
      when "Todo"
        link_to truncate(comment.commentable.title,180),project_site_url(comment.commentable.task.project)+project_task_todo_path(comment.commentable.task.project.url,comment.commentable.task.project,comment.commentable.task,comment.commentable)
      when "Task"
        link_to truncate(comment.commentable.title,180),project_site_url(comment.commentable.project)+project_task_path(comment.commentable.project.url,comment.commentable.project,comment.commentable)
      when "Post"
        link_to truncate(comment.commentable.title,180),project_site_url(comment.commentable.project)+project_post_path(comment.commentable.project.url,comment.commentable.project,comment.commentable)
    end
  end
  
  def task_project_link(todo)
    if todo.task.project
      project_site_url(todo.task.project)+project_task_todo_path(todo.task.project.url,todo.task.project,todo.task,todo)
    else
      my_tasks_path
    end
  end
end
