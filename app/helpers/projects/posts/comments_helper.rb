module Projects::Posts::CommentsHelper
		def send_email_notify_to_post_comment_creation
			if !@post.email_notification.nil? and !@post.email_notification.blank?
				users = User.find_all_by_id(@post.email_notification.split(","))
				for user in users
					UserMailer.deliver_post_comment_notify_mail(@project,@post,@comment,current_user,user,request.env['HTTP_HOST'],request.env['SERVER_NAME']) 
				end	
			end	
		end	
		
		    def store_post_comments_details_to_the_user(comment) 
					
			project = comment.project
			@project_users = ProjectUser.find_all_by_project_id(project.id)
			for project_user in @project_users
				if !project_user.user_id.nil? 
					status = (project_user.user_id == current_user.id) ? true : false
					PostsCommentsDisplay.create(:user_id => project_user.user_id,:comment_id => comment.id,:is_comment_viewed=>status)
				end						
			end							
		end	

end
