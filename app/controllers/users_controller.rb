require 'csv' 
require 'recurly' 
class UsersController < ApplicationController
	# Be sure to include AuthenticationSystem in Application Controller instead
	include AuthenticatedSystem
	protect_from_forgery
	before_filter :login_required, :except=>['new','create', 'activate','forgot','reset_password','change_layout','recurly_notification','resend_activation','change_password','invite_signup']
	before_filter :change_domain,:only=>['new','create','activate','forgot','reset_password','change_layout','change_password','invite_signup']
	#before_filter :current_project,  :only=>['edit_user_role']
	before_filter :check_site_address, :only=>['edit_user_role']
	layout :change_layout
	protect_from_forgery :except => :recurly_notification


	#ActiveMerchant::Billing::Base.gateway_mode = :test 
	include ActiveMerchant::Billing
	# render new.rhtml
	def new
		#~ if host.count>2
		  #~ redirect_to APP_CONFIG[:site_url]+"/signup"
		#~ else
		  check_current_user_exist
		  @user = User.new
		#~ end
	end
	
	def edit
		if params[:project_id]
			online_users
		else
			online_users_on_global
		end
		@user=User.find_by_id(params[:id]) #if current_user
		@user = current_user
		@projects=current_user.user_projects if current_user
		#@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		time_zone_select		
		@project=Project.find_by_id(params[:project_id]) if params[:project_id]
		params[:project_id] = nil if @project.nil?
		@project_user = ProjectUser.find_by_user_id_and_project_id(@user.id,params[:project_id]) if params[:project_id]
	end
	
	def edit_user_role	
		if params[:project_id]
			online_users
		else
			online_users_on_global
		end
		@user=User.find_by_id(params[:user_id]) #if current_user
		@projects=current_user.user_projects if current_user
		#@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		time_zone_select		
		@project=Project.find(params[:project_id]) if params[:project_id]
		@project_user = ProjectUser.find_by_user_id_and_project_id(@user.id,params[:project_id]) if params[:project_id]	
		render :action => 'edit'
	end	
 
  def create
		logout_keeping_session!
		params[:user][:password_confirmation] = params[:user][:password]
		params[:user][:site_address].downcase! if params[:user][:site_address]
		@user = User.new(params[:user])
		@user.update_attributes(:time_zone=>"(GMT-05:00) Eastern Standard Time")
		success = @user && @user.save
		errors_list = @user.errors.entries  if !success
		render :update do |page|
			if success 
				UserMailer.deliver_signup_notification(@user,request.env['HTTP_HOST'],request.env['SERVER_NAME']) rescue ''
				page.alert "We've sent you an email with your activation link. Please check your inbox."
				page.redirect_to resend_activation_path
			else
				#error = @user.errors.entries.first
				fieldname =[]
				error =[]
				set = 0
				for error_entry in errors_list
					if error_entry[0]=="password" or error_entry[0]=="password_confirmation"
						set =3 if  error_entry[1] == "is too short (minimum is 5 characters)" || error_entry[1]="is too long (maximum is 20 characters)"
						set =1 if error_entry[0]=="password_confirmation"
					else
						if !(fieldname.include?(error_entry[0]))
							error << error_entry[1]
							fieldname << error_entry[0]
						end
					end						 
				end	 
				error << "Please enter password." if set==1
				error << "Please enter a password between five (5) and twenty (20) characters." if set==3

				if fieldname.include?  "site_address" and set!=0
					site_msg = error[-2]
					error[-2] = error[-1] 
					error[-1] = site_msg					 
				end	 
				page.alert(error.join("\n"))
			end	
		end
	end

	def activate
		logout_keeping_session!
		user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
		case
			when (!params[:activation_code].blank?) && user && !user.active?
			user.activate!
			# flash[:notice] = "Signup complete! Please sign in to continue."
			redirect_to "http://#{APP_CONFIG[:site][:name]}/login"
			when params[:activation_code].blank?
			# flash[:error] = "The activation code was missing.  Please follow the URL from your email."
			redirect_back_or_default('/')
			else 
			# flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
			redirect_back_or_default('/')
		end
	end
	
	def forgot
		if request.post?	  
			@user = User.find_by_email(params[:user][:email]) 
			render :update do |page|
				if @user
					#~ chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
					#~ p = ""
					#~ 1.upto(10) { |i| p << chars[rand(chars.size-1)] }
					#~ @user.password=p
					#~ @user.password_confirmation=p
					#~ @user.update_attributes(:password=>@user.password, :password_confirmation=>@user.password_confirmation)
					@user.create_reset_code  
					UserMailer.deliver_reset_notification(@user,request.env['HTTP_HOST'],request.env['SERVER_NAME']) 
					page.alert "We've sent you an email with instructions on how to reset your password. Please check your inbox."
					page.redirect_to "http://#{APP_CONFIG[:site][:name]}/login"
				else
					page.alert "Please enter your email id" if params[:user][:email].empty?
					page.alert "Sorry! We didn't recognize that email address."  if !params[:user][:email].empty?
				end
			end
		end
	end


	def success_or_fail_login
		if (@user.email.nil? || @user.email.blank?) || (@user.confirmed_at.nil?) || (!@user.confirmation_code.nil?)
			redirect_to verify_email_path(@user.id)
		else
			self.current_user =@user
			#flash[:notice] = "Logged in successfully"
			redirect_back_or_default('/')
		end
	end
	
	def resend_activation
		if params[:email] && !params[:email].blank? && request.xhr?
			@user=User.find_by_email(params[:email])
			render :update do |page|
				if @user
					if @user.activation_code
						send_activation_code(@user)
						page.alert "Your new activation code is sent."
					else
						page.alert "Your account is already active."
					end
					page.redirect_to login_path
				else
					page.alert "Sorry, Email you entered is not registered yet."
					page.redirect_to signup_path
				end
			end
		end
	end  

  
	def reset_password
		@user=User.find_by_reset_code(params[:reset_code])
		if @user
			@user.update_attributes(:reset_code => nil)
		else
			redirect_to '/404' and return
		end
	end
  
	def change_password
		@user=User.find_by_id(params[:id])
		if @user && params[:user] && params[:user][:password] && params[:user][:password_confirmation]
			self.current_user = @user
			current_user.password=params[:user][:password]
			current_user.password_confirmation=params[:user][:password_confirmation]
			current_user.save
			render :update do |page|
				page.redirect_to '/global'
			end
		else
			render :update do |page|
				page.alert "password and confirm password did not match"
			end
		end
	end
  
	def invite_signup
	end  

	def update		
		@project = nil	
		@projects=current_user.user_projects if current_user
		#@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		@project=Project.find(params[:project_id]) if !params[:project_id].nil? && params[:project_id].strip != ""
		@user=User.find_by_id(params[:id]) #if current_user
		@project_user = ProjectUser.find_by_user_id_and_project_id(@user.id,params[:project_id]) if !params[:project_id].nil? && params[:project_id].strip != ""		
		if @user and @user.id == current_user.id		
			upload_profile_image(params[:image])
			if !params[:user][:password].blank? 
				@user.step = "1"
				@user.password = params[:user][:password]
				@user.password_confirmation = params[:user][:password]
			end
			@user.update_attributes(params[:user])
			@user.time_zone = params[:time]
			@user.color_code = params[:color_code]
			responds_to_parent do
				render :update do |page|			
					if @user.save
						if @project
							page.redirect_to project_dashboard_index_path(@project.url,@project)
						else	
							page.redirect_to :controller=>'home',:action=>'global_dashboard'
						end
					else
						error = @user.errors.entries.first
						fieldname =[]
						error =[]
						set = 0
						
						for error_entry in @user.errors.entries
							if error_entry[0]=="password" or error_entry[0]=="password_confirmation"
								if  error_entry[1] == "is too short (minimum is 5 characters)"
									page.alert("Please enter a password between five (5) and twenty (20) characters.")	 
									set=0
									break
								end	
							end						
						end
						
					end	
				end	
			end		
		elsif @user			
			@project=Project.find_by_id(params[:project_id])
			if params[:roles]
				role=params[:roles][:name].to_i
				@project_user.update_attribute(:role_id,role) if @project_user && role && role>0 && role<4
			end	
			responds_to_parent do
				render :update do |page|						
					page.redirect_to  project_people_path(@project.url,@project)
				end
			end
		end	
	end
	
	
	def check_user_id
		@project = Project.find_by_id(params[:project_id])
		@project_user=ProjectUser.find_by_user_id_and_project_id(current_user.id,params[:project_id])
		if params[:project_id] and (@project.nil? or @project_user.nil?) #or flag  or @project_name != @project.url
			redirect_to "http://#{APP_CONFIG[:site][:name]}/global"
		end
	end
		
	def account
		@project_owner=ProjectUser.find_by_user_id_and_is_owner(current_user.id, true)
		if @project_owner
			check_bandwidth_usage_mytask
		else
			@status=false
		end 
		check_user_id
		get_storage_stats
		@project_own=ProjectUser.find(:first, :conditions=>['project_id=? AND is_owner=? AND user_id=?', params[:project_id], true, params[:id]]) if params[:project_id]
		@project_own=ProjectUser.find_by_user_id(current_user.id,:conditions=>['is_owner=?', true]) if !params[:project_id]
		@project=Project.find(params[:project_id]) if params[:project_id]
		@next_billing_date=BillingHistory.find(:last, :conditions=>['user_id=?', current_user.id])
		get_owner_projects if @project
		basic_account_details
		@current_plan_id=current_user.billing_information ? current_user.billing_information.plan_id : 0
	end

	def update_account

		basic_account_details

		if @beta_plan
			render :update do |page|
				page.alert "Sorry you cannot change the plan from the Beta plan"
			end
		else
			if current_user.billing_information.nil? && params[:plan_id].blank?
				render :update do |page|
					page.alert "Please select a plan and provide your credit card information."
				end
			else
				if current_user.billing_information && !current_user.billing_information.recurring_profile_id.nil?
					update_billing
				else
					@plan=Plan.find_by_id(params[:plan_id])
					create_billing			
					#if credit_card.valid? 
					#~ if valid_billing_info && pay_first.success? && @response.params['transaction_id'] 
					#~ create_billing
					#~ else
					#~ errors=[]
					#~ @billing_info.errors.entries.each do |e|
					#~ errors<<e[1]
					#~ end
					#~ errors<<  "Sorry, Error in processing. Please try again later." if errors.empty?
					#~ render :update do |page|
					#~ page.alert errors.join("\n")
					#~ end
				end
			#~ else
				#~ render :update do |page|
				#~ page.alert "There was an error processing your billing and credit card information, please check your information and resubmit."
				#~ end
			end
		end      
	end      

	
  def update_billing
    #~ @billing_info=current_user.billing_information
    #~ @plan=current_user.billing_information.plan
    #~ params[:billing_information][:expires]=card_date(params[:date][:year],params[:date][:month])
    #~ @billing_info.attributes=params[:billing_information]
    #~ if credit_card.valid?
      #~ if @billing_info.valid?  
        #~ @billing_info.update_attributes(params[:billing_information])
        #~ update_details
        #~ update_plan_limits
        #~ render :update do |page|
          #~ page.alert "Account Edited"
          #~ page.redirect_to account_path(current_user)
        #~ end
      #~ else
        #~ errors=[]
        #~ @billing_info.errors.entries.each do |e|
          #~ errors<<e[1]
        #~ end
        #~ errors<<  "Sorry, Error in processing. Please try again later." if errors.empty?
        #~ render :update do |page|
          #~ page.alert errors.join("\n")
        #~ end
      #~ end
    #~ else
      #~ render :update do |page|
        #~ page.alert "There was an error processing your billing and credit card information, please check your information and resubmit."
      #~ end
    #~ end
				acct = Recurly::Account.find(current_user.id)
acct.billing_info=Recurly::BillingInfo.create(
      :account_code => acct.account_code,
#:first_name => params[:billing_information][:first_name],
	#				:last_name => params[:billing_information][:last_name],
	#				:address1 => params[:billing_information][:address1],
	#				:address2 => params[:billing_information][:address2],
	#				:city => params[:billing_information][:city],
	#				 :state => 'IL',
				#	 :country => 'US',
		#			:zip => params[:billing_information][:zip_code],
					:credit_card => {
						:number => "#{params[:card]}",
						:year => "#{params[:date][:year]}" ,
						:month => "#{params[:date][:month]}",
						:verification_value => "#{params[:ccv]}"
					},
					:ip_address =>'127.0.0.1' # request.ENV[:remote]
					)
					
			#		puts acct.billing_info.errors.errors["base"].empty?
					 @billing_info=current_user.billing_information
    @plan=current_user.billing_information
    params[:billing_information][:expires]=card_date(params[:date][:year],params[:date][:month])
    @billing_info.attributes=params[:billing_information]
		@billing_info.update_attributes(params[:billing_information])
					 render :update do |page|
						 if acct.billing_info.errors && acct.billing_info.errors.errors && acct.billing_info.errors.errors["base"] && !acct.billing_info.errors.errors["base"].empty?
							 page.alert "There was an error processing your credit card information, please check your information and resubmit."
								
						else
							page.alert "Account Edited" 
						end
						page.redirect_to account_path(current_user)
					end
	
		
	end
  def create_billing
    #~ billing_info
    #~ @billing_info.recurring_profile_id=@response.params['profile_id']
    #~ @billing_info.save
    #~ BillingHistory.create(:user_id=>current_user.id,:plan_name=> @billing_info.plan.name,:amount=> @billing_info.plan.price,:billing_date=>Date.today)
    #~ UserMailer.deliver_plan_changed(@plan,current_user)
    #~ update_plan_limits
    #~ render :update do |page|
      #~ page.alert "You have upgraded your plan to the #{@plan.name} Plan. You will be charged $#{@plan.price} on a monthly basis."
      #~ page.redirect_to account_path(current_user)
    #~ end
		account = Recurly::Account.new(
				:account_code => "#{current_user.id}",
				:first_name => current_user.first_name,
				:last_name => current_user.last_name,
				:email => current_user.email,
				:company_name =>current_user.company)
		
		
		
		account.billing_info = Recurly::BillingInfo.new(
					:first_name => current_user.first_name,
					:last_name => current_user.last_name,
			#		:address1 => params[:billing_information][:address1],
			#		:address2 => params[:billing_information][:address2],
			#		:city => params[:billing_information][:city],
			#		 :state => 'IL',
			#		:country => 'US',
			#		:zip => params[:billing_information][:zip_code],
					:credit_card => {
						:number => "#{params[:card]}",
						:year => "#{params[:date][:year]}" ,
						:month => "#{params[:date][:month]}",
						:verification_value => "#{params[:ccv]}"
					},
					:ip_address =>'127.0.0.1' 
				)	
	#			puts  request.ENV[:remote]
		
				
		subscription = Recurly::Subscription.create(
					:account_code => "#{current_user.id}",
					:plan_code => "#{@plan.name.downcase}", 
					:account => account
				)
				
if subscription.errors && subscription.errors.errors && subscription.errors.errors["base"] && !subscription.errors.errors["base"].empty?
else
	
		    billing_info
 #   @billing_info.recurring_profile_id=@response.params['profile_id']
    @billing_info.save

    update_plan_limits
			
end
						 render :update do |page|
							if subscription.errors && subscription.errors.errors && subscription.errors.errors["base"] && !subscription.errors.errors["base"].empty?
						
							page.alert "There was an error processing your billing and credit card information, please check your information and resubmit."
						else
							page.alert "You have upgraded your plan to the #{@plan.name} Plan. You will be charged $#{@plan.price.to_i} monthly."
			
						end
					  
					#	page.alert "Error" if !@persisted || @persisted==false
      page.redirect_to account_path(current_user)
					end
		
	end
  
	def billing_info
		@billing_info=BillingInformation.new(params[:billing_information])
		@billing_info.expires=card_date(params[:date][:year],params[:date][:month])
		@billing_info.user_id=current_user.id
		@billing_info.plan_id=params[:plan_id]
		@billing_info.recurring_profile_id="true"
	end

	def valid_billing_info
		billing_info
		@billing_info.valid?  
	end
  
	def card_date(year,month)
		year,month=year.to_i,month=month.to_i
		Date.new(year,month)
	end
  
  def change_plan
    basic_account_details
		if (!current_user.billing_information || (current_user.billing_information && current_user.billing_information.nil?))
			render :update do |page|
		    page.show "card_details"
			end
		else
			if @beta_plan
				render :update do |page|
					page.alert "Sorry you cannot change the plan from the Beta plan"
				end
			else
				if current_user.allowed_to_changeplan?(params[:plan_id])
					@current_plan_id=current_user.billing_information.plan_id if current_user.billing_information
					@plan=Plan.find_by_id(params[:plan_id])
					@plan1=Recurly::Plan.find(@plan.name.downcase)
					@billing_info=current_user.billing_information
					#        @plan.price== 0.0 ? suspend_profile : update_pay
					update_pay
					render :update do |page|
						if @resp && @resp==true 
							@billing_info.update_attributes(:plan_id=>@plan.id)
							update_plan_limits
							# UserMailer.deliver_plan_changed(@plan,current_user)
							page.replace_html "plan_details",:partial=>"plan"
							page.alert("You have #{plan_changed} your plan to the #{@plan.name} Plan. You will be charged $#{@plan1.unit_amount_in_cents/100} monthly.")
							page.redirect_to account_path(current_user)
						else
							page.alert "Cannot change the plan temporarily, please try again later"
						end
					end
				else
					render :update do |page|
						page.alert "We are unable to downgrade your plan because your usage exceeds the lower plan's limits." 
					end
				end
				#~ render :update do |page|
					#~ page.show "card_details"
				#~ end
			end
		end
  end
	
	def basic_account_details
		get_storage_stats
		@user=current_user
		#@projects=current_user.projects.all(:conditions=>['project_users.status=? and projects.project_status=?', true,true],:select => "distinct projects.*") if current_user
		@projects=current_user.user_projects if current_user
		@plans=Plan.user_plans
		@billing_info=current_user.billing_information
		plan=Plan.find_by_name "Beta"
		@beta_plan=plan if current_user.billing_information && current_user.billing_information.plan_id==plan.id
	end

	def change_layout
		%W{edit update account update_account edit_user_role}.include?(action_name) ? "base" : "front"  
	end
	
	def download
		attachment = Attachment.find_by_id(params[:id])
		@project=Project.find(attachment.project_id)

		@attachment_size=attachment.size
		download_bandwidth_calculation
		@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)

		download_file(attachment) if attachment
	end	

	def credit_card
		@card ||= ActiveMerchant::Billing::CreditCard.new(
						:number => params[:card],
						:verification_value => params[:ccv],
						:month => params[:date][:month],
						:year => params[:date][:year],
						:first_name =>current_user.first_name,
						:last_name => current_user.last_name)	
	end
          
	def options
		@options = {
				  :name => current_user.first_name,
				  :email => current_user.email,
				  #~ :start_date =>  Date.new(Time.now.year,Time.now.month.next),
				  :start_date => billing_start_date,
				  #~ :period => "Month",
				  :cycles=>15,
				  :credit_card => @card,
				  :frequency=>1,
				  :comment => 'Credit Card details updating'
		#		  :billing_address => "#{params[:billing_information][:address1]}, #{params[:billing_information][:address2]}"
				  
				  }
	end 

	def pay_first
		@response = creditcard_gateway.create_profile(options, 
					  :credit_card => credit_card, 
					  :description => "#{@plan.name}", 
					  :start_date => billing_start_date, 
					  :frequency => 1 , 
					  :amount => @plan.price*100, 
					  :initial_amount =>@plan.price*100)
					  @response
	end
  
	def option_values
		@options = {:name => current_user.billing_information.first_name,
							:email => current_user.email,
							:starting_at =>  billing_start_date,
							#~ :period => "Month",
							:comment => 'Change Plan',
							:cycles=>15,
							:billing_address => "#{current_user.billing_information.address1}, #{current_user.billing_information.address2}"
							}
	end
  
	def update_pay
		option_values
		
		
		if @current_plan_id.to_i<@plan.id.to_i
			
			subscription = Recurly::Subscription.find(current_user.id)
			subscription.change('renewal', :plan_code => "#{@plan.name.downcase}", :quantity => 1)
			
			@resp=subscription.persisted?
		else
			
			subscription = Recurly::Subscription.find(current_user.id)
			subscription.change('now', :plan_code => "#{@plan.name.downcase}", :quantity => 1)

			@resp=subscription.persisted?
		end
	#@response = creditcard_gateway.update_profile(@billing_info.recurring_profile_id,:description => "#{@plan.name}", :start_date => billing_start_date , :frequency => 1 , :amount =>@plan.price*100)             
	end

	def update_details
		credit_card
		@response = creditcard_gateway.update_profile(@billing_info.recurring_profile_id,options) 
	end
  
	def cancel_recurring
		#  options = {:name => current_user.billing_information.first_name,:email => current_user.email}
		#@response = creditcard_gateway.cancel_profile(current_user.billing_information.recurring_profile_id , options)
				billing_info=BillingInformation.find_by_user_id(current_user.id)
				
				if billing_info.plan_id.to_i==5 || billing_info.plan_id.to_i==6
					else
		acct = Recurly::Account.find(current_user.id)
		acct.close_account
		
end
		billing_info.destroy
	end
  
	def suspend_profile
		@response = creditcard_gateway.suspend_profile(current_user.billing_information.recurring_profile_id)
	end

	def valid_params
		@billing=BillingInformation.new(params[:billing_information])
		@billing.expires=@date
		@billing.valid?
	end

	def creditcard_gateway
		@gateway  =  ActiveMerchant::Billing::PaypalExpressRecurringGateway.new(
					:login => PAYPAL_CONFIG[:login] ,
					:password => PAYPAL_CONFIG[:password],
					:signature => PAYPAL_CONFIG[:signature]
					)
	end
  
	def plan_changed
		if @current_plan_id
			@current_plan_id > @plan.id ? "Upgraded" : "Downgraded"
		else
			"Upgraded"
		end
	end
  
	def close_account
		if request.xhr?
			#~ cancel_recurring if current_user.billing_information 
			billing_info=BillingInformation.find_by_user_id(current_user.id)
				if billing_info 
					if billing_info.plan_id.to_i==6
					else
						acct = Recurly::Account.find(current_user.id)
						acct.close_account
					end
					billing_info.destroy
				end 
			UserMailer.deliver_delete_account(current_user)
			delete_user(current_user)

			#current_user.update_attributes(:email=>"",:site_address=>"")
			render :update do |page|
				page.alert "Your account has successfully been deleted."
				page.redirect_to :controller=>"sessions",:action=>"destroy"      
			end
		else
			render :text=>"The page you were looking does not exist"
		end
	end
  
	def download_billing_history
		
		if current_user.billing_histories
			report = StringIO.new
			CSV::Writer.generate(report, ',') do |title|
				title << ['Date', 'Plan Name', 'Price']
				current_user.billing_histories.each do |bill|
					title << [bill.billing_date.strftime("%B %e, %Y"), bill.plan_name,  bill.amount]
				end 
			end 
			report.rewind
			send_data(report.read,:type => 'text/csv;',:filename => 'All History.csv', :disposition =>'attachment')
		end
	end

	def billing_start_date
		Date.today.next_month.beginning_of_month
	end
  
	def test_profile
		puts creditcard_gateway.get_profile_details("I-BFBSHETF3UF1").inspect
	end
	
	
	def recurly_notification

		if params[:new_subscription_notification] || params[:updated_subscription_notification] || params[:renewed_subscription_notification]
					if params[:new_subscription_notification]
						@plan_name=params[:new_subscription_notification][:subscription][:plan][:name]
						@start_date=params[:new_subscription_notification][:subscription][:current_period_started_at]
						@end_date=params[:new_subscription_notification][:subscription][:current_period_ends_at]
						@user=params[:new_subscription_notification][:account][:account_code]
					elsif params[:updated_subscription_notification]
						@plan_name=params[:updated_subscription_notification][:subscription][:plan][:name]
						@start_date=params[:updated_subscription_notification][:subscription][:current_period_started_at]
						@end_date=params[:updated_subscription_notification][:subscription][:current_period_ends_at]
						@user=params[:updated_subscription_notification][:account][:account_code]
					elsif params[:renewed_subscription_notification]
						@plan_name=params[:renewed_subscription_notification][:subscription][:plan][:name]
						@start_date=params[:renewed_subscription_notification][:subscription][:current_period_started_at]
						@end_date=params[:renewed_subscription_notification][:subscription][:current_period_ends_at]
						@user=params[:renewed_subscription_notification][:account][:account_code]
					end
					@plan_in_cothinkit=Plan.find_by_name(@plan_name)
					@plan=Recurly::Plan.find(@plan_name.downcase)
					@amount=@plan.unit_amount_in_cents/100
					time=Time.now+10800
					date=time.strftime("%Y-%m-%d")
					@billing=BillingHistory.create(:user_id=>@user,:plan_name=> @plan_name,:amount=>@amount,:billing_date=>date, :next_billing_date=>@end_date.strftime("%Y-%m-%d"))
					project_users=ProjectUser.find_all_by_user_id_and_is_owner(@user, true)
					project_users.each do |proj_user|
						project=Project.find_by_id(proj_user.project_id)
						project.update_attributes(:project_status=>true)
					end 
					

					@user_in_cothinkit=User.find(@user)
					@billing_info=BillingInformation.find_by_user_id(@user)
					@plan_limits=PlanLimits.find_by_user_id(@user)
					@plan_limits.update_attributes(:download_bandwidth_in_MB=>0, :storage_used=>0, :bandwidth_used=>0)
			#		UserMailer.deliver_plan_changed(@plan_in_cothinkit,@user_in_cothinkit)
		end
		render :nothing=>true

	end

end
