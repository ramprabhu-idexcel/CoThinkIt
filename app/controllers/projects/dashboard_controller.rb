class Projects::DashboardController < ApplicationController
	layout 'base'
		before_filter :login_required
	before_filter :current_project, :except=>['status_update','change_project_settings']
	before_filter :online_users, :only=>['index','project_settings']
	before_filter :ensure_domain,:except=>['late_tasks']
	before_filter :check_site_address, :only=>['index','project_settings']
	
	def index
		
#		@projects=current_user.projects
	 time_zone=find_time_zone
	 time_zone=time_zone.to_s
	  current_date=find_current_zone_date(time_zone)
		current_time=current_date
		@current_date=current_date.to_date
		user_data
		@year=@current_date.year
    @month=@current_date.month
    @all_events=Event.project_dashboard_events(@project.id).group_by{|d| (d.created_at+(find_current_zone_difference(time_zone))).to_date}
    @size=@all_events.keys.count
    @date=@all_events.keys[2]
		dashboard_shortcut
 	end
  
  def user_data
    @tasks=@project.tasks.find(:all, :conditions=>['due_date=? AND is_completed=?', @current_date, false])
    @todos=@project.todos.find(:all, :conditions=>['todos.due_date=? AND todos.is_completed=?', @current_date, false])
		@events=@project.tasks.group_by{|e| e.due_date.to_date if e.due_date && e.is_completed==false}
		@events_todo=@project.todos.group_by{|e| e.due_date.to_date if e.due_date && e.is_completed==false}
  end
  
	def next_month
		time_zone=find_time_zone
	 current_date=find_current_zone_date(time_zone)
	current_time=current_date
		@current_date=current_date.to_date
    @year=params[:year].to_i
    @month=params[:month].to_i+1
    if @month==13
      @year+=1
      @month=1
    end
    user_data
    render :update do |page|
      page.replace_html "cal",:partial=>"calendar"
    end
  end
  
  def previous_month
		time_zone=find_time_zone
	 current_date=find_current_zone_date(time_zone)
	current_time=current_date
		@current_date=current_date.to_date
		@year=params[:year].to_i
    @month=params[:month].to_i-1
    if @month==0
      @year-=1
      @month=12
    end
    user_data
    render :update do |page|
      page.replace_html "cal",:partial=>"calendar"
    end
  end
	
	  def show_event
    @date=Date.strptime(params[:date], '%Y-%m-%d')
		@all_tasks=@project.tasks
    @all_todos=@project.todos
		@tasks=[]
		@todos=[]
		@all_tasks.each do |task|
			if task.due_date==@date && task.is_completed==false
				@tasks<<task
			end
		end
		@all_todos.each do |todo|
			if !todo.due_date.nil? && todo.due_date==@date && todo.is_completed==false
				@todos<<todo
			end
		end
	  @selected_date=@date.to_date
	time_zone=find_time_zone
		current_date=find_current_zone_date(time_zone)
		current_time=current_date
		@current_date=current_date.to_date
		if @current_date==@selected_date-1
      @display_date="Tomorrow - Tasks & To-Dos"
    elsif @current_date==@selected_date+1
      @display_date="Yesterday - Tasks & To-Dos"
    elsif @current_date==@selected_date
			@display_date="Today - Tasks & To-Dos"
		else
			@date=@selected_date.to_time	
      @display_date="#{@date.strftime("%B")} #{@date.day}, #{@date.strftime("%Y")} - Tasks & To-Dos"
    end
    render :update do |page|
      page.replace_html "events",:partial=>"home/events_list"
      page.replace_html "display_date", :text=>"#{@display_date}"
      #~ page.visual_effect(:SlideDown, "events")
    end
  end
	
	  def more_history_project
		current_date=Date.strptime(params[:date], '%Y-%m-%d')
    @date=current_date.yesterday
		@overall_events=@project.events.group_by{|d| d.created_at.to_date}
		@size=@overall_events.count
		@overall_events=@overall_events.keys.sort{|a,b| a<=>b}.reverse
		@all_events=Event.events_in_date_project(@project.id,@date).group_by{|d| d.created_at.to_date}
		while @all_events.empty? do
       @date=@date-1
       @all_events=current_user.events_in_date(@date).group_by{|e| e.created_at.to_date}
    end
    render :update do |page|
      page.insert_html :bottom,"more_history",:partial=>"home/more_history"
      page.replace_html "more_history_link",:partial=>"more_history_link"
      page.hide 'more_history_link'if @date==@overall_events[@size-1]
    end
  end
	
	def project_settings
		@proj_owner=ProjectUser.find_by_project_id_and_user_id_and_is_owner(@project.id, current_user.id, true)
		if @proj_owner
		check_bandwidth_usage
			@post_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id], :order=>"id desc", :limit=>15) 
		else
			redirect_to "http://#{APP_CONFIG[:site][:name]}/global"
		end
	end
	
	def change_project_settings
		
		@project=Project.find_by_id(params[:id])
		@projectowner=ProjectUser.find_by_user_id_and_project_id_and_is_owner(current_user.id,@project.id,true)
		render :update do |page|
			if @projectowner
				if params[:status]=="inprogress"
					
					
					@project.update_attributes(:is_completed=>false, :project_status=>true, :name=>params[:project_name])
					
				else
					
					@project.update_attributes(:is_completed=>true, :project_status=>false, :name=>params[:project_name])
				end
				page.alert "You have successfully changed the status of the project"
			else
				page.alert "You are not allowed to change the project settings"
			end
			site_url="http://#{@project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
			page.redirect_to site_url+project_dashboard_index_path(@project.url, @project)
		end
	end
	

  def dashboard_shortcut
    @pending_todos=@project.todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "In Progress", false,session[:login_time]])
    @unstarted_todos=@project.todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "Not Started", false,session[:login_time]])
    @late_todos=@project.todos.find(:all, :conditions=>['todos.todo_status=? AND todos.is_completed=? AND todos.created_at>=?', "Late", false,session[:login_time]])		
		@messages=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_post_viewed=? and user_id=?', true, false, current_user.id])
		@new_messages=[]
		@messages.each do |message|
      is_record=Post.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', message.post_id, @projects.map(&:id),session[:login_time]])
      if !is_record.nil?
        @new_messages<<is_record
      end
		end
		@new_messages=@new_messages.flatten
		
		@comments=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_comment_viewed=? and user_id=? and is_task=?', false, false, current_user.id,false])
		@task_comments=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_comment_viewed=? and user_id=? and is_task=?', false, false, current_user.id,true])
		@todo_comments=TodoCommentsDisplay.find(:all, :conditions=>['user_id=? and is_viewed=?', current_user.id, false])
		
		@new_comments=[]
		@comments.each do |message|
				is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', message.comment_id, @projects.map(&:id),session[:login_time]])
				if !is_record.nil?
					@new_comments<<is_record
				end
		end
		
		@todo_comments.each do |comment|
			is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', comment.comment_id, @projects.map(&:id),session[:login_time]])
			if !is_record.nil?
					@new_comments<<is_record
			end
		end
		
		@task_comments.each do |comment|
			is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', comment.comment_id, @projects.map(&:id),session[:login_time]])
			if !is_record.nil?
					@new_comments<<is_record
				end
		end

		@new_comments=@new_comments.flatten
  end
  
  def late_tasks
    @todos=@project.late_tasks(session[:login_time])
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect(:SlideDown, "dash_shortcuts")
    end
  end
  
  def task_in_progress
    @todos=@project.task_in_progress(session[:login_time])
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def pending_tasks
    @todos=@project.pending_tasks(session[:login_time])
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def new_posts
    @messages=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_post_viewed=? and user_id=?', true, false, current_user.id])
		@new_messages=[]
		@messages.each do |message|
      is_record=Post.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', message.post_id, [@project.id],session[:login_time]])
      if !is_record.nil?
        @new_messages<<is_record
      end
		end
		@new_messages.flatten!
    @posts=@new_messages
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"/home/post_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def new_comments
   	@comments=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_comment_viewed=? and user_id=? and is_task=?', false, false, current_user.id,false])
		@task_comments=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_comment_viewed=? and user_id=? and is_task=?', false, false, current_user.id,true])
		@todo_comments=TodoCommentsDisplay.find(:all, :conditions=>['user_id=? and is_viewed=?', current_user.id, false])
		@new_comments=[]
		@comments.each do |message|
      is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', message.comment_id, [@project.id],session[:login_time]])
      if !is_record.nil?
        @new_comments<<is_record
      end
		end
		@todo_comments.each do |comment|
			is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', comment.comment_id, [@projects.id],session[:login_time]])
			if !is_record.nil?
        @new_comments<<is_record
			end
		end
		@task_comments.each do |comment|
			is_record=Comment.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', comment.comment_id, [@project.id],session[:login_time]])
			if !is_record.nil?
        @new_comments<<is_record
      end
		end
		@new_comments.flatten!
     render :update do |page|
      page.replace "dash_shortcuts",:partial=>"/home/comments_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
end
