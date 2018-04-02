class SearchController < ApplicationController	
	include SearchHelper
	include ApplicationHelper
	before_filter :login_required
	before_filter :ensure_domain
	layout 'base'	
	
	def index		
		  h = Hash[:search_text => params[:search_text],:user_id => current_user.id]
			@search = Search.new(h)
			if @search.valid?
				s = Search.find(:first,:conditions => h)
				s.destroy if s
				@search.save		
			end
			@project = Project.find_by_id(params[:id]) if params[:id]			
      check_bandwidth_usage_mytask      
			split = (params[:search_text].count("\"") > 0) ? true : false	    
			implement_search_functionality(@project,split,params[:search_text].gsub("\"",""))		
			@recent_searches = Search.find_all_by_user_id(current_user.id,:order => "created_at desc",:limit => 5)			
	end	
	
	def implement_search_functionality(project,split,search_text)
		flag = []
		message = []
		flag << "accept"  if (search_text =~ /accept/)
		flag << "reject"  if (search_text  =~ /reject/)
		flag << "pending"  if (search_text =~ /pending/)		
		if !flag.empty?		
        message << " " 			
			for msg in flag
				message << " status like '%%#{msg}%%' "
			end	
		end
		
		list_current_user_projects		
		if !@projects.empty? and !params[:search_text].nil? and !params[:search_text].blank?
			if split == true				
				search = search_text.gsub("+"," ")		
				@search_values = [search_text]				
				@posts = Post.find(:all,:conditions => ["( title like ? or content like ?  #{message.join('or')} ) and project_id IN (?) ","%%#{search_text}%%","%%#{search_text}%%",@projects.map(&:id)],:order => "created_at asc")
				@comments = Comment.find(:all,:conditions => [" ( comment like ?  #{message.join('or')} ) and project_id IN (?)","%%#{search_text}%%",@projects.map(&:id)],:order => "created_at asc")
				@files = Attachment.find(:all,:conditions => [" filename like ? and project_id IN (?) ","%%#{search_text}%%",@projects.map(&:id)],:order => "created_at asc")
			else				
				@search_values = search_text.split(" ")				
				condition = [] 
				values = []
				for search in @search_values
					condition <<  " title like '%%#{search}%%' "				
					condition << " content like '%%#{search}%%' "
				end
        @posts =  Post.find(:all,:conditions => ["MATCH (title,content,status) AGAINST (?  IN BOOLEAN MODE) and  ( project_id IN (?) )",search_text,@projects.map(&:id)],:order => "created_at asc",:select => "posts.*, MATCH (title,content,status) AGAINST ('#{search_text}' IN BOOLEAN MODE) AS score",:order => " score desc")			
				#@posts = Post.find(:all,:conditions => ["( #{condition.join(" or ")}) #{message.join('or')} and ( project_id IN (?) )",@projects.map(&:id)],:order => "created_at asc")			
				condition = [] ; values = []			
				for search in @search_values
						condition << " comment like '%%#{search}%%'"
				end				
				@comments = Comment.find(:all,:conditions => ["MATCH (comment,status) AGAINST (?  IN BOOLEAN MODE) and ( project_id IN (?) )",search_text,@projects.map(&:id)],:order => "created_at asc",:select => "comments.*, MATCH (comment,status) AGAINST ('#{search_text}' IN BOOLEAN MODE) AS score",:order => " score desc")	
				#@comments = Comment.find(:all,:conditions => [" ( #{condition.join(" or ")} ) #{message.join('or')} and ( project_id IN (?) )",@projects.map(&:id)],:order => "created_at asc")	
				condition = [] ; values = []			
				for search in @search_values
						condition << " filename like '%%#{search}%%'"
				end			
				@files = Attachment.find(:all,:conditions =>  ["( #{condition.join(" or ")})  and ( project_id IN (?) )",@projects.map(&:id)],:order => "created_at asc")
			end
	  else
			@posts =[]; @comments=[];@files=[]
		end	
		count_days_record_result
	end	
	
	
	def previous_month
		current_date=find_current_zone_date		
		@current_date=current_date.to_date
    @year=params[:year].to_i
    @month=params[:month].to_i+1
    if @month==13
      @year+=1
      @month=1
    end
				@task=Task.find_by_id(params[:id]) if params[:id]
    render :update do |page|
			if params[:id]
				page.replace_html "update_calender_#{params[:id]}",:partial=>"projects/tasks/todos/calender_display"
			else
      page.replace_html "update_calender",:partial=>"projects/tasks/calender_display"
			end
    end		
	end

  def next_month
		current_date=find_current_zone_date		
		@current_date=current_date.to_date
    @year=params[:year].to_i
    @month=params[:month].to_i-1
    if @month==0
      @year-=1
      @month=12
    end		
		@task=Task.find_by_id(params[:id]) if params[:id]
    render :update do |page|
			if params[:id]
				page.replace_html "update_calender_#{params[:id]}",:partial=>"projects/tasks/todos/calender_display"
			else
      page.replace_html "update_calender",:partial=>"projects/tasks/calender_display"
			end
    end		
	end
	
		
	

	
end
