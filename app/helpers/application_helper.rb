# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #to display the date header in the dashboard page
	def date_header(date)
		time_zone=find_time_zone						
		today = Time.now.gmtime+find_current_zone_difference(time_zone)
		yes = today-1.day
		case date
			when Date.new(today.year,today.month,today.day)
				"Today"
			when Date.new(yes.year,yes.month,yes.day)
				"Yesterday"
		else
			date.strftime("%B %d")
		end
	end
  
	#To diplay the user's name with firstname and second name's initial
	def user_name(user) 
		"#{user.first_name} #{user.last_name.first}."
	end
  
	def more_event_link(event)
		time_zone=find_time_zone
		event.count>10 ? %Q{<div class="see-more" id="#{(event.first.created_at+(find_current_zone_difference(time_zone))).strftime("%d-%m")}"><a href="javascript:display_rem_events('#{(event.first.created_at+(find_current_zone_difference(time_zone))).strftime("%d-%m")}','#{event.count}');"><span class="icon icon-down">#{event.count-10} More</span></a></div>} : ""
	end
  
	#To display the type of the event 
	def event_type(event)
		case event.resource_type
			when "Post"
				%Q{<td class="type post ir"><span>Post</span></td>}
			when "Task"
				%Q{<td class="type task ir"><span>Task</span></td>}
			when "Todo"
				%Q{<td class="type todo ir"><span>To-Do</span></td>}
			when "Comment"
				%Q{<td class="type comment ir"><span>Comment</span></td>}
			when "Attachment"	
				%Q{<td class="type file ir"><span>File</span></td>}
		end
	end
  
	def display_events(event)
				time_zone=find_time_zone
        @event_project=event.project
				if @event_project
        @site_url="https://#{@event_project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
				else
					@site_url="https://#{APP_CONFIG[:site][:name]}"
				end
				case event.resource_type
					when "Comment"
							@title=event.resource_type
							@title="To-Do" if @title=="Todo"
							if event.resource.commentable_type=="Todo"
									@todo=Todo.find(event.resource.commentable_id)
									if @event_project
									@event_link= link_to("Re: #{strip_tags(truncate(@todo.title,180))}",@site_url+"#{project_task_todo_path(@event_project.url,@event_project,@todo.task,@todo)}#addcomment",:title=>"posted #{find_elapsed_time(event.created_at)}")
									else
										@event_link=link_to("Re: #{strip_tags(truncate(@todo.title,180))}","#{@site_url}/show_my_task?id=#{@todo.id}",:title=>"posted #{find_elapsed_time(event.created_at)}")
									end
									if @event_project
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+"#{project_task_todo_path(@event_project.url,@event_project,@todo.task,@todo)}#addcomment",:title=>"posted #{find_elapsed_time(event.created_at)}")
								end
							elsif event.resource.commentable_type=="Task"
									@task=Task.find(event.resource.commentable_id)
									if @event_project
									@event_link= link_to("Re: #{strip_tags(truncate(@task.title,180))}",@site_url+project_task_path(@event_project.url,@event_project,@task),:title=>"posted #{find_elapsed_time(event.created_at)}")
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_task_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
									else
										@event_link=link_to("Re: #{strip_tags(truncate(@task.title,180))}","#{@site_url}/show_my_tasklist?id=#{@task.id}",:title=>"posted #{find_elapsed_time(event.created_at)}")
									end
							else																
								@post=Post.find(event.resource.commentable_id)
									@event_link= link_to("Re: #{strip_tags(truncate(@post.title,180))}",@site_url+project_post_path(@event_project.url,@event_project,@post),:title=>"posted #{find_elapsed_time(event.created_at)}")
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_post_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
								end
								if @event_project
							@user_link=link_to(truncate(display_user_name(event.resource.user),10),@site_url+project_people_path(@event_project.url,@event_project))
							@project_link=link_to(truncate(event.project.name,10),@site_url+project_dashboard_index_path(@event_project.url,@event_project))
							else
								@user_link=link_to(truncate(display_user_name(event.resource.user),10),@site_url+edit_user_path(event.resource.user))
								@project_link=link_to("MyTasks","#{@site_url}/my-tasks")
							end
					when "Attachment"		
							check_bandwidth_usage_mytask_helper(event.project.id)
							@title=event.resource_type
							@title="To-Do" if @title=="Todo"
							if event.resource.attachable_type=="Post"
									@post=Post.find(event.resource.attachable_id)
									@user=User.find(@post.user_id)
									@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;",:title=>"posted #{find_elapsed_time(event.created_at)}")
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_task_path(@event_project.url,@event_project,@post),:title=>"posted #{find_elapsed_time(event.created_at)}")

							elsif  event.resource.attachable_type=="User"								
									@user = event.resource.attachable
									@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;")
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+ project_files_path(@event_project.url,@event_project))
							elsif  event.resource.attachable_type=="Chat"                   
									@chat=Chat.find(event.resource.attachable_id)
									@user = User.find(@chat.user_id)
									@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;")
									@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"), @site_url+project_files_path(@event_project.url,@event_project))
									@user_link=link_to(truncate(display_user_name(@user),10),@site_url+project_people_path(@event_project.url,@event_project))
									
							else	
									@comment=Comment.find(event.resource.attachable_id) if event.resource.attachable_type =="Comment"
									if !@comment.nil?		
											if @comment.commentable_type=="Todo"
													@todo=Todo.find(@comment.commentable_id)
													@comment=Comment.find(event.resource.attachable_id)
													@user=User.find(@comment.user_id)
													@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;",:title=>"posted #{find_elapsed_time(event.created_at)}")
													@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+"#{project_task_todo_path(@event_project.url,@event_project,@todo.task,@todo)}#addcomment",:title=>"posted #{find_elapsed_time(event.created_at)}")
											elsif @comment.commentable_type=="Task"
													@task=Task.find(@comment.commentable_id)
													@comment=Comment.find(event.resource.attachable_id)
													@user=User.find(@comment.user_id)
													@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;",:title=>"posted #{find_elapsed_time(event.created_at)}")
													@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"), @site_url+project_task_path(@event_project.url,@event_project,@comment.commentable),:title=>"posted #{find_elapsed_time(event.created_at)}")
											else
													@post=Post.find(@comment.commentable_id)
													@user=User.find(@comment.user_id)
													@event_link= link_to(truncate(event.resource.filename,180),"#", :onclick=>"download_bandwidth_check_file_common('#{event.resource.id}','#{@status}'); return false;",:title=>"posted #{find_elapsed_time(event.created_at)}")
													@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_post_path(@event_project.url,@event_project,@post),:title=>"posted #{find_elapsed_time(event.created_at)}")
											end
									end	
							end 
							@user_link=link_to(truncate(display_user_name(@user),10),@site_url+project_people_path(event.project.url,event.project))
							@project_link=link_to(truncate(event.project.name,10),@site_url+project_dashboard_index_path(event.project.url,event.project))
					else
					display_values(event)
				end
		end
  
	def display_values(event)
		time_zone=find_time_zone
		@title=event.resource_type
		@title="To-Do" if @title=="Todo"
		if event.resource_type=="Todo"
			if @event_project
			@event_link= link_to(truncate(event.resource.title,180),@site_url+project_task_todo_path(@event_project.url,@event_project,event.resource.task,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
			@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_task_todo_path(@event_project.url, @event_project,event.resource.task,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
		 else
			 		@event_link=link_to(truncate(event.resource.title,180),"#{@site_url}/show_my_task?id=#{event.resource.id}",:title=>"posted #{find_elapsed_time(event.created_at)}")
			end
		elsif event.resource_type=="Task"
			if @event_project
			@event_link= link_to(truncate(event.resource.title,180),@site_url+project_task_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
			@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_task_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
			else
				@event_link=link_to(truncate(event.resource.title,180),"#{@site_url}/show_my_tasklist?id=#{event.resource.id}",:title=>"posted #{find_elapsed_time(event.created_at)}")
			end
		elsif event.resource_type=="Post"
			@event_link= link_to(truncate(event.resource.title,180),@site_url+project_post_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
			@time_link=link_to((event.created_at+(find_current_zone_difference(time_zone))).strftime("%l:%M %p"),@site_url+project_post_path(@event_project.url,@event_project,event.resource),:title=>"posted #{find_elapsed_time(event.created_at)}")
		end
		if @event_project
		@user_link=link_to(truncate(display_user_name(event.resource.user),10),@site_url+project_people_path(@event_project.url,@event_project))
		@project_link=link_to(truncate(event.project.name,10),@site_url+project_dashboard_index_path(@event_project.url,@event_project))
		else
										@user_link=link_to(truncate(display_user_name(event.resource.user),10),@site_url+edit_user_path(event.resource.user))
								@project_link=link_to("MyTasks","#{@site_url}/my-tasks")
		end
	end
  
	#This method is used for the top headers style enable/disable
	def header_style(page_name)
		style = " active "
		style = params[:controller] == page_name ? style : " "
	end

	#This method is used for the top headers style enable/disable for tasks tab only
	def set_header_for_task_tabs
		a = ["projects/tasks","projects/tasks/todos"]
		style = a.include?(params[:controller]) ? "active" : ""
	end	
  
	#To display the elapsed time
	def find_elapsed_time(time)
		diff=Time.now-time
		case diff
			when 0..59
				"#{pluralize(diff.to_i,"second")} ago"
			when 60..3599
				"#{pluralize((diff/60).to_i,"minute")} ago"  
			when 3600..86399
				"#{pluralize((diff/3600).to_i,"hour")} ago" 
		else
			time_zone=find_time_zone
			t=(time+find_current_zone_difference(time_zone)).strftime("%l:%M %p")
		end
	end

	def process_file_uploads(attachable_model)		
		params[:attachment].each do |key, value|
			if value and value != ''
				@attachment = Attachment.new(Hash['uploaded_data' => value])
				@attachment.project_id = @project.id if @project
				attachable_model.attachments << @attachment
			end
		end if params[:attachment]
	end
	
	#displaying the icon of the particular file based on the content type
	def icon(content_type)
		type = content_type.split("/").last
		type=content_type if type.nil?
		
		@flag=0
			if  type.include?("vnd.openxmlformats-officedocument.wordprocessingml.document")  
				@flag=1
			return "/images/doctype_icons/document-msword.png"
			elsif  type.include?("vnd.openxmlformats-officedocument.spreadsheetml.sheet") 	
				@flag=1
			return "/images/doctype_icons/document-vnd.ms-excel.png"
						elsif type.include?("vnd.openxmlformats-officedocument.presentationml.presentation") 
				@flag=1
			return "/images/doctype_icons/document-vnd.ms-powerpoint.png"
		elsif type.include?("jpg") || type.include?("jpeg") || type.include?("png") || type.include?("gif") || type.include?("bmp") || type.include?("tiff") || type.include?("webp") || type.include?("raw") || type.include?("tif")
			# for image formats
			@flag=1
			return "/images/doctype_icons/document-jpeg.png"
			

		elsif type.include?("mp3") || content_type.include?("audio/x-wav") || type.include?("midi") || type.include?("aiff") || type.include?("ogg") || type.include?("flac") || type.include?("wma") || type.include?("aac") || type.include?("m4a") || type.include?("mid")  || type.include?("aif") || type.include?("iff")  || type.include?("m3u")  || type.include?("mpa") || (type.include?("ra") && !type.include?('rar'))  || type.include?("realaudio")  || type.include?("mpegurl") || type.include?("mpeg") || content_type.include?("audio/mp4")
			#for audio formats
			@flag=1
			return "/images/doctype_icons/document-mp3.png"
						elsif type.include?("rtf")  || type.include?("txt")  || type.include?("plain") 
				#for plain text formats
			@flag=1
			return "/images/doctype_icons/document-text.png"
		elsif type.include?("psd")
			#for photoshop format
			@flag=1
			return "/images/doctype_icons/document-photoshop.png"
		elsif type.include?("ai")
			#for ai format
			@flag=1
			
			return "/images/doctype_icons/document-illustrator.png"
		elsif type.include?("7z") || type.include?("deb") || type.include?("gz") || type.include?("pkg") || type.include?("rar") || type.include?("sit") || type.include?("sitx") || type.include?("tar") || type.include?("tar.gz") || type.include?("zip") || type.include?("zipx") || type.include?("dmg") || type.include?("iso") || type.include?("toast") || type.include?("vcd") || type.include?("stuffit")  || type.include?("x-cd-image") 
			#for compressed file formats
				@flag=1
			return "/images/doctype_icons/document-zip.png"
				elsif type.include?("mpeg") || type.include?("3g2") || type.include?("3gp") || type.include?("asf") || type.include?("asx") || type.include?("avi") || type.include?("flv") || type.include?("mov") || type.include?("mp4") || type.include?("mpg") || type.include?("rm") || type.include?("swf") || type.include?("vob") || type.include?("wmv")  || type.include?("quicktime")  || type.include?("x-msvideo")    || type.include?("x-shockwave-flash") 
					#for video formats
				@flag=1
			return "/images/doctype_icons/document-film.png"
				elsif type.include?("asp") || type.include?("cer") || type.include?("csr") || type.include?("css") || type.include?("htm") || type.include?("html") || type.include?("js") || type.include?("jsp") || type.include?("php") || type.include?("rss") || type.include?("xhtml") || type.include?("accdb") || type.include?("db") || type.include?("mdb") || type.include?("pdb")  || type.include?("sql")   || type.include?("javascript") || type.include?("msaccess") || type.include?("x-aportisdoc") || type.include?("x-ole-storage")  || type.include?("x-vhdl") || type.include?("x-ruby")
			@flag=1
			return "/images/doctype_icons/document-code.png"
		end
		default_content_types = APP_CONFIG[:content][:type].split(',') #content types are specified in settings.yml
		if @flag==0
		default_content_types.each do |default_content_type|
			if default_content_type == type
				if File.exists?("#{RAILS_ROOT}/public/images/doctype_icons/document-#{type}.png")
					return "/images/doctype_icons/document-#{type}.png"
				else
					return "/images/doctype_icons/document.png"
				end		
			end
		end
		end
		return "/images/doctype_icons/document.png"
	end
	
	
		def icon_with_file(content_type,filename)
		type = content_type.split("/").last
		type=content_type if type.nil?
	
		@flag=0
			if  type.include?("vnd.openxmlformats-officedocument.wordprocessingml.document")  
				@flag=1
			return "/images/doctype_icons/document-msword.png"
			elsif  type.include?("vnd.openxmlformats-officedocument.spreadsheetml.sheet") 	
				@flag=1
			return "/images/doctype_icons/document-vnd.ms-excel.png"
						elsif type.include?("vnd.openxmlformats-officedocument.presentationml.presentation") 
				@flag=1
			return "/images/doctype_icons/document-vnd.ms-powerpoint.png"
		elsif type.include?("jpg") || type.include?("jpeg") || type.include?("png") || type.include?("gif") || type.include?("bmp") || type.include?("tiff") || type.include?("webp") || type.include?("raw") || type.include?("tif")
			# for image formats
			@flag=1
			return "/images/doctype_icons/document-jpeg.png"
			

		elsif type.include?("mp3") || content_type.include?("audio/x-wav") || type.include?("midi") || type.include?("aiff") || type.include?("ogg") || type.include?("flac") || type.include?("wma") || type.include?("aac") || type.include?("m4a") || type.include?("mid")  || type.include?("aif") || type.include?("iff")  || type.include?("m3u")  || type.include?("mpa") || (type.include?("ra") && !type.include?('rar'))  || type.include?("realaudio")  || type.include?("mpegurl") || content_type.include?("audio/mpeg") || content_type.include?("audio/mp4") || content_type.include?("audio/basic")
			#for audio formats
			@flag=1
			return "/images/doctype_icons/document-mp3.png"
						elsif type.include?("rtf")  || type.include?("txt") 
				#for plain text formats
			@flag=1
			return "/images/doctype_icons/document-text.png"
		elsif type.include?("psd")
			#for photoshop format
			@flag=1
			return "/images/doctype_icons/document-photoshop.png"
		elsif type.include?("ai") && !content_type.include?("text")
			#for ai format
			@flag=1
			
			return "/images/doctype_icons/document-illustrator.png"
		elsif type.include?("7z") || type.include?("deb") || type.include?("gz") || type.include?("pkg") || type.include?("rar") || type.include?("sit") || type.include?("sitx") || type.include?("tar") || type.include?("tar.gz") || type.include?("zip") || type.include?("zipx") || type.include?("dmg") || type.include?("iso") || type.include?("toast") || type.include?("vcd") || type.include?("stuffit")  || type.include?("x-cd-image") 
			#for compressed file formats
				@flag=1
			return "/images/doctype_icons/document-zip.png"
				elsif type.include?("mpeg") || type.include?("3g2") || type.include?("3gp") || type.include?("asf") || type.include?("asx") || type.include?("avi") || type.include?("flv") || type.include?("mov") || type.include?("mp4") || type.include?("mpg") || type.include?("rm") || type.include?("swf") || type.include?("vob") || type.include?("wmv")  || type.include?("quicktime")  || type.include?("x-msvideo")    || type.include?("x-shockwave-flash") 
					#for video formats
				@flag=1
			return "/images/doctype_icons/document-film.png"
				elsif type.include?("asp") || type.include?("cer") || type.include?("csr") || type.include?("css") || type.include?("htm") || type.include?("html") || type.include?("js") || type.include?("jsp") || type.include?("php") || type.include?("rss") || type.include?("xhtml") || type.include?("accdb") || type.include?("db") || type.include?("mdb") || type.include?("pdb")  || type.include?("sql")   || type.include?("javascript") || type.include?("msaccess") || type.include?("x-aportisdoc") || type.include?("x-ole-storage")  || type.include?("x-vhdl") || type.include?("x-ruby")
			@flag=1
			return "/images/doctype_icons/document-code.png"
			else
				@return_url=""
				find_icon_with_filename(filename)
				if @flag==1 
					return @return_url.to_s
				end
		end
		default_content_types = APP_CONFIG[:content][:type].split(',') #content types are specified in settings.yml
		if @flag==0
		default_content_types.each do |default_content_type|
			if default_content_type == type
				if File.exists?("#{RAILS_ROOT}/public/images/doctype_icons/document-#{type}.png")
					return "/images/doctype_icons/document-#{type}.png"
				else
					return "/images/doctype_icons/document.png"
				end		
			end
		end
		end
		return "/images/doctype_icons/document.png"
	end

	def find_icon_with_filename(filename)
		
		file=filename.split('.')
		type=file[file.length-1].to_s
		type=type.downcase
			
		if type.include?("jpg") || type.include?("jpeg") || type.include?("png") || type.include?("gif") || type.include?("bmp") || type.include?("tiff") || type.include?("webp") || type.include?("raw") || type.include?("tif")
			# for image formats
			@flag=1
			@return_url="/images/doctype_icons/document-jpeg.png"
			

		elsif type.include?("mp3") ||type.include?("wav") || type.include?("midi") || type.include?("aiff") || type.include?("ogg") || type.include?("flac") || type.include?("wma") || type.include?("aac") || type.include?("m4a") || type.include?("mid")  || type.include?("aif") || type.include?("iff")  || type.include?("m3u")  || type.include?("mpa") || (type.include?("ra") && !type.include?('rar'))  || type.include?("realaudio")  || type.include?("mpegurl") || type.include?("mpeg") 
			#for audio formats
			@flag=1
			@return_url="/images/doctype_icons/document-mp3.png"
						elsif type.include?("rtf")  || type.include?("txt")  
							
				#for plain text formats
			@flag=1
			@return_url="/images/doctype_icons/document-text.png"
		elsif type.include?("psd")
			#for photoshop format
			@flag=1
			@return_url="/images/doctype_icons/document-photoshop.png"

		elsif type.include?("7z") || type.include?("deb") || type.include?("gz") || type.include?("pkg") || type.include?("rar") || type.include?("sit") || type.include?("sitx") || type.include?("tar") || type.include?("gz") || type.include?("zip") || type.include?("zipx") || type.include?("dmg") || type.include?("iso") || type.include?("toast") || type.include?("vcd") 
			#for compressed file formats
				@flag=1
			@return_url="/images/doctype_icons/document-zip.png"
				elsif type.include?("mpeg") || type.include?("3g2") || type.include?("3gp") || type.include?("asf") || type.include?("asx") || type.include?("avi") || type.include?("flv") || type.include?("mov") || type.include?("mp4") || type.include?("mpg") || type.include?("rm") || type.include?("swf") || type.include?("vob") || type.include?("wmv") 
					#for video formats
				@flag=1
			@return_url="/images/doctype_icons/document-film.png"
				elsif type.include?("asp") || type.include?("cer") || type.include?("csr") || type.include?("css") || type.include?("htm") || type.include?("html") || type.include?("js") || type.include?("jsp") || type.include?("php") || type.include?("rss") || type.include?("xhtml") || type.include?("accdb") || type.include?("db") || type.include?("mdb") || type.include?("pdb")  || type.include?("sql")   || type.include?("javascript") || type.include?("msaccess") || type.include?("x-vhdl") || type.include?("rb") || type.include?("erb")
					
			@flag=1
			@return_url="/images/doctype_icons/document-code.png"
	end
	end
	
	
	def pass_icon_filename(content_type)		
		type = content_type.split("/").last
		default_content_types = APP_CONFIG[:content][:type].split(',') #content types are specified in settings.yml
		default_content_types.each do |default_content_type|
			if default_content_type == type
				if File.exists?("#{RAILS_ROOT}/public/images/doctype_icons/document-#{type}.png")
					return "document-#{type}.png"
				else
					return "document.png"
				end		
			end
		end
		return "document.png"		
	end	
	
	#more link on the post tab
	def more(post)
		"<a href=#{project_post_path(@project.url,@project, post)}>{more}</a>" if post.content.length > 300
	end
	
	#To find
	def find_last_user_comment(post)
		post.comments.last
	end
	
	#displays the single status flag
	def status_display(resource)
		if !resource.status_flag.nil?
			if resource.status == "pending"
			%Q{| <a href='#' class='pending'>Pending</a>}
			elsif resource.status == "rejected"
			%Q{| <a href='#' class='rejected'>Rejected</a>}
			elsif resource.status == "accepted"
			%Q{| <a href='#' class='accepted'>Accepted</a>}
			end
		end
		
	end
	def status_display_search(resource)
		
		if !resource.nil? and !resource.status_flag.nil?
			if resource.status == "pending"
				%Q{ <a href='#' class='status pending'>Pending</a>}
				elsif resource.status == "status rejected"
				%Q{ <a href='#' class='rejected'>Rejected</a>}
				elsif resource.status == "accepted"
				%Q{ <a href='#' class='status accepted'>Accepted</a>}
				else
						%Q{<a href='#' class='status rejected' style="color:grey">	No status</a>}
			end
			else
			%Q{<a href='#' class='status rejected' style="color:grey">	No status</a>}
		end
	end
	
	#status flag style update
	def status_flag_style_update(post, status)
		if post.status == status
			"#{status} selected"
		else
			status
		end
	end
	
	#comment/post history create
	def history_update(resource, action_happened)
		history = HistoryPost.new
		history.user_id = current_user.id
		history.action = action_happened
		@post.history_posts << history
	end	
	
	#To display the recent files for a project
	def recent_files_for_project
		 @posts = @project.posts		 
		 @comments = Comment.find(:all,:conditions => ["project_id=? and commentable_type='Post' and commentable_id IN (?)",@project.id,@posts.map(&:id)]) if !@posts.empty?	
		 attach=[]
		 if !@comments.nil? and !@comments.empty?
			attach<<Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Comment' and attachable_id IN (?)",@project.id,@comments.map(&:id)]) 		
		end	 
		if !@posts.nil? and !@posts.empty?
			attach<<Attachment.find(:all,:conditions => ["project_id=? and attachable_type='Post' and attachable_id IN (?)",@project.id,@posts.map(&:id)]) 		
		end	 
		attach=attach.flatten
		return attach
	end
	
	#To display the recent files for the particular post
	def recent_files_for_post(post)
		 post.attachments.find_all_by_project_id(@project.id, :order => 'created_at desc')
	end
	
	#user profile picture display 
	def show_profile_picture(resource_type)
		if resource_type && resource_type.user && !resource_type.attachments.nil? && resource_type.user.attachments.find_by_project_id(nil)
			resource_type.user.attachments.find_by_project_id(nil).post_thumbnail
		else
			"/images/users/blank.png"
		end
	end
	
	#user profile picture display for current user	
	def show_current_user_picture(user)
		 if user && user.attachments.find_by_project_id(nil)
      user.attachments.find_by_project_id(nil).post_thumbnail
     else
			"/images/users/blank.png"
		end
	end	
	
  def show_user_image(user)
    if user && user.attachments.find_by_project_id(nil)
      user.attachments.find_by_project_id(nil).profile_thumbnail
    else
			"/images/users/blank.png"
		end
  end
	# Display comments details in post listing page.
	def comments_count_display(resource)
		if resource.comments.empty?
			return "No comments"
		elsif 	resource.comments.count == 1
			return "<strong> 1 </strong> comment"
		elsif  resource.comments.count > 1
      return "<strong> #{resource.comments.count} </strong> comments"			
		end	
	end	
	
		def comments_display(comments)
		if comments.empty?
			return "No comments"
		elsif 	comments.count == 1
			return "<strong> 1 </strong> comment"
		elsif  comments.count > 1
      return "<strong> #{comments.count} </strong> comments"			
		end	
	end	
	
	def display_post_time_details_with_year(date)
		time_zone=find_time_zone				
		return !date.nil? ? (date+find_current_zone_difference(time_zone)).strftime("%A, %B %e, %Y") : ""
	end	
	
	def display_time_display(date)
		time_zone=find_time_zone						
		return !date.nil? ? (date+find_current_zone_difference(time_zone)).strftime("%A, %B %e") : ""
	end	
	
	def display_time_display_search_page(date)
		time_zone=find_time_zone						
		return !date.nil? ? (date+find_current_zone_difference(time_zone)).strftime("%B %e") : ""
	end	
	
	def display_month_day_details(date)
		time_zone=find_time_zone				
		return !date.nil? ? (date+find_current_zone_difference(time_zone)).strftime("%B %e") : ""
	end	
	
	def display_attachment_title(file)
		resource = file.attachable			 
		 if file.attachable_type =="Comment"
         return_truncate_string(resource.comment)
		 elsif file.attachable_type == 'Post'
			   return_truncate_string(resource.title)	
     elsif file.attachable_type == 'User'
			 return_truncate_string(file.filename)					 
		 end 		 
	 end
	 

	 
	 def display_file(file,filter)
			time_zone=find_time_zone	 
			if filter.nil? or filter.blank? or filter == "Date and time"	
				if @project and @project.project_status == true and @project.is_completed==false
					@file_link=	 link_to(return_truncated_filename(file.filename),"#", :onclick=>"download_bandwidth_check_file('#{file.id}'); return false;",:class=>"desc")
			 elsif @project and @project.is_completed==true
				 @file_link=	 %Q{<a href="#" class="desc" onclick="completed_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
				else
					@file_link=	 %Q{<a href="#" class="desc" onclick="suspend_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
				 end
			 @date= (file.created_at+find_current_zone_difference(time_zone)).strftime("%l:%M %p") 
		 else
			 if @project and @project.project_status == true and @project.is_completed==false
			 @file_link=	 link_to(return_truncated_filename(file.filename),"#", :onclick=>"download_bandwidth_check_file('#{file.id}'); return false;",:class=>"desc")
			 elsif @project and @project.is_completed==true
				@file_link=	 %Q{<a href="#" class="desc" onclick="completed_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
				else
				 @file_link=	 %Q{<a href="#" class="desc" onclick="suspend_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
				 end
		   @date= (file.created_at+find_current_zone_difference(time_zone)).strftime("%m-%d-%Y, %l:%M %p") 
		 end
	 end

  def display_file_search(file)
    time_zone=find_time_zone	
    project=@project ? @project : file.project
    if project and project.project_status == true and project.is_completed==false
			@file_link=	 link_to(return_truncated_filename(file.filename),"#", :onclick=>"download_bandwidth_check_file('#{file.id}'); return false;",:class=>"desc")
    elsif project and project.is_completed==true
      @file_link=	 %Q{<a href="#" class="desc" onclick="completed_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
    elsif project and !project.project_status 
      @file_link=	 %Q{<a href="#" class="desc" onclick="suspend_alert(); return false">#{return_truncated_filename(file.filename)}</a>}
    else
      @file_link=	 link_to(return_truncated_filename(file.filename),"#", :onclick=>"download_bandwidth_check_file('#{file.id}'); return false;",:class=>"desc")
    end
    @date= (file.created_at+find_current_zone_difference(time_zone)).strftime("%l:%M %p") 
  end
	 
	 
	def return_truncate_string(str) 
		strip_tags(str).length > 36 ?  truncate(strip_tags(str),:ommision =>"...",:length =>35) : strip_tags(str)
  end
	
	def return_truncated_filename(str)
		strip_tags(str).length > 30 ?  truncate(strip_tags(str),:ommision =>"...",:length =>28)+str.split('.').last : strip_tags(str)
		end

	
  def display_attachment_filename(filename)
		 return_truncated_filename(filename)
	end
	 
	def display_user_name_for_file(file)
		resource = file.attachable			 
		if file.attachable_type == "User"
			display_user_name(resource)
		elsif resource	
				display_user_name(resource.user)
		else
        display_user_name(@project.owner) if @project			
		end	
	end	 
  
  # check the delete permission of the command
  def delete_command(command)
    current_user_role = ProjectUser.find_by_user_id_and_project_id(current_user.id, @project.id)
    command_user_role = ProjectUser.find_by_user_id_and_project_id(command.user_id, @project.id)
    return true if current_user.id == command.user_id  
    if !current_user_role.nil? and !command_user_role.nil?
      return true if current_user_role.role.name == "Project Owner"
      return false if current_user_role.role.name == "Guest"
      if current_user_role.role.name == "Team Member"
          return command_user_role.role.name == "Guest" ? true : false
      end  
      if current_user_role.role.name == "Administrator"          
          return (command_user_role.role.name == "Guest" or command_user_role.role.name == "Team Member") ? true : false
      end   
    end 
    return false
  end  
  
  # check the role permission for the project user role update
  def update_project_user_role(edit_user)
    current_user_role = ProjectUser.find_by_user_id_and_project_id(current_user.id, @project.id)
    edit_user_role = ProjectUser.find_by_user_id_and_project_id(edit_user.id, @project.id)
    return false if current_user.id == edit_user.id      
    if !current_user_role.nil? and !edit_user_role.nil?
      return false if current_user_role.role.name== "Guest" or current_user_role.role.name== "Team Member"
      return true if current_user_role.role.name== "Project Owner" 
      if current_user_role.role.name== "Administrator"          
        return (edit_user_role.role.name == "Guest" or edit_user_role.role.name == "Team Member") ? true : false
      end
    end
    return false    
  end  
  
  # check the role permission for the project user role delete / uninvite
  def delete_project_user(delete_user)
    current_user_role = ProjectUser.find_by_user_id_and_project_id(current_user.id, @project.id)
    delete_user_role = ProjectUser.find_by_user_id_and_project_id(delete_user.id, @project.id)
    return true if current_user.id == delete_user.id 
    if !current_user_role.nil? and !delete_user_role.nil?
      return true if current_user_role.role.name == "Project Owner"
      return false if current_user_role.role.name == "Guest"
      if current_user_role.role.name == "Team Member"
          return delete_user_role.role.name == "Guest" ? true : false
      end  
      if current_user_role.role.name == "Administrator"          
          return (delete_user_role.role.name == "Guest" or delete_user_role.role.name == "Team Member") ? true : false
      end       
    end
    return false
  end 
	
	def check_user_for_post_edit(post)
		project_user =ProjectUser.find_by_user_id_and_project_id(current_user.id,post.project.id)
		post_user =ProjectUser.find_by_user_id_and_project_id(post.user_id,post.project.id)
		return true if project_user.id==post_user.id
		if project_user && post_user
			return true if project_user.role.name=="Administrator" || project_user.role.name=="Project Owner"
			return false if project_user.role.name=="Guest"
			if project_user.role.name == "Team Member"
          return post_user.role.name == "Guest" ? true : false
      end  
		else
			return false
		end
	end

	def check_user_for_post_delete(post)
		project_user =ProjectUser.find_by_user_id_and_project_id(current_user.id,post.project.id)
		post_user =ProjectUser.find_by_user_id_and_project_id(post.user_id,post.project.id)
		return true if project_user.id==post_user.id
		if project_user && post_user
			return true if project_user.role.name=="Project Owner"
			return false if project_user.role.name=="Guest"
			if project_user.role.name == "Team Member"
          return post_user.role.name == "Guest" ? true : false
			end  
			if project_user.role.name=="Administrator"
				return post_user.role.name !="Administrator" && post_user.role.name !="Project Owner" ? true : false
			end
		else
			return false
		end
	end

  # check the role permission for invite guest functionality ,add todo, edit todo, add task,add post
  def check_role_for_guest
    current_user_role = ProjectUser.find_by_user_id_and_project_id(current_user.id, @project.id)
    return (!current_user_role.nil? and !current_user_role.role.nil? and current_user_role.role.name != "Guest") ? true : false
  end 

	def check_status_project(project=nil)
		 @project = project if !project.nil?
		 
		 if @project and @project.project_status == true
			 return true 
		else
				return false
		end
	end
	
		def check_completed_project(project=nil)
		 @project = project if !project.nil?
		 if @project and @project.is_completed == false
			 return true 
		else
				return false
		end
	end


	def check_status_global_project_for_task(task)		
    project =	Project.find_by_id(task.project.id)
		if project and project.project_status == true
			return true 
		else
				return false
		end	
	end
	
	def check_status_global_project_for_todo(todo)		
    project =	Project.find_by_id(todo.task.project.id)
		if project and project.project_status == true
			return true 
		else
				return false
		end	
	end
	
	def find_current_zone_date(zone = nil)
	time= (zone.nil?) ? find_time_zone.split('(GMT') : zone.split('(GMT')
		time=time.to_s
		if time.include?('GMT ')
			time=time.split('GMT ')
			time=time[1]
		end
		time=time.split(':')
		current_date=Time.now.gmtime
		current_date=current_date+(time[0].to_f*60*60 + time[1].to_f*60)
		current_date
  end		

	def find_current_zone_difference(zone)		
		if zone
		time=zone.split('(GMT')
		time=time.to_s
		if time.include?('GMT ')
			time=time.split('GMT ')
			time=time[1]
		end
		time=time.split(':')
		seconds=time[0].to_f*60*60 + time[1].to_f*60
		else
		seconds =0
		end
	end		
	
	def find_time_zone
		if current_user 
			time_zone=current_user.time_zone.split(')')[0]		
	 	 end
	end
  
  #to display the select tag in role changing
  def role_select_tag
   u=current_user.project_users.find_by_project_id(@project.id)	 
	 if update_project_user_role(@user)
    case u.role.name
      when "Project Owner"
        select("roles", "name", Role.find_value(["Project Owner"]).collect {|r| [ r.name, r.id ]}, {:selected => @project_user.role_id})          
      when "Administrator"
        select("roles", "name", Role.find_value(["Project Owner","Administrator"]).collect {|r| [ r.name, r.id ]}, {:selected => @project_user.role_id})      
			end
	 else
    case u.role.name
      when "Project Owner"
        select("roles", "name", Role.find_value(["Project Owner"]).collect {|r| [ r.name, r.id ]}, {:selected => @project_user.role_id},{:disabled => true})          
      when "Administrator"
        select("roles", "name", Role.find_value(["Project Owner","Administrator"]).collect {|r| [ r.name, r.id ]}, {:selected => @project_user.role_id},{:disabled => true})      	      
			end		 
   end		 
  end
  
  def display_local_time(user)
    if user.time_zone
      display_time=Time.now.gmtime+find_current_zone_difference(user.time_zone)
      display_time.strftime("%l:%M %p")
    else
      "x"
    end
  end
	
	def return_truncate_string_for_search_page(str) 
		strip_tags(str).length > 60 ?  truncate(strip_tags(str),:ommision =>"...",:length =>60) : strip_tags(str)
  end	
	
	def return_truncate_string_for_side_bar_details(str) 
		strip_tags(str).length > 25 ?  truncate(strip_tags(str),:ommision =>"...",:length =>25) : strip_tags(str)
  end		
	
	def list_current_user_projects
    #@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		@projects=current_user.projects.all(:conditions=>['status=?', true],:select => "distinct projects.*", :order=>"name") if current_user
	end		
	
	def check_user_role_for_task(task)		
    project_user =	ProjectUser.find_by_user_id_and_project_id(current_user.id,task.project.id)
		if project_user 
			(!project_user.role.nil? and project_user.role.name != "Guest") ? true : false
		else
			false
    end			
	end
	
	def check_user_role_for_todo(todo)		
    project_user =	ProjectUser.find_by_user_id_and_project_id(current_user.id,todo.task.project.id)
		if project_user 
			(!project_user.role.nil? and project_user.role.name != "Guest") ? true : false
		else
			false
    end			
	end
	
	def return_month_name(number)
		Date::MONTHNAMES[number]
	end	
	
	def display_date_format(date)
		date.strftime("%B %e, %Y")
	end	

  def plan_class(count,index)
    case index
      when 0 
        "alt"
      when 2
        "alt"
      when count-1
        @beta_plan ? "alt" : "alt last-row"
      else
        ""
    end
  end
  
  def upgrade_link(plan)
    link=%Q{javascript:upgrade('#{!current_user.billing_information.nil?}','#{plan.id}','#{current_user.allowed_to_changeplan?(plan.id)}','#{@current_plan_id}');}
    if current_user.billing_information && current_user.billing_information.plan_id
      case current_user.billing_information.plan_id<=>plan.id
        when 1
          link_to("Upgrade",link)
        when 0
          "-"
        when -1
          link_to("Downgrade",link)
      end
    else
      plan.name=="Trial" ? "-" : link_to("Upgrade",link)
    end
  end
  
  def current_plan_class(plan,index)
    (current_user.billing_information && current_user.billing_information.plan_id==plan.id) || ((!current_user.billing_information || current_user.billing_information.plan_id.nil?) && index==4)  ? "selected" : ""
  end
	

	def return_truncate_string_in_view_page(str,chr) 
		strip_tags(str).length > chr ?  truncate(strip_tags(str),:ommision =>"...",:length =>chr) : strip_tags(str)
  end		 
	
	def return_without_striptag_in_view_page(str,chr) 
		str.length > chr ?  truncate(str,:ommision =>"...",:length =>chr) : str
  end		 


	def display_user_name(user)
		if user
			"#{user.first_name.capitalize} #{user.last_name.first.capitalize}."
		end
	end
  
  def file_time
    current_user.user_time(Time.now).strftime("%m%d%y-%H%M").strip
  end
  
  def display_chatlog_link
    link_to "more...","javascript:more_chat_log()",:class=>"more-link" if @dates.count>4
  end
	
	def find_attachment_content_type(attachment)
		attachment.content_type.split("/").first
	end
	

  def plan_changed
    if @current_plan_id
    @current_plan_id > @plan.id ? "Upgraded" : "Downgraded"
    else
      "Upgraded"
    end
  end

		def update_plan_limits
		@plan_limits=PlanLimits.find_by_user_id(current_user.id)
		#@plan=Plan.find(@billing_info.plan_id)
		storage=@plan.storage
		bandwidth=@plan.transfer
		if storage.include?('GB')
			storage=storage.split('GB')
			storage=storage[0].to_i
			storage=storage*1024
		else
			storage=storage.split('GB')
			storage=storage[0].to_i
		end
		if bandwidth.include?('GB')
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
			bandwidth=bandwidth*1024
		else
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
		end
		if @plan_limits && !@plan_limits.nil?
			@plan_limits.update_attributes(:max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		else
			@plan_limits=PlanLimits.create(:user_id=>current_user.id, :max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		end
	end
  
  def update_plan_limits_admin(user)
		@plan_limits=PlanLimits.find_by_user_id(user.id)
		#@plan=Plan.find(@billing_info.plan_id)
		storage=@plan.storage
		bandwidth=@plan.transfer
		if storage.include?('GB')
			storage=storage.split('GB')
			storage=storage[0].to_i
			storage=storage*1024
		else
			storage=storage.split('GB')
			storage=storage[0].to_i
		end
		if bandwidth.include?('GB')
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
			bandwidth=bandwidth*1024
		else
			bandwidth=bandwidth.split('GB')
			bandwidth=bandwidth[0].to_i
		end
		if @plan_limits && !@plan_limits.nil?
			@plan_limits.update_attributes(:max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		else
			@plan_limits=PlanLimits.create(:user_id=>user.id, :max_storage_in_MB=>storage, :max_bandwidth_in_MB=>bandwidth)
		end
	end
  
  def path_global
    "https://#{APP_CONFIG[:site][:name]}/global"
  end
	
	def path_for_search_comment_details(comment)		
			case comment.commentable_type
			when "Post"
			  project_post_path(comment.project.url,comment.project,comment.commentable)
      when  "Todo"
			  project_task_todo_path(comment.project.url,comment.project,comment.commentable.task,comment.commentable)
      when  "Task"
			  project_task_path(comment.project.url,comment.project,comment.commentable)
      end			

	end	
	
		
def title(cn,an)

	@project = Project.find_by_id(params[:project_id])		
	render :text=>"Project id #{params[:project_id]} is not available" if @project.nil?
	@user=current_user if current_user
	if cn=="sessions" && (an=="new") 
		return "Cothinkit - Login"
		
	elsif cn=="posts" && (an=="new") 
		return " Cothinkit - #{modified_captialize_call(@project.name)} - Create Post"
	elsif cn=="posts" && (an=="edit_post") 
		return " Cothinkit - #{modified_captialize_call(@project.name)} - Edit Post"		
	elsif cn=="comments" && (an=="edit_comment") 
		return " Cothinkit - #{modified_captialize_call(@project.name)} - Update Post"		
	elsif cn=="todos" && (an=="edit_todo_comment") 
		return " Cothinkit - #{modified_captialize_call(@project.name)} - Todo"			
	elsif cn=="tasks" && (an=="edit_task_comment") 
		return " Cothinkit - #{modified_captialize_call(@project.name)} - Task"				
	elsif cn=="my_tasks" && (an=="index") 
		return " Cothinkit - #{@user.user_name} - MyTasks"				
	elsif cn=="my_tasks" && (an=="show_my_tasklist") 
		return " Cothinkit - #{@user.user_name} - MyTasks"			
	elsif cn=="my_tasks" && (an=="edit_mytasklist_comment") 
		return " Cothinkit - #{@user.user_name} - Edit - MyTasks"				
	elsif cn=="my_tasks" && (an=="show_my_task") 
		return " Cothinkit - #{@user.user_name} - MyTasks"			
	elsif cn=="my_tasks" && (an=="edit_mytask_comment") 
		return " Cothinkit - #{@user.user_name} - Edit - MyTasks"	
			
	elsif cn=="users" 
		if an=="account"
			return "Cothinkit - Account"
		elsif an=="forgot"
			return "Cothinkit - Forgot Password?"
		elsif an == "new"
			return "Cothinkit - Signup"
		elsif an=="edit"
			return "Cothinkit - #{@user.user_name} - Profile"
    elsif an=="resend_activation"
      return "Cothinkit - Activation Email"
		elsif an=="edit_user_role"
			if @project
				return "Cothinkit - #{modified_captialize_call(@project.name)} - Edit User Role"			
			else
				return "Cothinkit -  Edit User Role"			
			end	
			elsif an=="reset_password"
				return "Cothinkit - Set New Password"
			elsif an=="invite_signup"
				return "Cothinkit - Invite Signup"
			
		end
			
	elsif cn=="footer" 
		if an=="faq"
			return "Cothinkit - FAQ"
		elsif an=="terms"
			return "Cothinkit - Terms of Use"
		elsif an=="privacy"
			return "Cothinkit - Privacy Policy"
		end
		
	elsif an=="index" 
		if cn=="tasks" 
			return "Cothinkit - #{modified_captialize_call(@project.name)} - Tasks & To-Dos"
		elsif cn=="posts" 
			return "Cothinkit - #{modified_captialize_call(@project.name)} - Posts"
		elsif cn=="files" 
			return "Cothinkit - #{modified_captialize_call(@project.name)} - Files"
		elsif cn=="chat" 
			return "Cothinkit - #{modified_captialize_call(@project.name)} -chat"
		elsif cn=="search"
			if @project
				return "Cothinkit - #{modified_captialize_call(@project.name)} -Search"
			else
				return "Cothinkit - Search"
			end	
		elsif cn=="dashboard"
			return "Cothinkit - #{modified_captialize_call(@project.name)} - Dashboard"

		elsif cn == "home"
			return "Cothinkit - Homepage"
		end
		
		elsif an=="show"
			if cn=="tasks"
				return 	"Cothinkit - #{modified_captialize_call(@project.name)} - Task"
			elsif cn=="posts"
				return "Cothinkit - #{modified_captialize_call(@project.name)} - Post"
			elsif cn=="todos"
				return "Cothinkit - #{modified_captialize_call(@project.name)} - To-Do"
			end
				
	elsif cn=="home" && an=="global_dashboard"
			return "Cothinkit - Global Dashboard"
			elsif cn=="home" && an=="all_projects"
			return "Cothinkit - All Projects"
			elsif cn=="chat" && an=="chat_popout"
						return "Cothinkit - #{modified_captialize_call(@project.name)} -chat"
		
	elsif cn=="projects" 
		if an=="people"
			return "Cothinkit - #{modified_captialize_call(@project.name)} - People & Permissions"
		elsif an=="invite"
			return "Cothinkit - #{modified_captialize_call(@project.name)} - Invite People"
			elsif an=="new"
				return "Cothinkit - Create Project"
		end
	end	
end

  def display_in_gb(value)
    if value.nil? || value.blank?
      "Unlimited"
    else
      if value.include?('GB')
        "#{value.to_i} GB"
      else
        in_gb=value.to_i/1024
        in_gb<1 ? "#{value.to_i} MB" : "#{in_gb} GB"
      end    
    end
  end
  
  def beta_plan_user
    current_user.billing_information && current_user.billing_information.plan_id && current_user.billing_information.plan.name=="Beta"
  end
	
	def modified_captialize_call(s)
		s.first.upcase+s[1..s.length] if !s.nil?
	end		
	
	def show_comment_details_with_sanitize(comment)
		if comment.match(/Apple-style-span/)  or comment.match(/Apple-converted-space/) 
			return Sanitize.clean(comment, Sanitize::Config::BASIC)
		else
      return comment			
		end				
	end
	
  def site_url
    if RAILS_ENV=="development" 
      "https://#{@project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
    else
      if APP_CONFIG[:site][:name] == "staging.cothinkit.com"
        "https://#{@project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
      else
        "https://#{@project.owner.site_address}.#{APP_CONFIG[:site][:name]}"
      end
    end
  end
  
  def find_project_url(project)
    if RAILS_ENV=="development" 
      "https://#{project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(project.url,project)
    else
      if APP_CONFIG[:site][:name] == "staging.cothinkit.com"
        "https://#{project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(project.url,project)
      else
        "https://#{project.owner.site_address}.#{APP_CONFIG[:site][:name]}"+project_dashboard_index_path(project.url,project)
      end
    end
  end  
  
  def upload_profile_image(image)
    unless image.nil?
      @attach=Attachment.new(:uploaded_data=>image) 
      @attach.attachable = current_user
      img=Attachment.find(:first,:conditions=>['attachable_id = ? AND project_id is NULL',current_user.id]) 
      img.destroy if img
      @attach.save
    end
  end
	
	
		def check_bandwidth_usage_mytask_helper(project)
get_owner_projects_mytask_helper(project)
		if @plan_limits.download_bandwidth_in_MB.nil? || @plan_limits.bandwidth_used.nil?
			@bandwidth_in_MB=0
		else
			@bandwidth_in_MB=@plan_limits.download_bandwidth_in_MB + @plan_limits.bandwidth_used
		end
		download_bandwidth_in_MB=@bandwidth_in_MB 
		if !@plan_limits.max_bandwidth_in_MB.nil?
			if download_bandwidth_in_MB <=  @plan_limits.max_bandwidth_in_MB
				@status=true
			else
				@status=false
			end
		else
			@status=true
		end
		
		
		project_owner=ProjectUser.find_by_project_id_and_is_owner(project, true) 
		@user=User.find(project_owner.user_id)
		@bill_info = BillingInformation.find_by_user_id(project_owner.user_id) if project_owner
		if @bill_info && !@bill_info.nil?
			@plan=Plan.find(@bill_info.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
		if @plan && @plan.name!="Beta" && @plan.name !="Genius"
			@next_plan=Plan.find(@plan.id-1) if @plan.id!=1
		end
		if !@next_plan
			@next_plan=Plan.find(:first)
		end
		if !@bill_info.nil? and !@bill_info.plan.nil? and @bill_info.plan.name=="Beta"
			@status = true
		end	

		if current_user.id.to_i==@user.id.to_i
			@is_proj_owner=true
		else
			@is_proj_owner=false
		end

	end
		def get_owner_projects_mytask_helper(project)
	 @project_owner=ProjectUser.find_by_project_id_and_is_owner(project, true)
	 
			@user=User.find_by_id(@project_owner.user_id)
			@all_project_users=ProjectUser.find(:all, :conditions=>['user_id=? AND is_owner=?', @user.id, true])
			@all_projects=[]
			@all_project_users.each do |proj_user|
				@all_projects<<Project.find(proj_user.project_id)
			end
			@plan_limits=PlanLimits.find_by_user_id(@user.id)
			if !@plan_limits || @plan_limits.nil?
				@plan_limits=PlanLimits.new(:user_id=>@user.id, :max_storage_in_MB=>10, :max_bandwidth_in_MB=>50)
				@plan_limits.save
			end
			@all_projects=@all_projects.flatten
		end
  
  def valid_user_data(user)
    @errors=[]
    if user
      @errors<<"Please enter your company, organization, group, or school name." if user[:company] && user[:company].blank?
      if user[:site_address]
        if user[:site_address].blank?
          @errors<<"Please enter a domain name." 
        else
          @errors<<"Improper value entered, special characters are not allowed in domain name." unless user[:site_address].match /^\w+$/i
          @errors<<"Sorry! The domain name you entered is already in use." if !User.find_all_by_site_address(user[:site_address]).empty? ||  %w{www demo cothinkit blog staging}.include?(user[:site_address].downcase)
        end
      end
    end
    @errors
  end
end


