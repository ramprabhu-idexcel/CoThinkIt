class Projects::SearchController < ApplicationController
	include SearchHelper
	before_filter :login_required
	before_filter :current_project
	before_filter :ensure_domain	
	before_filter :check_site_address, :only=>['index']
	layout 'base'	
	
	def index
		h= Hash[:search_text => params[:search_text],:user_id => current_user.id,:project_id => @project.id]
		@search = Search.new(h)
		if @search.valid?
			s = Search.find(:first,:conditions => h)
			s.destroy if s
			@search.save		
		end
    check_bandwidth_usage
		split = (params[:search_text].count("\"") > 0) ? true : false	
		implement_search_functionality(@project,split,params[:search_text].gsub("\"",""))		
    @recent_searches = Search.find_all_by_user_id(current_user.id,:order => "created_at desc",:limit => 5)
	end	
	
	def implement_search_functionality(project,split,search_text)
		flag = []
		message = []
		flag << "accept"  if (search_text=~ /accept/)
		flag << "reject"  if (search_text=~ /reject/)
		flag << "pending"  if (search_text =~ /pending/)		
		if !flag.empty?		
        message << " " 			
			for msg in flag
				message << " status like '%%#{msg}%%' "
			end	
		end	
		   			
		if !params[:search_text].nil? and !params[:search_text].blank?			
				if split == true			
					@posts = @project.posts.find(:all,:conditions => [" title like ? or content like ?  #{message.join('or')}","%%#{search_text}%%","%%#{search_text}%%"])
					@comments = Comment.find(:all,:conditions => ["(comment like ? #{message.join('or')} ) and project_id=? ","%%#{search_text}%%",@project.id])
					@files = Attachment.find(:all,:conditions => [" filename like ? and project_id=? ","%%#{search_text}%%",@project.id])
				else
						search_values = search_text.split(" ")
						condition = [] 
						values = []
						for search in search_values
								condition <<  " title like '%%#{search}%%' "				
								condition << " content like '%%#{search}%%' "
							end
							@posts =  Post.find(:all,:conditions => ["MATCH (title,content,status) AGAINST (?  IN BOOLEAN MODE) and  ( project_id =? )",search_text,@project.id],:order => "created_at asc",:select => "posts.*, MATCH (title,content,status) AGAINST ('#{search_text}' IN BOOLEAN MODE) AS score",:order => " score desc")			
					#	@posts = @project.posts.find(:all,:conditions => ["( #{condition.join(" or ")}) #{message.join('or')} and ( project_id =? )",@project_id])			
						condition = [] ; values = []			
						for search in search_values
									condition << " comment like '%%#{search}%%'"
								end				
								@comments = Comment.find(:all,:conditions => ["MATCH (comment,status) AGAINST (?  IN BOOLEAN MODE) and ( project_id =? )",search_text,@project.id],:order => "created_at asc",:select => "comments.*, MATCH (comment,status) AGAINST ('#{search_text}' IN BOOLEAN MODE) AS score",:order => " score desc")									
						#@comments = Comment.find(:all,:conditions => [" ( #{condition.join(" or ")} ) #{message.join('or')} and ( project_id =? )",@project_id])			
						condition = [] ; values = []			
						for search in search_values
									condition << " filename like '%%#{search}%%'"
						end			
						@files = Attachment.find(:all,:conditions =>  ["( #{condition.join(" or ")}) and ( project_id =? )",@project.id])			
					end
		else
      @posts =[]; @comments=[];@files=[]			
    end 	
    count_days_record_result
	end	
		
end
