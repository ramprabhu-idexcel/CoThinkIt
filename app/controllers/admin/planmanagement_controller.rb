require 'fastercsv'
require 'recurly'
class Admin::PlanmanagementController < AdminController
	  before_filter :admin_login_required
		include Admin::PlanmanagementHelper
		
	 layout "admin"
	def plans
		@plans=Plan.find(:all, :order =>"id DESC")
		
	end
	def edit
		
		@plans=Plan.find(:all, :order =>"id DESC")	  
		@id=params[:id]
		@editplan=Plan.find_by_id(@id)
		
		render  :update do |page|
			page.replace_html :edit_plan ,:partial => "edit_plan"
		end	
		          
	  end
		  
		  
	def update
	
		   params[:plan][:no_of_users].downcase
		   params[:plan][:no_of_projects].downcase
		if params[:plan][:no_of_users].downcase == "unlimited"
			params[:plan][:no_of_users] = nil
		end
		if params[:plan][:no_of_projects].downcase == "unlimited"
			params[:plan][:no_of_projects] = nil

			end
		    id=params[:id]
		    @plan=Plan.find_by_id(id) 
		    @plan.update_attributes(params[:plan])
		    storage=((params[:plan][:storage].to_f)*1024)
		     storage_MB=storage.to_s+"MB"
		     transfer=((params[:plan][:transfer].to_f)*1024)
		     transfer_MB=transfer.to_s+"MB"
		    @plan.update_attribute(:storage,storage_MB)
		    @plan.update_attribute(:transfer,transfer_MB)
				@plans=Plan.find(:all, :order =>"id DESC")
				
				 render  :update do |page|
							#~ page.replace_html :edit_plan ,:partial => "edit_plan"
							#~ page.replace_html :plan_list ,:partial => "plan_list"
							page.redirect_to '/adminpanel/plans'
				 end			
		     
	     end
	     
	def sorting_plan
		
		if params[:order]=="no_of_users" or params[:order]=="no_of_projects"
			sort = params[:by]
			@plans =[]
			@plan1 = Plan.find(:all,:conditions => "plans.#{params[:order]} IS NOT NULL",:select => "plans.*",:order => "plans.#{params[:order]} #{sort}")
			@plan2 = Plan.find(:all,:conditions => "plans.#{params[:order]} IS NULL",:select => "plans.*",:order => "plans.id #{sort}")
			if sort == "asc"
					@plans << @plan1
					@plans << @plan2
			else
					@plans << @plan2
					@plans << @plan1				
			end	
			@plans =@plans.flatten								
		elsif  params[:order]=="storage" or params[:order]=="transfer"
			@plans = []
			@plan1=Plan.find(:all, :order =>"sort_len #{params[:by]},storage_sort #{params[:by]}",:select => "plans.*,SUBSTRING(#{params[:order]},1,LENGTH(#{params[:order]})-2)	as storage_sort , LENGTH(#{params[:order]})-2 as sort_len",:conditions => " #{params[:order]} IS NOT NULL ")
			@plan2 = Plan.all - @plan1
			
			if params[:by] == "asc"			
				  @plans << @plan1
					@plans << @plan2
					
			else
				  @plans << @plan2
			  	@plans << @plan1
													
			end	
			@plans =@plans.flatten		

			
		else	
			@plans=Plan.find(:all, :order =>"#{params[:order]} #{params[:by]}")
		end	
		
		render  :update do |page|
			page.replace_html :plan_list ,:partial => "plan_list"
		end			
	end	
	 	    
	def download_plan_csv
		filename = 'plan_management.csv'
		headers.merge!(
		'Content-Type' => 'text/csv',
		'Content-Disposition' => "attachment; filename=\"#{filename}\"",
		'Content-Transfer-Encoding' => 'binary'
		)
		@performed_render = false
 		render :status => 200, :text => Proc.new { |response, output|
		headings = ["Plan","Users","Projects","Storage(GB)","Transfer(GB)","Monthly Price"]
		output.write FasterCSV.generate_line(headings)

    Plan.find(:all).each do |plan|
			  data = [plan.name, (plan.no_of_users.nil?) ? "Unlimited" : plan.no_of_users,( plan.no_of_projects.nil?) ? "Unlimited" :  plan.no_of_projects, convert_to_GB(plan.storage),convert_to_GB(plan.transfer),"$#{plan.price}"]
			output.write FasterCSV.generate_line(data)	
															
		end	

		}
	end				
end
