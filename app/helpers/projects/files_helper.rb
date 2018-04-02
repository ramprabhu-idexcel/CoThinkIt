module Projects::FilesHelper
	#~ def get_files_details
    #~ filter = params[:filter_option]				
		 #~ @files = Attachment.paginate(:all,:conditions => ["project_id=?",@project.id],:order => "created_at Desc",:page => params[:page],:per_page =>30)	
     #~ page = params[:page] || 1		
		#~ limit  =	 30* page.to_i	 
    #~ if filter.nil? or filter.blank? or filter == "Date and time"			
      #~ @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " created_at Desc",:offset =>0,:limit => limit)		
    #~ elsif filter == "Person"
     #~ @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " Date(created_at) Desc",:offset =>0,:limit => limit)			
		 #~ @user_files=@all_files.group_by{|d| 
		 #~ resource = d.attachable		
		 #~ if d.attachable_type =="Comment"
         #~ resource.user_id
		 #~ elsif d.attachable_type == 'Post'
			   #~ resource.user_id
		 #~ elsif d.attachable_type == 'User'
			   #~ d.attachable_id
		 #~ end 		 
		#~ }					
    #~ elsif filter == "Alphabetical"
      #~ @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " Date(created_at) Desc, filename asc",:offset =>0,:limit => limit)		
    #~ elsif filter == "File Type"
      #~ @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:select => "attachments.*, SUBSTRING_INDEX(filename,'.',-1) as sort_str ",:order => " Date(created_at)  Desc,sort_str asc,filename asc",:offset =>0,:limit => limit)					
    #~ end 		
	#~ end	
	
	def get_files_details
    filter = params[:filter_option]				
		 @files = Attachment.paginate(:all,:conditions => ["project_id=?",@project.id],:order => "created_at Desc,filename asc",:page => params[:page],:per_page =>30)	
     page = params[:page] || 1		
		limit  =	 30* page.to_i	 
    if filter.nil? or filter.blank? or filter == "Date and time"			
      @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " created_at Desc",:offset =>0,:limit => limit)		
    elsif filter == "Person"
     @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " filename asc",:offset =>0,:limit => limit)			
		 @user_files=@all_files.group_by{|d| 
		 resource = d.attachable		
		 if d.attachable_type =="Comment"
         resource.user_id
		 elsif d.attachable_type == 'Post'
			   resource.user_id
		 elsif d.attachable_type == 'User'
			   d.attachable_id
		 end 		 
		}					
    elsif filter == "Alphabetical"
      @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:order => " filename asc",:offset =>0,:limit => limit)		
    elsif filter == "File Type"
      @all_files=Attachment.find(:all,:conditions => ["project_id=?",@project.id],:select => "attachments.*, SUBSTRING_INDEX(filename,'.',-1) as sort_str ",:order => "sort_str asc,filename asc",:offset =>0,:limit => limit)					
    end 		
	end		
	
	def display_file_filter_by_person(user_id)
		user = User.find_by_id(user_id)
		return !user.nil? ? user.first_name+"'s Files" : "Files"
	end	
end
