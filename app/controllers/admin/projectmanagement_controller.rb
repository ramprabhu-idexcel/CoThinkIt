require 'fastercsv'
class Admin::ProjectmanagementController < AdminController
before_filter :admin_login_required
	include Admin::ProjectmanagementHelper
	layout "admin"
	
	def projectmanagement
				@projects=Project.paginate :page => params[:page], :per_page => 100
				proj=Project.find :all
				@lastpage=proj.count/100
				
				
	end
	
	def edit
		flash[:message]=nil
		flash[:error]=nil
		@change_project_url=false
		if params[:edit_status]
			@project=Project.find_by_id(params[:id])
			@status=['Active','Suspend','Delete']
			@val = (@project.project_status==true) ? 'Active' : 'Suspend'
			render :action => "edit_status",:layout => false
		elsif params[:edit_url]
			
			@projects=Project.find:all
					@id=params[:id]
					@project=Project.find_by_id(params[:id])
					@change_project_url=true
				else
					@projects=Project.find:all
					@id=params[:id]
					@project=Project.find_by_id(params[:id])
				end
						render  :update do |page|
							page.hide 'error_success_message'
			page.replace_html :edit_project ,:partial => "edit_project"
		end	
	end
	
	def update
		
		
		id=params[:id]
		@project=Project.find_by_id(id)
		if params[:project_status] 
		  if  params[:project_status] != "Delete"
			   val = (params[:project_status]=="Active") ? 1 : 0
			   @project.update_attribute(:project_status,val)
			elsif params[:project_status] == "Delete"
						@project.destroy
						success=true
						flash[:message]="Success! Project deleted."
					end
				
			render :update do |page|
				success = @project.update_attributes(:name=>params[:project][:name],:url=>params[:project][:url]) if params[:project][:name] && params[:project_status]!="Delete"
				
					if success
					  	
					else
						errors_list = @project.errors  if !success
						
							if @project.errors["name"].class == String
								if @project.errors["name"] && @project.errors["name"]=="Please give your project a name."
								flash[:error]="Error! Required field is empty!"
								else
								flash[:error]=@project.errors["name"] if @project.errors["name"]
								end
							else 
								flash[:error]=@project.errors["name"][0] if @project.errors["name"]
							end
							if @project.errors["url"].class == String
								if @project.errors["url"] && @project.errors["url"]=="Please enter a URL for your project."
								flash[:error]="Error! Required field is empty!"
								elsif @project.errors["url"] && @project.errors["url"]=="Improper value entered, special characters are not allowed"
									flash[:error]="Error! Improper value entered (e.g. entering a project URL or site address with symbols !@$%^&*().,/?;:[]\{}|~`+-*/= etc...)"
								else
								flash[:error]=@project.errors["url"] if @project.errors["url"]
								end
							else 
							flash[:error]=@project.errors["url"][0] if @project.errors["url"]
							end
						end
					flash[:message]="Success! Project updated." if params[:project_status]!="Delete"
					
					page.redirect_to '/adminpanel/projectmanagement'	
					end
					
		end
						 
	 end
	 
	def sorting_project
				if params[:order]=="owner"
					@projects=Project.paginate(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id inner join users on project_users.user_id = users.id",:order => " users.first_name #{params[:by]}",:page => params[:page], :per_page => 100)
					@proj=Project.find(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id inner join users on project_users.user_id = users.id",:order => " users.first_name #{params[:by]}")
				elsif  params[:order]=="owner_email"	
					@projects=Project.paginate(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id inner join users on project_users.user_id = users.id",:order => " users.email #{params[:by]}",:page => params[:page], :per_page => 100)	
					@proj=Project.find(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id inner join users on project_users.user_id = users.id",:order => " users.email #{params[:by]}")
				elsif params[:order] == "storage_used"	 or params[:order] == "download_bandwidth_in_MB"
			
					@projects=Project.paginate(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id left join plan_limits on project_users.user_id = plan_limits.user_id ",:order => " plan_limits.#{params[:order]} #{params[:by]}",:select =>"projects.* , plan_limits.#{params[:order]}" ,:page => params[:page], :per_page => 100)	
					@proj=Project.find(:all, :order =>"#{params[:order]} #{params[:by]}",:conditions => ["project_users.is_owner = true "],:joins => " inner join project_users on projects.id = project_users.project_id left join plan_limits on project_users.user_id = plan_limits.user_id ",:order => " plan_limits.#{params[:order]} #{params[:by]}",:select =>"projects.* , plan_limits.#{params[:order]}")
					
					#~ @project2 = Project.find(:all) - @project1
					
					#~ if params[:by] == "asc"
							#~ @projects << @project1
							#~ @projects << @project2
					#~ else
							#~ @projects << @project2
							#~ @projects << @project1				
					#~ end	
					#~ @projects =@projects.flatten									
					
				else
					@projects=Project.paginate(:all, :order =>"#{params[:order]} #{params[:by]}",:page => params[:page], :per_page => 100)
					@proj=Project.find(:all, :order =>"#{params[:order]} #{params[:by]}")
				end					
				
				@lastpage=@proj.count/100
				if request.xhr?
				render  :update do |page|
					page.replace_html :project_listing ,:partial => "project_list"
				end			
				else
					render :action=>'projectmanagement'
				end
		end

	def download_project_csv
		filename = 'project_management.csv'
		headers.merge!(
		'Content-Type' => 'text/csv',
		'Content-Disposition' => "attachment; filename=\"#{filename}\"",
		'Content-Transfer-Encoding' => 'binary'
		)
		@performed_render = false
 		render :status => 200, :text => Proc.new { |response, output|
		headings = ["Project","Project URL","Owner","Owner's Email","Storage(GB)","Current Transfer(GB)","Status"]
		output.write FasterCSV.generate_line(headings)

	
	Project.find(:all).each do |project|
		user = project.owner
		plan=user.plan_limits if user

		owner_name = !user.nil? ? user.first_name : ""
		owner_email = !user.nil? ? user.email : ""
		if plan!=nil		
			val = (plan.storage_used.nil?) ? 0 : plan.storage_used
			storage_plan =bandwidth_in_gb(val)
		else
			storage_plan =0
		end	
		
		if plan!=nil		
			val = (plan.download_bandwidth_in_MB.nil?) ? 0 : plan.download_bandwidth_in_MB
			val1= (plan.bandwidth_used.nil?) ? 0 : plan.bandwidth_used 
			bandwidth =bandwidth_in_gb(val+val1)
		else
			bandwidth =0
		end
		status =  project.project_status==true ? "Active" : "Suspend"
		data = [project.name,project.url,owner_name,owner_email,storage_plan,bandwidth,status]
		output.write FasterCSV.generate_line(data)
	end	
	

	
		}
	end

def project_status

ids=params[:id].split(',')
status=ids.last
selected_ids=ids.split(status);
selected_ids.first.each do |id|
	@project=Project.find_by_id(id)
	
			  if  status!= "Delete"
				 val = (status=="Active") ? 1 : 0
				 @project.update_attribute(:project_status,val)
			elsif status == "Delete"
						@project.destroy
					end
		
end
				render :update do |page|
				   page.redirect_to '/adminpanel/projectmanagement'	
					 end
end
end
