
class HomeController < ApplicationController
	protect_from_forgery  :except=>:check_email_reply_and_save
  include CalendarHelper 
  layout :change_layout
	before_filter :login_required, :except=>['index','not_found','check_email_reply_and_save']
	before_filter :ensure_domain, :except=>['index','check_email_reply_and_save','late_tasks','all_projects']
	before_filter :online_users_on_global, :only=>['global_dashboard','online_user_card']
  before_filter :change_domain,:only=>['index','global_dashboard']
  LATE,IN_PROGRESS,PENDING="Late","In Progress","Not Started"
  
  def index		
		check_current_user_exist
		#~ users_site_address = User.all.collect{|user| user.site_address}
		#~ if current_user			
			#~ redirect_to "http://#{current_user.site_address}.#{APP_CONFIG[:site][:name]}/global_dashboard" and return
		#~ elsif request.env['HTTP_HOST'] == APP_CONFIG[:site][:name]
			#~ #redirect_to "http://#{APP_CONFIG[:site][:name]}/" and return
		#~ else
			#~ if users_site_address.include?(request.env['HTTP_HOST'].split(".").first)
				#~ domain = request.env['HTTP_HOST'].split(".").first
				#~ redirect_to "http://www.#{request.env['HTTP_HOST']}/login"
			#~ else
				#~ redirect_to "http://www.#{APP_CONFIG[:site][:name]}/" and return
			#~ end
		#~ end	
	end
		
	def new
      @projects=current_user.user_projects if current_user
  end
		
  def global_dashboard
		
		@user=current_user
    @time_zone=time_zone_select
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
    user_data
		
    @all_events=current_user.all_events(current_user.id).group_by{|d| (d.created_at+(find_current_zone_difference(time_zone))).to_date}
    @size=@all_events.keys.count
    @date=@all_events.keys[2]
		@progress_projects=current_user.user_pending_projects
		@completed_projects=current_user.user_completed_projects
		dashboard_shortcut
		all_projects
  end  
  
  def next_month
    @global = true
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
    @global = true
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
   
  def user_data
		@global = true
		@projects=current_user.user_projects if current_user
    #@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
    @tasks=[]
    @todos=[]
    @events=[]
    @events_todo=[]
    @find_events=[]
    @find_events_todo=[]
    @projects.each do |project|
      @tasks<<project.tasks.find(:all, :conditions=>['due_date=? AND is_completed=?', @current_date, false])
      @todos<<project.todos.find(:all, :conditions=>['todos.due_date=? AND todos.is_completed=?', @current_date, false])
      @find_events<<project.tasks
      @find_events_todo<<project.todos
    end
    @tasks=@tasks.flatten
    @todos=@todos.flatten
    @events=@find_events.flatten.group_by{|e| e.due_date.to_date if e.due_date && e.is_completed==false}
    @events_todo=@find_events_todo.flatten.group_by{|e| e.due_date.to_date if e.due_date && e.is_completed==false}
   end
  
  def more_history
    @global = true
    current_date=Date.strptime(params[:date], '%Y-%m-%d')
    @date=current_date.yesterday
    @overall_events=current_user.all_events(current_user.id).group_by{|d| d.created_at.to_date}
    @size=@overall_events.count
		@overall_events=@overall_events.keys.sort{|a,b| a<=>b}.reverse
    @all_events=current_user.events_in_date(@date).group_by{|e| e.created_at.to_date}
    while @all_events.empty? do
       @date=@date-1
       @all_events=current_user.events_in_date(@date).group_by{|e| e.created_at.to_date}
      end
    render :update do |page|
      page.insert_html :bottom,"more_history",:partial=>"more_history"
      page.replace_html "more_history_link",:partial=>"more_history_link"
      page.hide 'more_history_link'if @date==@overall_events[@size-1]
    end
  end
  
  def show_event
    @global = true
    @date=Date.strptime(params[:date], '%Y-%m-%d')
    @tasks=current_user.tasks_in_date(@date)
    @todos=current_user.todos_in_date(@date)
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
      page.replace_html "events",:partial=>"events_list"
      page.replace_html "display_date", :text=>"#{@display_date}"
      #~ page.visual_effect(:SlideDown, "events")
    end
  end
  
  def change_layout
    (action_name=="index" || action_name=="not_found") ? "front" : "base"  
  end
  
  def show_date
    @global = true
    @date=Date.strptime(params[:date], '%Y-%m-%d')
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
  @tasks=[]
  @todos=[]
     render :update do |page|
         page.replace_html "display_date", :text=>"#{@display_date}"
         page.replace_html "events",:partial=>"events_list"
         end
  end
    def online_user_card
    render :update do |page|
      page.replace_html 'online_user', :partial=>'online_users_global'
    end
  end
	
	def email_notify
    site_name=APP_CONFIG[:site][:name]
    tokenized_url = TokenizedUrl.find_by_token(params[:token])
		if params[:token] && tokenized_url
      site_name="#{tokenized_url.site_address}.#{site_name}" if tokenized_url.site_address
      redirect_to "http://#{site_name}#{tokenized_url.asssigned_url}"
    else
      redirect_to "http://#{site_name}/global"							
    end			
	end
	
  def complete_profile 
    @user=current_user
    @time_zone=time_zone_select
    @user.attributes=params[:user]
    responds_to_parent do
      render :update do |page|
        if @user.valid?
          upload_profile_image(params[:image]) 
          @user.update_attributes(params[:user])
          page.hide "update-profile-modal"
        else
          errors=@user.errors.first.join("\n")
          page.alert errors
        end  
      end  
    end  
  end
	
	def check_email_reply_and_save
		
		logger.info("IN check_email_reply_and_save")
		logger.info(params[:html])
		
		logger.info("HTML CONTENT")
		
			val =""
			if params[:to]
				to_address = params[:to]
				to_front = to_address.split("@reply.cothinkit.com")
		#		to_l = to_front[0].split("ctzp")
				if to_front[0].match /ctztdo/
					val = "todo"
					todo_id=  to_front[0].split("ctztdo")[1]
				else
					val = "post"
					post_id =  to_front[0].split("ctzp")[1]
				end					
			end	
			logger.info(params[:from])
			if params[:from]
				from = params[:from].split("<")[1]
				logger.info(from)
			  @user=User.find_by_email(from.split(">")[0])
			end
			logger.info(val)
			logger.info(	post_id )
			logger.info(@user.inspect)
			if val == "post" and @user
				 @post=Post.find(post_id)
				 @project=@post.project
				 logger.info(params[:html])
					content1=params[:html].split("Reply ABOVE THIS LINE to add a comment to this message")
					 logger.info(content1)
					content=content1[0]
					content_f = content.split("wrote:")[0]
					content2=content_f.split("On")
					content = content2[0...content2.length-1].join("On")
					if content.include?("gmail_quote")
					content=content.split('<div class="gmail_quote">')[0]
					end
					if content.include?('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')
						content=content.split('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')[1]
						content=content.split("---")
						content = content[0...content.length-1].join("---")
					end
					logger.info "---------------------------------------------------------"	
           logger.info(content)					
					 logger.info "---------------------------------------------------------"
					 if content.count("Apple-style-span") > 0 or content.count("Apple-converted-space") > 0
						 content = Sanitize.clean(content, Sanitize::Config::BASIC)
					 end	 
					@comment=Comment.create(:commentable_id=>@post.id, :commentable_type=>"Post", :comment=>content.to_s, :user_id=>@user.id, :project_id=>@project.id, :status_flag=>false)
						if params[:attachments] && params[:attachments].to_i > 0
							for count in 1..params[:attachments].to_i
									@comment.attachments.create(:uploaded_data => params["attachment#{count}"], :project_id=>@project.id) 
							end	
						end					
				
			elsif val == 	"todo" and @user
				 @todo=Todo.find(todo_id)
				 @project=@todo.task.project
					content1=params[:html].split("Reply ABOVE THIS LINE to add a comment to this message")
					content=content1[0]
					content_f = content.split("wrote:")[0]
					content2=content_f.split("On")	
				  content = content2[0...content2.length-1].join("On")
						if content.include?("gmail_quote")
					content=content.split('<div class="gmail_quote">')[0]
					end
					if content.include?('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')
						content=content.split('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')[1]
						content=content.split("---")
						content = content[0...content.length-1].join("---")
					end
					logger.info "---------------------------------------------------------"	
           logger.info(content)					
					 logger.info "---------------------------------------------------------"
					 if content.count("Apple-style-span") > 0 or content.count("Apple-converted-space") > 0
						 content = Sanitize.clean(content, Sanitize::Config::BASIC)
					 end					 
					@comment=Comment.create(:commentable_id=>@todo.id, :commentable_type=>"Todo", :comment=>content.to_s, :user_id=>@user.id, :project_id=>@project.id, :status_flag=>false)
						if params[:attachments] && params[:attachments].to_i > 0
							for count in 1..params[:attachments].to_i
									@comment.attachments.create(:uploaded_data => params["attachment#{count}"], :project_id=>@project.id) 
							end	
						end									
			end	
      render :text => "success"
	end	
	
  def not_found
    
  end
	
	def file_download_from_email
@attachment=Attachment.find(params[:id])
#render :file =>  "#{RAILS_ROOT}/public"+@attachment.public_filename
download_file(@attachment) if @attachment


	end
	
	def dashboard_shortcut
		@global = true  
		@pending_todos=Todo.global_tasks(user_project_ids,session[:login_time],IN_PROGRESS)
    @pending_todos<<current_user.my_tasks_status(IN_PROGRESS, session[:login_time])
    @pending_todos.flatten!
		@unstarted_todos=Todo.global_tasks(user_project_ids,session[:login_time],PENDING)
    @unstarted_todos<<current_user.my_tasks_status(PENDING, session[:login_time])
    @unstarted_todos.flatten!
		@late_todos=Todo.global_tasks(user_project_ids,session[:login_time],LATE)
    @late_todos<<current_user.my_tasks_status(LATE, session[:login_time])
    @late_todos.flatten!

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
    @todos=Todo.global_tasks(user_project_ids,session[:login_time],LATE)
    @todos<<current_user.my_tasks_status(LATE, session[:login_time])
    @todos=flatten_sort_created_at(@todos)
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def task_in_progress
    @todos=Todo.global_tasks(user_project_ids,session[:login_time],IN_PROGRESS)
    @todos<<current_user.my_tasks_status(IN_PROGRESS, session[:login_time])
    @todos=flatten_sort_created_at(@todos)
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def pending_tasks
    @todos=Todo.global_tasks(user_project_ids,session[:login_time],PENDING)
    @todos<<current_user.my_tasks_status(PENDING, session[:login_time])
    @todos=flatten_sort_created_at(@todos)
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"task_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def user_project_ids
    current_user.user_project_ids
  end
   
  def flatten_sort_created_at(todos)
    todos.flatten!
    todos.sort_by{|item| item.created_at}.reverse!
  end
  
  def new_posts
    @messages=PostsCommentsDisplay.find(:all, :conditions=>['is_post=? and is_post_viewed=? and user_id=?', true, false, current_user.id])
    @projects=current_user.user_projects
		@new_messages=[]
		@messages.each do |message|
      is_record=Post.find(:first, :conditions=>['id=? and project_id IN (?) and created_at>=?', message.post_id, @projects.map(&:id),session[:login_time]])
      if !is_record.nil?
        @new_messages<<is_record
      end
		end
		@new_messages.flatten!
    @posts=@new_messages
    render :update do |page|
      page.replace "dash_shortcuts",:partial=>"post_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def new_comments
    @projects=current_user.user_projects
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
		@new_comments.flatten!
     render :update do |page|
      page.replace "dash_shortcuts",:partial=>"comments_shortcut"
      page.visual_effect :SlideDown, "dash_shortcuts"
    end
  end
  
  def all_projects
		@project_own=ProjectUser.find(:first, :conditions=>['project_id=? AND is_owner=? AND user_id=?', params[:project_id], true, params[:id]]) if params[:project_id]
		@project_own=ProjectUser.find_by_user_id(current_user.id,:conditions=>['is_owner=?', true]) if !params[:project_id]
    get_storage_stats
    @projects=current_user.user_projects
    @completed_projects=current_user.user_completed_projects
    @progress_projects=current_user.projects_in_progress
		@all_completed_projects=current_user.completed_projects
		
  end
end
 
