class Projects::FilesController < ApplicationController
	before_filter :login_required
	include Projects::FilesHelper
	layout 'base'
	before_filter :current_project
	before_filter :online_users, :only=>['index']

	before_filter :ensure_domain
		
	before_filter :check_site_address, :only=>['index']
		
	def index
		get_files_details
	  get_storage_stats
		check_bandwidth_usage
		@project_own=ProjectUser.find(:first, :conditions=>['project_id=? AND is_owner=? AND user_id=?', @project.id, true, current_user.id])
		@filter=params[:filter_option]		
		if request.xhr?
			render :update do |page| 
				#page.insert_html :bottom,"project_files_list", :partial => "list_files_with_filters"
				page.replace_html "project_files_list" ,:partial => 'list_files_with_filters'
				if @files.total_pages > @files.current_page
					page.call 'checkScroll'
				end				
				page[:loading].hide
			end			
		end	
	end
	
	def change_select_link
		render :update do |page| 
			page.replace_html "select_link_#{params[:file_id]}", :partial => "change_select_all"
		end				
	end	
	
	def download_selected_file		
		list = params[:selected_list].split(",")
		attachment = []	
		@attachment_size=0
    if !list.empty?
      if File.exists? "#{RAILS_ROOT}/public/download_files.zip"
        File.delete("#{RAILS_ROOT}/public/download_files.zip")
      end
			if RAILS_ENV=="development"  
					Zip::ZipFile.open("#{RAILS_ROOT}/public/download_files.zip", Zip::ZipFile::CREATE) { |zipfile|
						for file in list
							attach = Attachment.find_by_id(file) if !file.nil? and !file.blank?
							@attachment_size=@attachment_size+attach.size
							new_filename = check_files_name(attachment,attach.filename)
							attachment << new_filename
							zipfile.add("#{new_filename}","#{RAILS_ROOT}/public#{attach.public_filename}") if !attach.nil?
						end
					}
			else 
				 s3_connect
				 Zip::ZipOutputStream.open("#{RAILS_ROOT}/public/download_files.zip") { |zipfile|
						for file in list
							attach = Attachment.find_by_id(file) if !file.nil? and !file.blank?
							@attachment_size=@attachment_size+attach.size
							new_filename = check_files_name(attachment,attach.filename)
							attachment << new_filename
							#zipfile.add("#{new_filename}","#{RAILS_ROOT}/public#{attach.public_filename}") if !attach.nil?							
							s3_file=S3Object.find(attach.public_filename.split("/#{S3_CONFIG[:bucket_name]}/")[1],"#{S3_CONFIG[:bucket_name]}")
							zipfile.put_next_entry(new_filename)
							zipfile.print s3_file.value
						end
					}
				end	
				
				download_bandwidth_calculation
				@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
			
					send_file "#{RAILS_ROOT}/public/download_files.zip"
			
    end		
	end	
	
	def check_files_name(attachment,filename)
		new_name =  filename
		count =1
		
		while (attachment.include?(new_name)) do				
			name =  filename.split(".")
			name[-2]= name[-2]+count.to_s
			new_name = name.join(".")
			count = count +1
		end
		
		new_name			
	end	
	
	def filter_file
		get_files_details
		render :update do |page|
			@filter=params[:filter_option]
			#~ if params[:filter_option] == "Person"
				page.replace_html "project_files_list" ,:partial => 'list_files_with_filters'											
				if @files.total_pages > @files.current_page
					page.call 'clear_page_count'
					page.call 'checkScroll'				

				end				
				page[:loading].hide
				
			#~ else
				#~ page.replace_html "project_files_list" ,:partial => 'list_files_with_filters'
			#~ end
		end			
	end	
	
	def create		
		
		get_owner_projects
		@size=[]
		@is_valid_file=true
			post_content_type_for_file_tab if params[:file1]
			if @is_valid_file		&& @is_valid_file==true	
				total_current_post_size=find_current_post_storage(@size.sum)
				@plan_limits=PlanLimits.find_by_user_id(@user.id)
				total_storage=@plan_limits.max_storage_in_MB
				used_storage = @plan_limits.storage_used.to_f
				used_storage=used_storage+total_current_post_size
				total_bandwidth_in_MB=@plan_limits.max_bandwidth_in_MB 
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
				if (total_storage.nil? || (total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB > upload_download_bandwidth.to_f))
					@user=User.find(current_user.id) if current_user
					responds_to_parent do
						render :update do |page|
							@attachment = Attachment.new
							@attachment.uploaded_data = params[:file1]
							@attachment.project_id = @project.id
							@attachment.attachable =@user
							@attachment.save
              page.redirect_to project_files_path(@project.url,@project)
						end
					end
				else
	@project_owner=ProjectUser.find_by_project_id_and_is_owner_and_user_id(@project.id, true, current_user.id)
					responds_to_parent do	
					if ((total_storage.to_f > used_storage.to_f)  && ( total_bandwidth_in_MB <= upload_download_bandwidth.to_f))
						render :update do |page|	
              page['account-limit-modal'].show
            end
					elsif (total_storage.to_f <= used_storage.to_f)
						render :update do |page|	
							page['account-limit-modal'].show
						end
					else
						render :update do |page|	
							page['account-limit-modal'].show
						end
					end
				end
end
		end
	end
end
