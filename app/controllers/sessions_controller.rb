# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
		protect_from_forgery
	before_filter :login_required, :except=>['new','create','global_dashboard']
  before_filter :change_domain,:only=>['new','create']
  include AuthenticatedSystem
  layout 'front'
  
  # render new.erb.html
  def new

		if current_user
			redirect_to "http://#{APP_CONFIG[:site][:name]}/global" and return
		end
	#~ if params[:signup]
#~ #		flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
		#~ end
  end

  def create
		logout_keeping_session!
    user = User.authenticate(params[:session][:email], params[:session][:password])
    self.current_user = user if user && user.status == true && user.activation_code.nil?
    render :update do |page|
			if user && user.activation_code
        page.alert "Please activate your account or request to resend you activation code"
        page.redirect_to resend_activation_path
      else
        if user and user.status == nil
					page.alert("Sorry! The password you entered is incorrect. Please check your spelling and try again")
					elsif user && user.status == false
							page.alert("Your account has been suspended.  Please contact us at support@cothinkit.com")
				else						
					 if user
							if params[:session][:remember_me] == "1"
								current_user.remember_me unless current_user.remember_token?
								cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
							end
							new_cookie_flag = (params[:session][:remember_me] == "1")
							#handle_remember_cookie! new_cookie_flag	
							# new lines added for finding users last login time
							@user_login=User.find(:first, :conditions=>['id = ?', current_user.id])
							if @user_login.last_login_time.nil?
								@user_login.update_attributes(:last_login_time=>Time.now.gmtime)
								session[:login_time]=@user_login.last_login_time
							else
								session[:login_time]=@user_login.last_login_time
								@user_login.update_attributes(:last_login_time=>Time.now.gmtime)
							end
							# new lines added for finding users last login time
              session[:from_login]=true
							page.redirect_to(session[:return_to] || "http://#{APP_CONFIG[:site][:name]}/global")
							session[:return_to]  = nil
						else			
						#redirect_to :controller =>'home', :action=>'global_dashboard'
						#  flash[:notice] = "You logged in successfully"
						# elsif  params[:session][:password].strip.empty? ||  params[:session][:email].strip.empty?
					 if  params[:session][:email] and !params[:session][:password].strip.empty? and !params[:session][:email] .strip.empty?
							email = params[:session][:email]
							if email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
								page.alert("Sorry! The password you entered is incorrect. Please check your spelling and try again")					
							else
								page.alert("Please enter a valid email address")	
							end	
					 else
							page.alert "Please enter your password." if params[:session][:email] &&  params[:session][:password].strip.empty? && !params[:session][:email] .strip.empty?
							page.alert "Please enter your email address \nPlease enter your password" if  params[:session][:password] .strip.empty?  &&  params[:session][:email] .strip.empty?
							page.alert "Please enter your email address." if  params[:session][:password] &&  params[:session][:email] .strip.empty? && !params[:session][:password] .strip.empty?
							#page.alert "Sorry! The password you entered is incorrect." if  !params[:session][:password] .strip.empty?  &&  !params[:session][:email] .strip.empty?
					 end			 
          end			 
		  end
		end
	end
end

  def destroy
	 @project_user=ProjectUser.find(:all, :conditions=>['user_id=?', current_user.id])
	 @project_user.each do |user|
		 user.update_attributes(:online_status=>false)
	 end
    logout_killing_session!
   
#    flash[:notice] = "You have been logged out."
		session[:return_to] =nil
    redirect_back_or_default(APP_CONFIG[:site_url])
  end
	
			def login_calculation

	end
	
protected
  # Track failed login attempts
  def note_failed_signin
		#flash[:error] = "Sorry! The password you entered is incorrect."
    #logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
	
end
