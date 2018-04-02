require 'fastercsv'
require 'fastercsv'
require 'recurly' 
class Admin::UsermanagementController < AdminController
#	ActiveMerchant::Billing::Base.gateway_mode = :test 
	include ActiveMerchant::Billing
	 before_filter :admin_login_required, :except=>':download_csv'
	layout "admin"
	 
	def usermanagement
		@user=User.paginate(:all ,:conditions=>"status IS NOT NULL", :page => params[:page], :per_page => 100)
		proj=User.find(:all ,:conditions=>"status IS NOT NULL")
				@lastpage=proj.count/100

		@status=['Active','Suspend','Delete']
	  
	end
	
	def edit
		#for edit user status
		flash[:error_user]=nil
		flash[:success_user]=nil
		@id=params[:id]
		@edituser=User.find_by_id(@id)
		@status=['Active','Suspend','Delete']
		@val = user_status(@edituser.status)
		@plan = Plan.all.collect{|p| [p.name, p.id] }
		@billing = BillingInformation.find_by_user_id(@edituser.id)
		@plan_de = @billing.nil? ? Plan.find_by_name("Trial")  :  @billing.plan
		@user=User.find:all 
		@siteaddress=@edituser.site_address                 
		@plans=Plan.find:all
		@status=['Active','Suspend','Delete']
		render  :update do |page|
			page.hide 'error_success_message_user'
			page.replace_html :edit_user ,:partial => "edit_user"
		end	
	end
	  
	  def update
			
			
			@page_reload=true
				id=params[:id]
				@user=User.find_by_id(id)
					if params[:status] 
						if   params[:status] != "Delete"
							val = (params[:status]=="Active") ? 1 : 0
							@user.update_attribute(:status,val)
								if val == 0
									projectusers=@user.project_users.find(:all, :conditions => ["is_owner = ?", true])
										projectusers.each do |projectuser|
											project=Project.find_by_id(projectuser.project_id)
											project.update_attribute(:project_status,val)
										end
								end
						elsif params[:status] == "Delete"
							 UserMailer.deliver_delete_account(@user)
								delete_user(@user)
							end
							
						#redirect_to '/adminpanel/usermanagement'		
					end
						if  params[:status]
								success = 	@user.update_attributes(:site_address=>params[:user][:site_address].downcase)
									if success
										change_plan
									end
									
							render :update do |page|
								success = 	@user.update_attributes(:site_address=>params[:user][:site_address].downcase)
								
									if !success
										
			errors_list = @user.errors  if !success
									  fieldname =[]
									  error =[]
											if @user.errors["site_address"].class == String
												
												if @user.errors["site_address"] && @user.errors["site_address"]=="Please enter a site address."
													flash[:error_user]="Error! Required field is empty!"
												elsif (@user.errors["site_address"]) && (@user.errors["site_address"])=="Please only use letter and numbers. No spaces please."
													flash[:error_user]="Error! Improper value entered (e.g. entering a project URL or site address with symbols !@$%^&*().,/?;:[]\{}|~`+-*/= etc...)"
												else
													flash[:error_user]=@user.errors["site_address"] if @user.errors["site_address"]
												end
											else 
												flash[:error_user]=@user.errors["site_address"][0] if @user.errors["site_address"]
											end
page.redirect_to '/adminpanel/usermanagement'
									else
										if flash[:success_user].nil?
											
										 flash[:success_user]="Success! User updated."
										end
																	if @page_reload==true
																		
											page.redirect_to '/adminpanel/usermanagement'
											else
												
												page.redirect_to '/adminpanel/usermanagement'
										end
										
									end
							end
						end



					#~ render :update do |page|
						#~ page.redirect_to '/adminpanel/usermanagement'		
					#~ end


		end
	 
	def download_csv
		filename = 'usermanagement.csv'
		headers.merge!(
		'Content-Type' => 'text/csv',
		'Content-Disposition' => "attachment; filename=\"#{filename}\"",
		'Content-Transfer-Encoding' => 'binary'
		)
		@performed_render = false
 		render :status => 200, :text => Proc.new { |response, output|
		headings = ["Name","Email","site address"]
		output.write FasterCSV.generate_line(headings)
 		last_user_id = 0
		while last_user_id do
		users = User.find(:all,
                              :conditions => ["users.id > ? AND users.email !=''", last_user_id],
                              :order => 'users.id',
                              :limit => 1000)
 
		last_user_id = users.size > 0 ? users[-1].id : nil
 		users.each { |user|
		data = [user.first_name, user.email,user.site_address]
		output.write FasterCSV.generate_line(data)
		}
		end
		}
	end
  
  def change_plan
		
		@alert_message=""
    @user=User.find_by_id params[:id]
		@existing_plan=Plan.find_by_id(@user.billing_information.plan_id) if @user.billing_information
		
		if @existing_plan.nil?
			@existing_plan=Plan.find_by_name("Beta")
		end
		
    @plan=Plan.find_by_id params[:billing_information][:plan_id]
		
		if @existing_plan.id.to_i!=@plan.id.to_i || (@existing_plan.name=="Beta" && @plan.name=="Beta")
			
			@page_reload=false
			if @plan.name=="Beta"
				
				change_beta_plan
			elsif @plan.name=="Trial"
				
				if @user.allowed_to_changeplan?(params[:billing_information][:plan_id])
					@user.billing_information ? @user.billing_information.update_attribute(:plan_id,params[:billing_information][:plan_id]): BillingInformation.create(:user_id=>@user.id,:plan_id=>params[:billing_information][:plan_id])
		 
					update_plan_limits_admin(@user)
					#~ if @user.billing_information.recurring_profile_id.nil?
						#~ @user.billing_information.delete
					#~ end
					
					flash[:success_user]="Success! User updated."
	  		#  flash[:success_user]="You have changed the plan to Trial Plan. User will be charged $0 on a monthly basis."
				#	page.redirect_to '/adminpanel/usermanagement'	
				else
					
					flash[:error_user]="We are unable to Downgraded user's plan because user's usage exceeds the lower plan's limits."
				end
			else
				
				if @user.billing_information && !@user.billing_information.recurring_profile_id.nil?
					changed=@user.billing_information.plan_id>params[:billing_information][:plan_id].to_i ? "Upgraded" : "Downgraded"
					@current_plan_id=@user.billing_information.plan_id if @user.billing_information
					if @user.allowed_to_changeplan?(params[:billing_information][:plan_id])
						# @response=creditcard_gateway.cancel_profile(@user.billing_information.recurring_profile_id)
							if @current_plan_id.to_i<@plan.id.to_i
								subscription = Recurly::Subscription.find(@user.id)
								subscription.change('renewal', :plan_code => "#{@plan.name.downcase}", :quantity => 1)
								@resp=subscription.persisted?
							else
								subscription = Recurly::Subscription.find(@user.id)
								subscription.change('now', :plan_code => "#{@plan.name.downcase}", :quantity => 1)
								@resp=subscription.persisted?
								#      @response = creditcard_gateway.update_profile(@user.billing_information.recurring_profile_id,:description => "#{@plan.name}", :amount =>@plan.price*100)  
							end
						 	if @resp && @resp==true
								@user.billing_information.update_attribute(:plan_id,params[:billing_information][:plan_id])
								update_plan_limits_admin(@user)
								
								#   flash[:success_user]="You have #{changed} the plan to the #{@plan.name} Plan. User will be charged $#{@plan.price} on a monthly basis."
								flash[:success_user]="Success! User updated."
					#				page.redirect_to '/adminpanel/usermanagement'	
						  else
								flash[:error_user]="Sorry, Error in processing. Please try again later."
								#			page.redirect_to '/adminpanel/usermanagement'	
			 
							end          
					else
						
						flash[:error_user]="We are unable to #{changed} user's plan because user's usage exceeds the lower plan's limits."
							#		page.redirect_to '/adminpanel/usermanagement'	
				 	end
        else
					
          flash[:error_user]="Sorry the user don't have the credit card information, cannot change the user's plan"
					#	page.redirect_to '/adminpanel/usermanagement'	
        end     
			end   
		else
			
		end
  end
  
  def creditcard_gateway
    @gateway  =  ActiveMerchant::Billing::PaypalExpressRecurringGateway.new(
                :login => PAYPAL_CONFIG[:login] ,
                :password => PAYPAL_CONFIG[:password],
                :signature => PAYPAL_CONFIG[:signature]
                )
	end
							
	def sorting_user
		if params[:order] != "plan"
			@user=User.paginate(:all,:conditions=>"status IS NOT NULL",:order => "#{params[:order]} #{params[:by]}", :page => params[:page], :per_page => 100)
			@proj=User.find(:all,:conditions=>"status IS NOT NULL",:order => "#{params[:order]} #{params[:by]}")
		else
			sort = params[:by]
			#~ @user =[]
			#~ @user = User.paginate(:all,:conditions=>"users.status IS NOT NULL",:joins => "left join billing_informations on users.id = billing_informations.user_id",:select => "users.*",:order => "billing_informations.plan_id #{sort}",:from =>"users", :page => params[:page], :per_page => 100)
      @free_users=User.find(:all,:conditions=>['users.status is not null and billing_informations.id is null'],:include=>:billing_information)
      @beta_users=User.find(:all,:conditions=>['users.status is not null and billing_informations.id is not null and plans.name =?',"Beta"],:include=>{:billing_information=>"plan"},:order=>"billing_informations.plan_id asc")
      @users_in_plan=User.find(:all,:conditions=>['users.status is not null and billing_informations.id is not null and plans.name !=?',"Beta"],:include=>{:billing_information=>"plan"},:order=>"billing_informations.plan_id asc")
      @user=@beta_users+@users_in_plan+@free_users
      @user=@user.reverse if sort=="asc"
      @user=@user.paginate(:page => params[:page], :per_page => 100)
			@proj = User.find(:all,:conditions=>"users.status IS NOT NULL",:joins => "left join billing_informations on users.id = billing_informations.user_id",:select => "users.*",:order => "billing_informations.plan_id #{sort}",:from =>"users")
		#	SELECT users.* FROM users left join billing_informations on users.id = billing_informations.user_id ORDER BY billing_informations.plan_id asc
			#~ @user2 = User.find(:all) - @user1
			#~ if sort == "asc"
					#~ @user << @user1
					#~ @user << @user2
			#~ else
					#~ @user << @user2
					#~ @user << @user1				
			#~ end	
			#~ @user =@user.flatten
		#	@user=User.find(:all,:order => "plan_info #{params[:by]}",:select => "users.*,billing_informations.plan_id as plan_info",:joins => " left join billing_informations on users.id = billing_informations.user_id ")
			
   #select users.*,billing_informations.plan_id from users left join billing_informations on users.id = billing_informations.user_id order by billing_informations.plan_id

			
		end	
					@lastpage=@proj.count/100
		@status=['Active','Inactive']	
				if request.xhr?		
		render  :update do |page|
			page.replace_html :user_listing ,:partial => "user_list"
		end	
		else
				render :action=>'usermanagement'
		end
	end	
	  
  def change_beta_plan
		
		
		

if @existing_plan.id!=@plan.id		|| (@existing_plan.name=="Beta" && @plan.name=="Beta")
    @billing_info=@user.billing_information 
    if @billing_info 
      creditcard_gateway.suspend_profile(@billing_info.recurring_profile_id) if @billing_info.recurring_profile_id
    else
      @billing_info=BillingInformation.create(:user_id=>@user.id,:plan_id=>params[:billing_information][:plan_id])
    end
    update_beta_limits(@user)
   
      BillingHistory.create(:user_id=>@user.id,:plan_name=>"Beta",:amount=>0,:billing_date=>Date.today)
      @billing_info.update_attribute(:plan_id,params[:billing_information][:plan_id])
   #   flash[:success_user]="You have changed the plan to the Beta Plan."
	 flash[:success_user]="Success! User updated."
			#	page.redirect_to '/adminpanel/usermanagement'	
   
  end
end


def user_status_edit

ids=params[:id].split(',')
status=ids.last
selected_ids=ids.split(status);
selected_ids.first.each do |id|
	@user=User.find_by_id(id)
	if  status != "Delete"
				val = (status=="Active") ? 1 : 0
							@user.update_attribute(:status,val)
							if val == 0
									projectusers=@user.project_users.find(:all, :conditions => ["is_owner = ?", true])
										projectusers.each do |projectuser|
											project=Project.find_by_id(projectuser.project_id)
											project.update_attribute(:project_status,val)
										end
								end
						elsif status == "Delete"
							 UserMailer.deliver_delete_account(@user)
								delete_user(@user)
							end
		
	end
	
				render :update do |page|
				   page.redirect_to '/adminpanel/usermanagement'	
					 end
				 end
				 
				 
end
