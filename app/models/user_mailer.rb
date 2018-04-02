require 'erb'
class UserMailer < ActionMailer::Base
  include ActionView::Helpers::NumberHelper


  def signup_notification(user,http_user,servername)
		puts "------------------------------------------------"
		setup_email(user,servername)
    #~ @subject    = 'Please activate your new account.'
    @body[:url]  = "http://#{APP_CONFIG[:site][:name]}/activate/#{user.activation_code}"
    @user=user
    @recipient_name=user.first_name.capitalize
    @url="http://#{APP_CONFIG[:site][:name]}/activate/#{user.activation_code}".form_anchor
    @email_template=Admin::EmailTemplate.find_by_key("Signup")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
  
  def activation(user,http_user,servername)
    setup_email(user,servername)
    #~ @subject    = 'Your account has been activated!'
    @body[:url]  = "http://#{http_user}/"
    @email_template=Admin::EmailTemplate.find_by_key("Activation")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
  
	def reset_notification(user,http_user,servername)
		setup_email(user,servername)
		#~ @subject="Link to reset your password."
		#~ @body[:url]  = "http://#{http_user}/reset/#{user.reset_code}"
    @user=user
    @url="http://#{http_user}/resetpassword/#{user.reset_code}"
    @email_template=Admin::EmailTemplate.find_by_key("Reset Password")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
	end
  
  def invitation(recipient,inviter,http_user,servername)
		setup_email(recipient.user,servername)
    #~ @subject="#{recipient.user.first_name}, you've been invited to the #{recipient.project.name} Project on cothinkit by #{inviter.first_name}"
    #~ @body[:inviter_name]=inviter.first_name
    #~ @body[:recipient_name]=recipient.user.first_name
    #~ @body[:project_name]=recipient.project.name
    #~ @body[:url]="http://#{APP_CONFIG[:site][:name]}/invite/#{recipient.invitation_code}"
    @inviter_name=inviter.first_name
    @recipient_name=recipient.user.first_name
    @project_name=recipient.project.name
    @url="http://#{APP_CONFIG[:site][:name]}/invite/#{recipient.invitation_code}".form_anchor
    @email_template=Admin::EmailTemplate.find_by_key("Invitation")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
  
  def new_member_invitation(recipient,firstname, lastname, inviter,project_name,project_user,http_user,servername)
    @recipients  =recipient
    #~ @from        = "admin@cothinkit.com"
    @sent_on     = Time.now
    #@body[:user] = user
    #~ @subject="You've been invited to the #{project_name} Project on co·think·it by #{inviter.first_name}"
    #~ @body[:first_name]=firstname if firstname && !firstname.nil?
    #~ @body[:last_name]=lastname if lastname && !lastname.nil?
    #~ @body[:inviter_name]=inviter.first_name
    #~ @body[:recipient_name]="User"
    #~ @body[:project_name]=project_name
    #~ @body[:url]="http://#{APP_CONFIG[:site][:name]}/invite/#{project_user.invitation_code}"
    @inviter_name=inviter.first_name
    @recipient_name="User"
    @project_name=project_name
    @first_name=firstname if firstname && !firstname.nil?
    @last_name=lastname if lastname && !lastname.nil?
    @url="http://#{APP_CONFIG[:site][:name]}/invite/#{project_user.invitation_code}".form_anchor
    @email_template=Admin::EmailTemplate.find_by_key("New Member Invitation")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
	end
	
	def new_post_notification(post_creater,user,post,project,http_user,servername)
		setup_email(user,servername)      
		#~ @from="#{post.user.first_name} #{post.user.last_name}<notifications@cothinkit.com>"
		#~ @body[:post] = post
    @user=user
    @post=post
    @project_name=project.name
		@reply_to   ="#{post.project.name} <ctzp#{post.id}@#{APP_CONFIG[:postfix_email]}>"
		#~ @subject = "#{project.name}: There's a new post by '#{post_creater}' on '#{post.title}' on co·think·it!"
    #~ @body[:project_name] = project.name
		token = generate_url_token(project_post_path(project.url,project,post),project.id)
    @url="http://#{http_user}/email/#{token}".form_anchor
		@post_creater = post_creater
		@icon=[]
				if post.attachments && !post.attachments.empty?
					post.attachments.each do |attach|
						@icon<<"#{icon_attach(attach.content_type,attach.filename)}"
					end
				end
    @email_template=Admin::EmailTemplate.find_by_key("New Post")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
	end	
  
	def todo_assign_mail(project,todo,current_user,user,http_user,servername)
				setup_email(user,servername)  
				@from="#{todo.user.first_name} #{todo.user.last_name}<notifications@cothinkit.com>"				
				@reply_to   ="#{todo.task.project.name} <ctztdo#{todo.id}@#{APP_CONFIG[:postfix_email]}>"
				@subject = "#{project.name}: You've been assigned a new to-do by #{todo.user.first_name} on co·think·it"
        @user=user
        @project_name=project.name
        @todo=todo
        @todo_first_name=todo.user.first_name
        @todo_last_name=todo.user.last_name
        @creater=todo.user
				token = generate_url_token(project_task_todo_path(project.url,project,todo.task,todo),project.id)
        @url="http://#{http_user}/email/#{token}".form_anchor
        @email_template=Admin::EmailTemplate.find_by_key("Todo Assigned")
        @subject    = eval(@email_template.subject)
        @from=eval(@email_template.from)
        form_mail_content				
	end
	
	def  todo_comment_notify_mail(project,todo,comment,current_user,user,http_user,servername)
				setup_email(user,servername)   
				@reply_to   ="#{todo.todo.task.project.name} <ctztdo#{todo.todo.id}@#{APP_CONFIG[:postfix_email]}>"
				token = generate_url_token(project_task_todo_path(project.url,project,todo.todo.task,todo.todo)+"#comment_"+comment.id.to_s,project.id)
        @todo=todo.todo
        @user=user
        @creater=comment.user
        @creater_first_name=comment.user.first_name
        @creater_last_name=comment.user.last_name
        @project_name=project.name
        @comment=comment
        @icon=[]
        @url="http://#{http_user}/email/#{token}".form_anchor
        if comment.attachments && !comment.attachments.empty?
					comment.attachments.each do |attach|
						@icon<<"#{icon_attach(attach.content_type,attach.filename)}"
					end
				end
        @email_template=Admin::EmailTemplate.find_by_key("Todo Comment")
        @subject    = eval(@email_template.subject)
        @from=eval(@email_template.from)
        form_mail_content			
	end

  def task_comment_notify_mail(project,todo,comment,current_user,user,http_user,servername)
				setup_email(user,servername)
				token = generate_url_token(project_task_path(project.url,project,task)+"#comment_"+comment.id.to_s,project.id)
				        @todo=todo
        @user=user
        @creater=comment.user
        @comment=comment
        @project=project
        @comment=comment
        @icon=[]
        @url="http://#{http_user}/email/#{token}".form_anchor	
        if comment.attachments && !comment.attachments.empty?
					comment.attachments.each do |attach|
						@icon<<"#{icon_attach(attach.content_type,attach.filename)}"
					end
				end
        @email_template=Admin::EmailTemplate.find_by_key("Todo Comment")
        @subject    = eval(@email_template.subject)
        @from=eval(@email_template.from)
        form_mail_content	
	end

  def post_comment_notify_mail(project,post,comment,current_user,user,http_user,servername)
				setup_email(user,servername)   
				@reply_to   ="#{post.project.name} <ctzp#{post.id}@#{APP_CONFIG[:postfix_email]}>"
        @post= post
        @title=post.title
				@creater = comment.user
				@project_name= project.name
				@user= user
				@comment= comment
				token = generate_url_token(project_post_path(project.url,project,post)+"#comment_"+comment.id.to_s,project.id)
				@url = "http://#{http_user}/email/#{token}".form_anchor	
				@icon=[]
				if comment.attachments && !comment.attachments.empty?
					comment.attachments.each do |attach|
						@icon<<"#{icon_attach(attach.content_type,attach.filename)}"
					end
				end
        
        @email_template=Admin::EmailTemplate.find_by_key("Post Comment")
        @subject    = eval(@email_template.subject)
        @from=eval(@email_template.from)
       form_mail_content
	end
	
  def delete_account(user)
    setup_email(user,"")
    #~ @subject="Your co·think·it account and all your projects have been deleted!"
    #~ @body[:first_name]=user.first_name
    @first_name=user.first_name
    @email_template=Admin::EmailTemplate.find_by_key("Close Account")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
	
	 def receive(email)
		if email && email.from && email.from.first
      @to_address=email.to.first.split(APP_CONFIG[:mail_server])
      @to_address=@to_address.to_s
      if @to_address.downcase.include?("ctzp")
        logger.info "I am in cothinkit post option"
				logger.info email.inspect
        post_create_via_email(email)
      elsif @to_address.downcase.include?("ctztdo")
				todo_comment_via_email(email)
	    end
    end
  end 
	
	def post_create_via_email(email)
		post_id=@to_address.gsub(/[a-z]+/, "")
		@user=User.find_by_email(email.from.first)
    @post=Post.find(post_id)
		@project=Project.find(@post.project_id)
		content=email.body.split("Attachment: (unnamed)") if email.body
    content=content.split("Attachment: (unnamed)")


content=content.to_s
content1=content.split("Reply ABOVE THIS LINE to add a comment to this message")

content=content1[0]

content2=content.split("On")
#content=content2[0]
 content = content2[0...content2.length-1].join("On")

logger.info content.inspect

		@comment=Comment.create(:commentable_id=>@post.id, :commentable_type=>"Post", :comment=>content.to_s, :user_id=>@user.id, :project_id=>@project.id, :status_flag=>false)
		if email.has_attachments?
      for attachment in email.attachments 
         @comment.attachments.create(:uploaded_data => attachment, :project_id=>@project.id) 
       end
     end
	 end
	 
	 def todo_comment_via_email(email)
		 todo_id=@to_address.gsub(/[a-z]+/, "")
		@user=User.find_by_email(email.from.first)
    @todo=Todo.find(todo_id)
		logger.info @todo.inspect
		@project=Project.find(@todo.task.project.id)
		logger.info @project.inspect
		content=email.body.split("Attachment: (unnamed)") if email.body
    content=content.split("Attachment: (unnamed)")
		content=content.to_s
content1=content.split("Reply ABOVE THIS LINE to add a comment to this message")

content=content1[0]

content2=content.split("On")
#content=content2[0]
content = content2[0...content2.length-1].join("On")
logger.info content.inspect
		@comment=Comment.create(:commentable_id=>@todo.id, :commentable_type=>"Todo", :comment=>content.to_s, :user_id=>@user.id, :project_id=>@project.id, :status_flag=>false)
		if email.has_attachments?
      for attachment in email.attachments 
         @comment.attachments.create(:uploaded_data => attachment, :project_id=>@project.id) 
       end
     end
	 end
	 
	 def storage_bandwidth_exceed(user,plan,next_plan)
		setup_email(user,"")
    #~ @subject="You're about to exceed your storage or transfer limits of current co·think·it plan!"
    #~ @body[:plan]=plan.name
		#~ @body[:next_plan]=next_plan.name
		#~ @body[:storage_plan]=plan.storage
		#~ @body[:storage_next_plan]=next_plan.storage
		#~ @body[:transfer_plan]=plan.transfer
		#~ @body[:transfer_next_plan]=next_plan.transfer
		#~ @body[:first_name]=user.first_name
    
    @plan=plan.name
    @next_plan=next_plan.name
    @storage_plan=plan.storage
    @storage_next_plan=next_plan.storage
    @transfer_plan=plan.transfer
    @transfer_next_plan=next_plan.transfer
    @first_name=user.first_name
    @email_template=Admin::EmailTemplate.find_by_key("Storage Bandwidth Exceed")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
	end
  
  def plan_changed(plan,user)
    setup_email(user,"")
    #~ @subject="You've Successfully Changed to the #{plan.name} Plan on cothinkit!"
    #~ @body[:first_name]=user.first_name    
    #~ @body[:plan_name]=plan.name
    @plan_name=plan.name
    @first_name=user.first_name
    @email_template=Admin::EmailTemplate.find_by_key("Plan Changed")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
  
  def payment_failed(user)
    setup_email(user,"")
    #~ @subject="Please update your billing information on cothinkit!"
    @body[:first_name]=user.first_name    
    @first_name=user.first_name
    @email_template=Admin::EmailTemplate.find_by_key("Payment Failed")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
  end
	
		# Admin reset mailer
	def reset_notification_admin(admin,http_user,servername)
		setup_adminemail(servername)
		#~ @subject="Link to reset your Temporary Password for Cothinkit. "
		#~ @body[:url]  = "http://#{APP_CONFIG[:site_name]}.com/adminreset/#{admin.reset_code_admin}"
    @url="http://#{APP_CONFIG[:site_name]}.com/adminreset/#{admin.reset_code_admin}".form_anchor
    @email_template=Admin::EmailTemplate.find_by_key("Password Reset Admin")
    @subject    = eval(@email_template.subject)
    @from=eval(@email_template.from)
    form_mail_content
	end
	
		def icon_attach(content_type,filename)
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
			

		elsif type.include?("mp3") || content_type.include?("audio/x-wav") || type.include?("midi") || type.include?("aiff") || type.include?("ogg") || type.include?("flac") || type.include?("wma") || type.include?("aac") || type.include?("m4a") || type.include?("mid")  || type.include?("aif") || type.include?("iff")  || type.include?("m3u")  || type.include?("mpa") || (type.include?("ra") && !type.include?('rar'))  || type.include?("realaudio")  || type.include?("mpegurl") || type.include?("mpeg") || content_type.include?("audio/mp4") || content_type.include?("audio/basic")
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
				find_icon_with_filename_attach(filename)
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

	def find_icon_with_filename_attach(filename)
		
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
	
  def form_mail_content
    @body[:temp]=create_mail_template(@email_template)
		@content_type="text/html"
    @template=set_template
  end
  
  def create_mail_template(email_template)
    ERB.new(email_template.mail_content).result(binding)
  end
   
  def set_template
    "invitation"
  end
	
	def exceed_90percent(user,now_plan,next_plan)
		  @recipients  = "#{user.email}"
      @from        = "admin@cothinkit.com"
      @subject     = "Time to think about upgrading to the #{next_plan.name} Plan on cothinkit!"
      @sent_on     = Time.now
      @body[:user] = user
			@now_plan=now_plan
			@next_plan=next_plan
			if @now_plan.storage.include?("GB")
				@now_storage=@now_plan.storage
			else
				a=@now_plan.storage.split("MB")
				b=a[0].to_i/1024
				@now_storage=b.to_s+"GB"
			end
			puts @now_plan.inspect
			puts @next_plan.inspect
			if @next_plan.storage.include?("GB")
				@next_storage=@next_plan.storage
			else
				a=@next_plan.storage.split("MB")
				b=a[0].to_i/1024
				@next_storage=b.to_s+"GB"
			end
			
			if @now_plan.transfer.include?("GB")
				@now_transfer=@now_plan.transfer
			else
				a=@now_plan.transfer.split("MB")
				b=a[0].to_i/1024
				@now_transfer=b.to_s+"GB"
			end
			if @next_plan.transfer.include?("GB")
				@next_transfer=@next_plan.transfer
			else
				a=@next_plan.transfer.split("MB")
				b=a[0].to_i/1024
				@next_transfer=b.to_s+"GB"
			end
      @plan_limit=PlanLimits.find_by_user_id(user.id)
			@content_type="text/html"
	end
		
	def exceed_100percent(user,now_plan,next_plan)
	  	@recipients  = "#{user.email}"
      @from        = "admin@cothinkit.com"
      @subject     = "You've reached your Plan Limit! Time to upgrade to the #{next_plan.name} Plan on cothinkit!"
      @sent_on     = Time.now
      @body[:user] = user
			@now_plan=now_plan
			@next_plan=next_plan
				if @now_plan.storage.include?("GB")
				@now_storage=@now_plan.storage
			else
				a=@now_plan.storage.split("MB")
				b=a[0].to_i/1024
				@now_storage=b.to_s+"GB"
			end
			if @next_plan.storage.include?("GB")
				@next_storage=@next_plan.storage
			else
				a=@next_plan.storage.split("MB")
				b=a[0].to_i/1024
				@next_storage=b.to_s+"GB"
			end
			
			if @now_plan.transfer.include?("GB")
				@now_transfer=@now_plan.transfer
			else
				a=@now_plan.transfer.split("MB")
				b=a[0].to_i/1024
				@now_transfer=b.to_s+"GB"
			end
			if @next_plan.transfer.include?("GB")
				@next_transfer=@next_plan.transfer
			else
				a=@next_plan.transfer.split("MB")
				b=a[0].to_i/1024
				@next_transfer=b.to_s+"GB"
			end
      @plan_limit=PlanLimits.find_by_user_id(user.id)
      @content_type="text/html"
	end
	
  protected
	
	
	def setup_adminemail(servername)
      @recipients  ="#{APP_CONFIG[:admin_reset_code][:email]}"
      @from        = "admin@cothinkit.com"
      #@subject     = ""
      @sent_on     = Time.now
      #@body[:user] = user
      @content_type="text/html"
    end
		
		

    def setup_email(user,servername)
      @recipients  = "#{user.email}"
      @from        = "admin@cothinkit.com"
      #@subject     = ""
      @sent_on     = Time.now
      @body[:user] = user
      @content_type="text/html"
    end
		
  def generate_url_token(path,project_id)
    token = Digest::SHA1.hexdigest(path)
    TokenizedUrl.create(:token =>token,:asssigned_url=>path,:project_id=>project_id)
    token
  end		
		
end
