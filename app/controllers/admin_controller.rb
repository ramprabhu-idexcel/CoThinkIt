class AdminController < ApplicationController	
  include AdminAuthenticatedSystem
  protect_from_forgery  :except =>[:create,:reset]
	layout "admin", :except=>[:login, :create, :logout, :forgot, :reset]
	   
	def login
		redirect_to summary_path if current_admin
	end
	
	
	def create
	  logout_keeping_session!
    admin = Admin.authenticate(params[:username], params[:password])
    if admin
      self.current_admin = admin
      redirect_to summary_path
      #~ flash[:notice] = "Logged in successfully"
    else
      @login = params[:username]
      flash[:error]="Invalid username/password"
      render :action => 'login'
    end
  end	
	
	def  logout
    logout_killing_session!
    flash[:notice] = "You have been logged out."
		redirect_to '/adminpanel'
	end
	
	def forgot
		 @admin = Admin.first
		 @admin.create_reset_code_admin
			UserMailer.deliver_reset_notification_admin(@admin,request.env['HTTP_HOST'],request.env['SERVER_NAME']) rescue ''
			redirect_to '/adminpanel'
			flash[:notice] = "Reset code sent to admin mail" ##{@admin.email}
	end
	
	
	def reset
		@admin = Admin.find_by_reset_code_admin(params[:reset_code_admin]) unless params[:reset_code_admin].nil?  
			if request.post? 
				if @admin
					if  params[:admin] &&  !params[:admin][:password].blank?
						@admin.password=params[:admin][:password]
            @admin.password_confirmation=params[:admin][:password]
						@admin.delete_reset_code_admin
            @admin.save
						flash[:notice] = "Password reset successfully for admin"  
						redirect_to '/adminpanel'
					else
						flash[:notice] = "Please Enter Password"  
						render :action=> 'reset'
					end
					else
						flash[:notice] = "Reset code already taken"
					redirect_to '/adminpanel'
				end
			end 
		end
		
	
	end
