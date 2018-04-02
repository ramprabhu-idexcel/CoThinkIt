class Projects::ChatController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token
	include Projects::Tasks::TodosHelper
	include Projects::ChatHelper
	include ApplicationHelper
	layout 'base'
  before_filter :current_project,:except=>['subscribe','unsubscribe','online_user_card']
  before_filter :online_users, :only=>['index','message','online_user_card']
	before_filter :check_site_address, :only=>['index']
	
	#~ def index
    #~ @dates=@project.chat_dates
    #~ @recents_chat_files = Attachment.find_all_by_attachable_type_and_project_id('Chat',@project.id,:limit => 5,:order => "id desc")
    #~ today=Date.today.strftime('%Y-%m-%d')
    #~ chat_date=@project.chat_dates
    #~ date= chat_date.first.date_s==today ? chat_date.second : chat_date.first unless chat_date.empty?
    #~ @chats=[]
		#~ if date
      #~ date=date.date_s.to_date
      #~ today=today.to_date
      #~ @date= date==today-1 ? "Yesterday" : date.strftime('%B %d, %Y')
      #~ @chats=@project.chats.find(:all, :conditions=>['Date(created_at)=?',date], :order=>'id desc')
    #~ end
    #~ @today_chats=@project.today_chats
	#~ end
	
  def index
		check_bandwidth_usage		
		time_zone=find_time_zone
  #  @dates=@project.chat_dates
    @recents_chat_files = Attachment.find_all_by_attachable_type_and_project_id('Chat',@project.id,:limit => 5,:order => "id desc")
    today=Date.today.strftime('%Y-%m-%d')
    chat_date=@project.chat_dates
    date= chat_date.first.date_s==today ? chat_date.second : chat_date.first unless chat_date.empty?
    
    his_date = []
		his_d = @project.find_last_four_dates
		his_d.each do |date1|
			his_date <<  date1.date_s.to_date
		end
		
		

     chats = @project.chats.find(:all,:conditions => ['Date(created_at) IN (?)',his_date],:order => "created_at desc").group_by{|d| (d.created_at+(find_current_zone_difference(time_zone))).to_date}
		 chat_his =[]
		 chats.each do |date,event|
			 if chat_his.length <=2
				 len = chat_his.length
				 chat_his[len] = []
				 chat_his[len] = [date,event]
			 else
				 break;
			 end	 
		 end

    today = Time.now.gmtime+find_current_zone_difference(time_zone)
		yesterday = (Time.now-1.day).gmtime+find_current_zone_difference(time_zone)
    if chat_his.empty?
			@today_chats=[]
			@chats=[]
		elsif chat_his.length == 1
			if chat_his[0][0] == today.to_date
        @chats=[]
				@today_chats=chat_his[0][1]
			else
				@today_chats=[]
				@chats = chat_his[0][1]
				@date = (chat_his[0][0] == yesterday.to_date) ? "Yesterday" : chat_his[0][0].strftime('%B %d, %Y')
			end 
		else
			if chat_his[0][0] == today.to_date
				@today_chats=chat_his[0][1]
				@chats = chat_his[1][1]
				@date = (chat_his[1][0] == yesterday.to_date) ? "Yesterday" : chat_his[1][0].strftime('%B %d, %Y')
			else
				@today_chats=[]
				@chats = chat_his[0][1]
				@date = (chat_his[0][0] == yesterday.to_date) ? "Yesterday" : chat_his[0][0].strftime('%B %d, %Y')
			end 
			
		end	
		@dates = @project.chats.find(:all,:conditions => ['Date(created_at) IN (?)',his_date],:order => "created_at desc").group_by{|d| (d.created_at+(find_current_zone_difference(time_zone))).to_date}


	end
  
  def chat_popout
    index 
  end
  
  def subscribe
    #~ send_to_clients ["login", "", "User logged in"]
    render :text => "ok"
  end

  def unsubscribe
    #~ send_to_clients ["logout", "", "User logged out"]
    render :text => "ok"
  end

  def message
		get_owner_projects
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
			
			if (total_storage.nil? || ((total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB > upload_download_bandwidth.to_f)))# || (((total_storage.to_f < used_storage.to_f)  && ( total_bandwidth_in_MB < upload_download_bandwidth.to_f)) && !params[:attachment]))				#Code for sending chat message starts here
				
				@chat=Chat.create(:user_id=>current_user.id,:project_id=>@project.id,:message=>auto_link_urls(params[:message_value]))
				if params[:attachment]
					params[:attachment].each do |key, value|
						if value and !value.blank?
							@attachment = Attachment.new(Hash['uploaded_data' => value])
							@attachment.project_id = @project.id
							@chat.attachments << @attachment
						end
					end 	
          @recents_chat_files = Attachment.find_all_by_attachable_type_and_project_id('Chat',@project.id,:limit => 5,:order => "id desc")
        end
				@project_user=ProjectUser.find(:last, :conditions=>['user_id=? AND project_id=?', current_user.id, @project.id]) if @project
				@project_user.update_attributes(:updated_at=>Time.now.gmtime) if @project_user && @project 
        online_user_header="<div class='box-top'><h4>Online</h4><a class='h-action' href='#{project_people_path(@project.url,@project)}'>Invite</a></div><ul id='online_users' class='online-users'>"
        main_data=["message",current_user.user_name,message_formation(@chat,:main=>true),"#{current_user.id}",current_user.color_code.to_s,Time.now,display_online_users,online_user_header]
        popout_data=["message",current_user.user_name,message_formation(@chat),"#{current_user.id}",current_user.color_code.to_s,Time.now,display_online_users,online_user_header]
			  send_to_clients(main_data,popout_data) 			
        responds_to_parent do	
          render :update do |page|	
            page.replace "file_upload",:partial => "projects/chat/remove_upload_files"   if params[:attachment]
            page.replace "recent_files",:partial=> "recent_files" if params[:attachment] && !params[:pop_out]
            page << "$('chat-msg').clear();"
						page.call "enable_button"
						#~ page.replace_html 'online_user', :partial=>'projects/chat/online_users_on_chat'
					#	page.call "startCounter"	
          end 
        end	
				
				#Code for sending chat message ends here
			else
				#~ @project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
				responds_to_parent do	
          render :update do |page|	
            page['account-limit-modal'].show
            #~ page.replace "file_upload",:partial => "projects/chat/remove_upload_files"  if params[:attachment] 
            #~ page.replace "recent_files",:partial=> "recent_files" if params[:attachment] && !params[:pop_out]
            #~ page << "$('chat-msg').clear();"
            #~ page.call "enable_button"
					end
				end
			end
		end
  end
  
  def display_online_users
    @online_users=ProjectUser.find(:all, :conditions=>['project_id=? AND online_status=? AND updated_at>=?', @project.id, true, Time.now.gmtime-1800]) if @project
     alt,content="",""
    online_users=[]
    @online_users.each do |online| 
      if online.project_id==@project.id 
        if ((Time.now.gmtime-online.updated_at).to_i<20)
           online_users<<["<li class='#{alt} online'><a href='#{project_people_path(@project.url,@project)}'>#{display_user_name(online.user)}</a></li>",online.user_id.to_s]
        else
          online_users<<["<li class='#{alt} idle'><a href='#{project_people_path(@project.url,@project)}'>#{display_user_name(online.user)}</a></li>",online.user_id.to_s]
        end
        alt = (alt=="alt") ? "" : "alt"
      end
    end
      online_users
  end
  
  def message_formation(chat_record,options={})
    chat =""
    chat= chat + "<p>#{chat_record.message}</p>"  if  chat_record.message
    file_att =""
    img_att = ""
    for attachment in chat_record.attachments			  
      attachment_content_type = find_attachment_content_type(attachment)
      if attachment_content_type == "image"				
        img_att= img_att + (options[:main] ? form_image_url(attachment) : form_popout_image_url(attachment))
      else		
        file_att= file_att +  "<li style=\"background-image: url('#{icon_with_file(attachment.content_type,attachment.filename)}');\"> <a href=\"/#{@project.url}/posts/#{@project.id}/download/#{attachment.id}\"  >#{attachment.filename}</a></li>"
				
      end							
    end	 
    chat= chat + '<ul class="file-list">' +file_att+'</ul>'	if !file_att.blank?
    chat= chat  + img_att if !img_att.blank?
    chat
	end	 
  
  def form_image_url(attachment)
		thumbnail=Attachment.find_by_parent_id_and_thumbnail(attachment.id,"big")
		file= (attachment.width>645 && thumbnail )  ? thumbnail : attachment
    if RAILS_ENV=="development"  
      '<a href="'+attachment.public_filename+'" > <img src= "'+file.public_filename+'" class="frame"></a>'			
    else
      "<a href='http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{attachment.filename}'> <img src= 'http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{file.filename}' class='frame'></a>"
    end			
	end	
  
  def form_popout_image_url(attachment)
    if RAILS_ENV=="development"  
      '<a href="'+attachment.public_filename+'" > <img src= "'+attachment.small_thumbnail+'" class="frame"></a>'			
    else
      "<a href='http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{attachment.filename}'> <img src= '#{attachment.small_thumbnail}' class='frame'></a>"
    end	
  end
  
	def download_chat
		#~ @user=current_user
		#~ jid = "#{@user.id}@#{APP_CONFIG[ :xpmm ][ :host ]}"
		#~ password = @user.chat_password.squish
				#~ require 'xmpp4r/muc/helper/mucbrowser'
		#~ client = Jabber::Client.new( jid )
		#~ client.connect
		#~ logger.info password.inspect
		#~ client.auth(password)
		#~ bosh_url = "http://#{APP_CONFIG[ :xpmm ][ :bosh_host ]}#{APP_CONFIG[ :xpmm ][ :bosh_service ]}"
		#~ @session_jid, @session_id, @session_random_id = RubyBOSH.initialize_session( jid, password, bosh_url, { :timeout => 60 } )
			if params[:file_id]
				attachment = Attachment.find_by_id(params[:file_id])
				download_file(attachment) if attachment		
				#~ render :update do |page|	
				
						#page.redirect_to :action => "testing_send_file",:project_id => @project.id
						#~ page.call "start_http_bind"
				#~ end
			else	
				time_zone=find_time_zone
				date1=[]
				date=Date.strptime(params[:date], "%Y-%m-%d")
				date1<<date
				date1<<date-1
				date1<<date+1
				@chats=@project.chats.find(:all,:conditions=>['DATE(created_at) IN (?)',date1], :order=>"created_at desc").group_by{|d| (d.created_at-18000).to_date}
				contents=""
				@chats.each do |date, event|
					if params[:date].to_s==date.to_s
						@download_date=(date).to_date
						contents<<"Chat Log for #{(date).to_date.strftime("%B %e, %Y")}\n\n\n"
						event.each do |chat|
							contents<<"#{chat.user.first_name}:  #{chat.message}\n" if !chat.message.blank?
							if !chat.attachments.empty?
								 contents<< "File(s):"
							chat.attachments.each do |attach|
								 if RAILS_ENV=="development"  
									 contents<<"/public/attachments/#{attach.id.to_s}/#{attach.filename}\n"
									else
								contents<<"#{attach.filename} (http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attach.id.to_s}/#{attach.filename})\n"
							end 
							end
						end
					end
				end 
			end
				@attachment_size=contents.size
				download_bandwidth_calculation
				@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
				
					send_data(contents,:filename=>"Chat #{@download_date.strftime("%m%d%y")}.txt",:type=>"text/plain")
				
			end
		end
		
	def testing_send_file
		attachment = Attachment.last
		send_file "#{RAILS_ROOT}/public"+attachment.public_filename
		
	end	

	def store_message
		@project=Project.find_by_name(params[:project])
		@chat=Chat.new
		@chat.user_id=current_user.id
		@chat.project_id=@project.id
		@chat.message=params[:message]
		@chat.save
		render :nothing=>true
	end
		def file_upload
			
			@user=current_user
			admin    = "#{@user.id}@#{APP_CONFIG[ :xpmm ][ :host ]}"
			# password = APP_CONFIG[ :xpmm ][ :admin_password ]
			jid = "#{@user.id}@#{APP_CONFIG[ :xpmm ][ :host ]}"
			password = @user.chat_password.squish
			
			@project=Project.find(params[:project_id])		
			@chat=Chat.new
			@chat.user_id=current_user.id
			@chat.project_id=@project.id
			@chat.message=params[:userMessage]
			@chat.save
			
			params[:attachment].each do |key, value|
				if value and value != ''
				@attachment = Attachment.new(Hash['uploaded_data' => value])
				@attachment.project_id = @project.id

				@chat.attachments << @attachment

				end
			end if params[:attachment]			
			
			responds_to_parent do	
					render :update do |page|	
						page.replace "file_upload",:partial => "projects/tasks/todos/remove_upload_files"	
					end 
      end					 
			room="#{@project.url.to_s+@project.id.to_s}"
			
			message = Jabber::Message.new

			message.body = message_formation(@chat)
			color = @user.color_code.nil? ? "000000" : @user.color_code 
			message.id = @chat.id.to_s+'#'+color + "$$#{Time.now}"



			require 'xmpp4r/muc/helper/mucclient'
			client = Jabber::Client.new( jid )
			client.connect
			
			client.auth(password)
			#~ client = Jabber::Client.new( Jabber::JID::new( "#{admin}@#{APP_CONFIG[ :xpmm ][ :host ]}" ) )
			#~ client.connect
			#~ client.auth( password )
			client.send( Jabber::Presence.new.set_type( :unavailable ) )

			muc = Jabber::MUC::MUCClient.new( client )
			muc.my_jid = jid
			begin
		
			muc.join( "#{room}@#{APP_CONFIG[ :xpmm ][ :muc_component ]}/#{display_user_name(@user)}" )
			rescue Exception => ex
			# TODO [AN] we have error here is max user limit is reached and therefore admin can't join room
			#render :text => "$('#facebox .upload_file .upload_message').get(0).innerHTML = 'there was an error; try again later'; $('#facebox .upload_file .errorsec').show( );"
					logger.error 'Error: max user limit reached : ' << ex.message
			return
		end
		  
			muc.send( message)

			begin
					client.close
			rescue Exception => ex
					logger.error ex.message
			# Errno::EPIPE (Broken pipe) error on linux dev machine
			end
			

			#render :text => "$('#facebox .upload_file .ok_upload_message').get(0).innerHTML = 'file saved'; $('#facebox .upload_file .ok_message').show( );"

		end


	 
		def new_todo
			@todo = Todo.new			
			assignees_list
			@current_date=find_current_zone_date		
			@year = @current_date.year
			@month = @current_date.month	
      @tasks = @project.tasks.find_all_by_is_completed(false)
	end
	
  def create_todo		
     @todo = Todo.new(params[:todo])
		 @todo.user_id=current_user.id
		 @todo.is_completed = false
		 store_assignee_details(current_user.id)
		 task_detail		 
		 @todo.task_id = @task.id
		 max_position = @task.todos.find(:all,:select => "max(position) as max_position")		 
		 @todo.position =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1		
		 render :update do |page|		 
			 if @todo.save				   				 	 
					 get_todo_details(@task.id)					 					 
           page.alert "Todo added successfully"           
					 page.call "close_control_model"					 					
			#		 send_mail_to_todo_assignee
			 else	 
				#~ for each_error in @todo.errors.entries
					#~ page.replace_html 'todo_title_error',each_error[1] if each_error[0] == "title"
				#~ end				
         page.alert "#{@todo.errors.entries.first[1]}"				
			 end	 
		 end			
   end	
	 
	 	
	  def online_user_card
    render :update do |page|
      page.replace_html 'online_user', :partial=>'projects/chat/online_users_on_chat'
    end
  end
   
  private
	
	def task_detail
		if params[:todo] and params[:todo][:task_id] and params[:todo][:task_id] !="0"
			@task = Task.find_by_id(params[:todo][:task_id])
		else			
      hash = Hash[:user_id => current_user.id,:project_id => @project.id,:is_completed => false,:title => "Unassigned To-Dos"]
			max_position = @project.tasks.find(:all,:select => "max(position) as max_position")
			hash[:position] =  (max_position and max_position[0]) ? max_position[0].max_position.to_i+1  :  1
			@task = Task.create(hash)		
		end	
	end	
  
  def send_to_clients(main_data,pop_out)		
    Socky.send(main_data.collect{|d| (d)}.to_json,:to=>{:channels=>params[:project_id]})
    Socky.send(pop_out.collect{|d| (d)}.to_json,:to=>{:channels=>"pop_out_#{params[:project_id]}"})
    Socky.send(["project_status","project_#{params[:project_id]}"].to_json,:to=>{:channels=>"global"})
  end

end
