module Projects::PostsHelper
		def list_email_notification_for_post
			@users =@project.members
			@email_notification_email_list = []	
			@email_notification_email_list << ["All of #{@project.name}","#{@users.map(&:id).join(",")}"]	
			@company_list = @project.members.find(:all,:select => " company, count( * ) ",:from => "users",:group=> "company",:having =>"count( * ) > 1" )
			for company in @company_list
				@email_notification_email_list << ["All of #{company.company}","#{@users.find_all_by_company(company.company).map(&:id).join(",")}"]		
			end			
			for user in @users
				@email_notification_email_list << ["#{user.first_name.capitalize} #{user.last_name.first.capitalize}.","#{user.id}"]		
			end				
		end	
		
		def check_guest_user_permission
			if !check_role_for_guest
				redirect_to project_posts_path(@project.url,@project)
			end	
		end		

    def store_post_details_to_the_user(post) 
			project = post.project
			@project_users = ProjectUser.find_all_by_project_id(project.id)
			for project_user in @project_users
				if !project_user.user_id.nil? 
					status = (project_user.user_id == current_user.id) ? true : false
					PostsCommentsDisplay.create(:user_id => project_user.user_id,:post_id => post.id,:is_post=>true, :is_post_viewed=>status)
				end						
			end							
		end	
		
		def change_post_status_in_show(post)
			PostsCommentsDisplay.update_all( "is_post_viewed = true", [" user_id =? and post_id IN (?) and is_post=?",current_user.id,post.id,true])
		end	
		
				
		def change_post_comment_status_in_show(comments)			
			PostsCommentsDisplay.update_all( "is_comment_viewed = true", ["user_id =? and comment_id IN (?) and is_post =?  ",current_user.id,comments.map(&:id),false])
			end	
end
