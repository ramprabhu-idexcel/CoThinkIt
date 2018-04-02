class ProjectsController < ApplicationController
  layout "base"
  before_filter :login_required, :except=>['join_from_invite']
	before_filter :current_project, :only=>['people', 'invite','edit_user_role','update_user_role','remove_user','online_user_card','new_user_invite','remove_invited_user']
	before_filter :ensure_domain, :except=>['join_from_invite']
	before_filter :online_users, :only=>['index','people','invite','online_user_card']
	before_filter :check_site_address, :only=>['invite','people']
	def new
    @project_owner=ProjectUser.find_by_user_id(current_user.id,:conditions=>['is_owner=?', true])
    get_storage_stats
    basic_values
    @project=Project.new
  end
	
  def index
  #  user_data
		redirect_to "http://#{APP_CONFIG[:site][:name]}/global" and return
  end
  
  def basic_values
    #@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		@projects=current_user.user_projects if current_user
    @other_members=current_user.all_active_members
	end
  
  def create
    @user=current_user
    a=0
    a=params[:project_user].length if params[:project_user] 
    b=0
    if params[:new_member] && params[:new_member].include?(',') 
          array=params[:new_member].split(', ')
          array.each do |mem|
            if !mem.blank? 
            b=b+1
            end
          end
        else
          b=1
     end
    @c=a+b if params[:project_user] || (params[:new_member] && params[:new_member]!="Start typing a name ...") 
    basic_values
    #@proj=current_user.projects
   @proj=ProjectUser.find(:all, :conditions=>['user_id=? AND is_owner=?', current_user.id, true])
    @billing_info=BillingInformation.find_by_user_id(current_user.id)
		if @billing_info
			@plan=Plan.find(@billing_info.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
    if (@proj && (!@plan.no_of_projects.nil? && @proj.count>=@plan.no_of_projects.to_i))
    		render :update do |page|	
            page['account-limit-modal'].show 
          end
    elsif (@c && (!@plan.no_of_users.nil? && @c.to_i>=@plan.no_of_users.to_i))
    		render :update do |page|	
     				 page['account-limit-modal'].show
          end
    else
    errors=[]
    errors<<valid_user_data(params[:user])
    params[:project][:url]=params[:project][:name].strip.downcase.gsub( /\s+/,'-')
    @project=Project.new(params[:project])
		 h = Hash[:user_id=>current_user.id,:status=>true,:is_owner=>true,:role_id=>Role.owner_id, :email=>current_user.email]		 
		@project_user = ProjectUser.new(h)
		@project.project_users << @project_user
    errors.flatten!
    if @project.valid? && (errors.nil? || errors.empty?)
			@user.update_attributes(params[:user])
      @project.save
      if params[:project_user]
        send_invitations(params[:project_user],@project)
      end
      if params[:new_member] && !params[:new_member].nil? && params[:new_member]!="Start typing a name ..."
        @member=[]
        if params[:new_member].include?(',') 
          array=params[:new_member].split(', ')
          array.each do |mem|
            if !mem.blank? 
            @member<<mem
            end
          end
        else
          @member=params[:new_member]
        end
        if params[:new_member]
        @member.each do |new_member|
          if !new_member.blank?
            if new_member.include?(',')
              new_member=new_member.split(',')
              new_member=new_member[1]
            end
            @is_project_user=ProjectUser.find(:last, :conditions=>['email=? AND invitation_code!=? AND project_id=?', new_member, "NULL", @project.id])
            if @is_project_user && !@is_project_user.nil?
              @project_user=@is_project_user
            else
              @project_user= ProjectUser.new(:user_id=>nil, :status=>false,:project_id=>@project.id,:role_id=>Role.team_member_id, :is_owner=>false, :email=>new_member)
              @project_user.make_invite_code
            end
            
          UserMailer.deliver_new_member_invitation(new_member,nil,nil,current_user,@project.name,@project_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
          end
        end
      end
		end
		 site_url="https://#{current_user.site_address}.#{APP_CONFIG[:site][:name]}"
       render :update do |page|
          page.redirect_to site_url+project_dashboard_index_path(@project.url,@project)
       end
    else
      render :update do |page|
        errors=[] if errors.nil?
        errors<< "#{@project.errors.entries[0][1]}" if !@project.errors.entries[0].nil?
        errors<< "#{@project.errors.entries[1][1]}" if !@project.errors.entries[1].nil? && @project.errors.entries[0].nil?
        page.alert errors.join("\n") unless errors.nil? || errors.empty?
			end
    end
  end
end
  def join_from_invite
		
    @project_user=ProjectUser.find_by_invitation_code(params[:invitation_code]) if params[:invitation_code]
		session[:invite_code]=params[:invitation_code]
		
		@project_user.update_attributes(:temp_invite_status=>true)
		if @project_user && !@project_user.user_id.nil?
			@user=User.find(@project_user.user_id)
		elsif @project_user && !@project_user.email.nil?
			@user=User.find_by_email(@project_user.email) 
		end
    if @user && current_user && current_user.id == @user.id
      new_member_invitation    
      if @project_user 
      #  redirect_to "/projects/#{@project_user.project_id}/dashboard"
      else
        redirect_to '/global'
      end 
    elsif @user 
      redirect_to login_path
    else 
      session[:first_name]=@project_user.first_name
      session[:last_name]=@project_user.last_name
      session[:email]=@project_user.email 
      session[:project_name]=@project_user.project.name
      redirect_to invite_signup_path
    end
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
  
	def user_data
#    @projects=current_user.projects
    @tasks=current_user.tasks_in_date(Date.today)
    @todos=current_user.todos_in_date(Date.today)
    @events=current_user.events.group_by{|e| e.due_date.to_date if e.due_date}
  end
	
  def people
    @project_users= @project.active_members
		@proj_user=@project.project_users.all
    @members= @project_users.group_by{|user| user.role.name if user.role}
  end
	
  def invite
    if current_user.not_guest?(params[:project_id])
      user_data
      basic_values
      @current_project=Project.find(params[:project_id])  
    else
      redirect_to project_people_path(@project.url,@project)
    end
  end
	
	 def invite_people
		
		render :update do |page|	
			@other_members=current_user.all_active_members
		 	a=params[:project_user].length if params[:project_user]
			@project=Project.find_by_id(params[:project_id])
			@owner=ProjectUser.find_by_is_owner_and_project_id(true, @project.id)
			bill=BillingInformation.find_by_user_id(@owner.user_id) if @owner && !@owner.nil?
			if !params[:new_member].blank? 
				@user_member=User.find(:first,:conditions=>["concat(first_name,' ',last_name) like ? OR email=?", params[:new_member],params[:new_member]])
				active_project_user=ProjectUser.find_by_user_id_and_status(@user_member.id, true) if @user_member
				if active_project_user.nil?
					page.call "clear_autocomplete"
					if params[:new_member]!="Start typing a name ..."
						page.alert "The user you are inviting is not a member in any shared project. Please invite by adding them below under 'Add New Person." 
					end
			else
					existing_user=ProjectUser.find(:last, :conditions=>['user_id=? AND project_id=?', @user_member.id, @project.id])
					if existing_user && existing_user.status==false
							UserMailer.deliver_invitation(existing_user,current_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])   
					elsif !existing_user
						 @project_user= ProjectUser.create(:user_id=>@user_member.id,:status=>false,:project_id=>@project.id,:role_id=>Role.team_member_id, :is_owner=>false)
					 	 @project_user.make_invite_code
						 UserMailer.deliver_invitation(@project_user,current_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
					end 
					page.redirect_to :back
				end
			end
			if bill && !bill.nil?
				@plan=Plan.find_by_id(bill.plan_id)
			else
				@plan=Plan.find_by_name("Trial")
			end
			@existing_users=@project.project_users
			@existing_users_count=@existing_users.count if @existing_users && !@existing_users.nil?
			@new_users=@existing_users_count.to_i+a.to_i if @existing_users_count
			if  @plan.no_of_users && !@plan.no_of_users.nil? && @existing_users_count && @existing_users_count>@plan.no_of_users
				page.redirect_to :back
				page.alert "Please upgrade your plan on your account page to add another user." 
			elsif @plan.no_of_users && !@plan.no_of_users.nil? && @new_users && @new_users>@plan.no_of_users 
				page.redirect_to :back
				page.alert "Please upgrade your plan on your account page to add another user." 
			else
				if !params[:user] 
					@ex=[]
					@existing_users.each do |existing_user|
					@ex<<"#{existing_user.user_id}"
					@user_deleted=false
					if !params[:project_user] 
						if existing_user.is_owner==false
							existing_user.destroy 
							@user_deleted=true
						end
					end  
					if params[:new_member].blank? && !params[:project_user] && @user_deleted==false
						page.alert "Please choose atleast one person for invite"
					end
				end
				if params[:project_user]
					@del_users=@ex-params[:project_user]
					@del_users.each do |del_user|
						@existing_users.each do |ex_user|
							if ex_user.user_id.to_i==del_user .to_i
								ex_user.destroy if ex_user.is_owner==false
							end
						end
					end
				end
				if params[:project_user]
					params[:project_user].each do |pu|
						existing_user=ProjectUser.find(:last, :conditions=>['user_id=? AND project_id=?', pu, @project.id])
						if existing_user && existing_user.status==false
							UserMailer.deliver_invitation(existing_user,current_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])   
						elsif !existing_user
							@project_user= ProjectUser.create(:user_id=>pu,:status=>false,:project_id=>@project.id,:role_id=>Role.team_member_id, :is_owner=>false)
							@project_user.make_invite_code
							UserMailer.deliver_invitation(@project_user,current_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
						end 
							
						page.redirect_to :back
					end
				end
			end
		end
	end
	end   
	
  def new_user_invite
		@project=Project.find_by_id(params[:project_id])
		@other_members=@project.project_users
		@owner=ProjectUser.find_by_is_owner_and_project_id(true, @project.id)
		bill=BillingInformation.find_by_user_id(@owner.user_id) if @owner && !@owner.nil?
		if bill && !bill.nil? && !bill.plan_id.nil? 
			@plan=Plan.find_by_id(bill.plan_id)
		else
			@plan=Plan.find_by_name("Trial")
		end
		@existing_users_count=@other_members.count.to_i+1
		render :update do |page|	
		if  @plan.no_of_users && !@plan.no_of_users.nil? && @existing_users_count && @existing_users_count>@plan.no_of_users
			page.call "text_reset"
			page.alert "Please upgrade your plan on your account page to add another user." 
		else
		value=params[:user][:email]
		true_value=(value=~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)!=nil
		
     if true_value==true
			@is_user = ProjectUser.find_by_email_and_project_id(params[:user][:email],@project.id) 
			@user= User.find_by_email(params[:user][:email])
			
			if ((!@is_user || @is_user.nil?) && @user)
				@is_user=ProjectUser.find_by_user_id_and_project_id(@user.id, @project.id)
			end
			
					if @user
						@id=@user.id
					else
						@id=nil
					end
					
						if @is_user && @is_user.status==true
							page.alert "A person with this email address has already joined the project." 
							page.call "text_reset"
						elsif @is_user && @is_user.status==false
							page.redirect_to :back
							page.call "text_reset"
							@is_user.update_attributes(:first_name=>params[:user][:first_name], :last_name=>params[:user][:last_name])
							
							UserMailer.deliver_new_member_invitation(params[:user][:email],params[:user][:first_name], params[:user][:last_name],current_user,@project.name,@is_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
							
						else
								if params[:user][:first_name] && params[:user][:last_name] && !params[:user][:email].blank?
								@is_project_user=ProjectUser.find(:last, :conditions=>['email=? AND invitation_code!=? AND project_id=?', params[:user][:email], "NULL", @project.id])
									if @is_project_user && !@is_project_user.nil?
										@project_user=@is_project_user
									else
										@project_user= ProjectUser.new(:user_id=>@id, :status=>false,:project_id=>@project.id,:role_id=>Role.team_member_id, :is_owner=>false, :email=>params[:user][:email], :first_name=>params[:user][:first_name], :last_name=>params[:user][:last_name])
										@project_user.make_invite_code
										
									end
										page.redirect_to :back
										page.call "text_reset"
										UserMailer.deliver_new_member_invitation(params[:user][:email],params[:user][:first_name], params[:user][:last_name],current_user,@project.name,@project_user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])    
							else
									page.alert "Please enter email id"
							end
						end
					#end
					else
						page.alert "Please Enter a valid E-mail id"
					end
					end
					end		
	end	
	 
  def edit_user_role
    @project_user=@project.project_users.find_by_user_id(params[:user_id])
  end
  
  def update_user_role
    @project_user=@project.project_users.find_by_user_id(params[:user_id])
    role=params[:roles][:name].to_i
    @project_user.update_attribute(:role_id,role) if @project_user && role && role>0 && role<4
    @project_users= @project.active_members
    @members=@project.active_members.group_by{|user| user.role.name if user.role}
    render :update do |page|
      page.call "close_control_model"
      page.replace_html "members",:partial=>"members_list"
      page.hide "member_#{params[:user_id]}"
      page.visual_effect :appear, "member_#{params[:user_id]}", :duration => 1
      page.replace_html "members_details",:partial=>"members_details"
    end
  end
  
  def remove_user
    @project_user=@project.project_users.find_by_user_id(params[:user_id])
    @project_user.delete if @project_user
    @project_users= @project.active_members
    @members= @project_users.group_by{|user| user.role.name if user.role}
    render :update do |page|
			page.visual_effect :fade, "member_#{params[:user_id]}", :duration => 1
      page.replace_html "members_details",:partial=>"members_details"
    end
  end
	
	def remove_invited_user
    @project_user=@project.project_users.find(params[:proj_user_id])
    @project_user.delete if @project_user
    @project_users= @project.active_members
    @members= @project_users.group_by{|user| user.role.name if user.role}
    render :update do |page|
      page.visual_effect :fade, "member_invited_#{params[:proj_user_id]}", :duration => 1
      page.replace_html "members_details",:partial=>"members_details"
    end
  end
  
  def online_user_card
    render :update do |page|
      page.replace_html 'online_user', :partial=>'projects/dashboard/online_users'
    end
  end
end
