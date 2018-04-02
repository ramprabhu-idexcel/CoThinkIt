ActionController::Routing::Routes.draw do |map|	
	#Admin email template routes
  map.email_templates '/adminpanel/email_templates', :controller=>'admin/email_templates',:action=>'index',:conditions=>{:method=>:get}
  map.edit_email_template '/adminpanel/email_template/:id/edit', :controller=>'admin/email_templates',:action=>'edit',:conditions=>{:method=>:get}
  map.admin_email_template '/adminpanel/email_template/:id', :controller=>'admin/email_templates',:action=>'update',:conditions=>{:method=>:put}
  map.email_template '/adminpanel/email_template/:id', :controller=>'admin/email_templates',:action=>'show',:conditions=>{:method=>:get}
  map.new_email_template '/adminpanel/email_template/new',:controller=>'admin/email_templates',:action=>'new',:conditions=>{:method=>:get}
  
  map.test_profile'/users/test_profile', :controller=>'users',:action=>'test_profile'
	map.task_upload_files '/tasks/upload_files/:project_id/:id',:controller=>'projects/tasks',:action=>'upload_files',:conditions=>{:method=>:post}
	map.resources :search,:collection => {:previous_month => :get,:next_month =>:get}
	#~ map.resources :users,:collection=>{:update_account=>:post,:change_plan=>:get}
	map.account '/users/:id/account',:controller=>'users',:action=>'account'
  map.resources :projects
	#map.projects ':project_name', :controller => 'projects', :action => 'show' 
  #~ map.projects_path '/projects',:controller=>"projects",:action=>"create",:conditions=>{:method=>:post}
  
  map.test_profile '/users/test_profile',:controller=>"users",:action=>"test_profile"
  
  map.account '/users/account/:id',:controller=>"users",:action=>"account",:conditions=>{:method=>:put}                                             
  map.update_account_users '/users/update_account', :controller=>"users" ,:action=>"update_account",:conditions=>{:method=>:post}   

  
  
  map.not_found '/not_found',:controller=>'home',:action=>'not_found'
	#~ Project.all.each do |project|
		
		#Header Index Links	
		
		map.project_dashboard_index "/:project_name/dashboard/:project_id/", :controller => 'projects/dashboard', :action => 'index' 
		map.project_search_index "/:project_name/search/:project_id", :controller => 'projects/search', :action => 'index' 
		map.project_chat_index "/:project_name/chat/:project_id", :controller => 'projects/chat', :action => 'index' 
		

		map.project_tasks "/:project_name/tasks/:project_id", :controller => 'projects/tasks', :action => 'index' ,:conditions => { :method => :get }

		#map.project_posts "/:project_name/posts/:project_id", {:controller => 'projects/posts', :action => 'index'}
		map.project_files "/:project_name/files/:project_id", :controller => 'projects/files', :action => 'index',:conditions=>{:method=>:get} 
    map.online_user "/:project_name/online_user_card/:project_id",:controller=>"projects",:action=>"online_user_card",:condtitions=>{:method=>:get}
		map.online_user_chat "/projects/chat/:project_id/online_user_card",:controller=>"projects/chat",:action=>"online_user_card",:condtitions=>{:method=>:get}
		map.project_settings "/:project_name/settings/:project_id", :controller => 'projects/dashboard', :action => 'project_settings' 
		map.project_change_settings "/project_change_settings/:id", :controller=>'projects/dashboard', :action=>'change_project_settings'
		#Tasks
		map.task_filter_project_tasks "/:project_name/tasks/task_filter/:project_id",{:controller=>"projects/tasks", :action=>"task_filter"}
		map.change_reorder_page_project_tasks "/:project_name/tasks/change_reorder_page/:project_id",{:controller=>"projects/tasks", :action=>"change_reorder_page"}
		map.new_project_task "/:project_name/tasks/new/:project_id",{:controller=>"projects/tasks", :action=>"new"}
        
    #Posts
		map.new_project_post "/:project_name/posts/new/:project_id", {:controller=>"projects/posts", :action=>"new"}
		
		
		map.project_posts "/:project_name/posts/:project_id", :controller=>"projects/posts", :action=>"index",:conditions => { :method => :get }	
		map.project_posts "/:project_name/posts/:project_id", :controller=>"projects/posts", :action=>"create", :conditions => { :method => :post }
		
		#map.status_filter "/:project_name/posts/:project_id/filter/:status", {:controller=>"projects/posts", :action=>"index", :conditions => { :method => :get }}
		map.history_project_posts "/:project_name/posts/:project_id/history", :controller=>"projects/posts", :action=>"history"	, :conditions => { :method => :get }					
		
		map.project_post "/:project_name/posts/:project_id/:id", {:controller=>"projects/posts", :action=>"show", :conditions => { :method => :get }}						
				
		
		map.download_project_posts "/:project_name/posts/:project_id/download/:id", :controller=>"projects/posts", :action=>"download", :conditions => { :method => :get }
		
		#post comments
		
    map.update_status_path_project_post_comments "/:project_name/posts/comments/update_status_path/:project_id/:post_id", :controller=>"projects/posts/comments", :action=>"update_status_path", :conditions => { :method => :get }
		map.history_display_project_post_comments "/:project_name/posts/comments/history_display/:project_id/:post_id", :controller=>"projects/posts/comments", :action=>"history_display", :conditions => { :method => :get }
		
		
		map.project_post_comments "/:project_name/posts/comments/:project_id/:post_id", :controller=>"projects/posts/comments", :action=>"create", :conditions => { :method => :post }
		map.project_post_comment "/:project_name/posts/comments/:project_id/:post_id/:id", :controller=>"projects/posts/comments", :action=>"show", :conditions => { :method => :get }
		map.project_post_comment "/:project_name/posts/comments/:project_id/:post_id/:id", :controller=>"projects/posts/comments", :action=>"update", :conditions => { :method => :put }
		map.project_post_comment "/:project_name/posts/comments/:project_id/:post_id/:id", :controller=>"projects/posts/comments", :action=>"destroy", :conditions => { :method => :delete }
		
		map.project_edit_post "/:project_name/posts/:project_id/:post_id/update_post", :controller=>"projects/posts", :action=>"edit_post"
		map.project_update_posts "/:project_name/posts/update/:project_id/:id", :controller=>"projects/posts", :action=>"post_update", :conditions => { :method => :post }
		map.delete_post_attachment "/delete_post_attachment", :controller=>"projects/posts", :action=>"delete_post_attachment"
		map.delete_post_comments "/:project_name/posts/:project_id/:id/delete_post_comments", :controller=>"projects/posts", :action=>"delete_post_comments"
		map.subscribe_and_unsubscribe_post "/:project_name/posts/:project_id/:id/subscribe_and_unsubscribe_post", :controller=>"projects/posts", :action=>"subscribe_and_unsubscribe_post"
		
		map.project_edit_comment "/:project_name/posts/:project_id/:post_id/:id/comment_edit", :controller=>"projects/posts/comments", :action=>"edit_comment"
		map.project_update_comment "/:project_name/posts/:project_id/:post_id/:id/comment_update", :controller=>"projects/posts/comments", :action=>"update_comment"
		map.delete_comment_attachment "/delete_comment_attachment", :controller=>"projects/posts/comments", :action=>"delete_comment_attachment"

		map.download_post_project_post "/:project_name/posts/:project_id/:id/download_post", {:controller=>"projects/posts", :action=>"download_post"}
		map.filter_file_project_files "/:project_name/files/:project_id/filter_file", {:controller=>"projects/files", :action=>"filter_file"}
		map.change_select_link_project_files "/:project_name/files/:project_id/change_select_link", {:controller=>"projects/files", :action=>"change_select_link"}
		

		map.edit_user_role "/:project_name/user/:project_id/:user_id",:controller=>'users',:action=>"edit_user_role"
		
		map.new_todo_project_chat "/:project_name/chat/new_todo/:project_id",:controller=>"projects/chat", :action=>"new_todo",:conditions => {:method =>:get}
    
    map.create_todo_project_chat "/:project_name/chat/create_todo/:project_id",:controller=>"projects/chat", :action=>"create_todo",:conditions => {:method =>:post}
		
		map.download_chat_project_chat  "/:project_name/chat/download_chat/:project_id",:controller=>"projects/chat", :action=>"download_chat",:conditions => {:method =>:get}

    
    
    
    
    
    
    
    
    
    
    
    #Task routes

    map.project_tasks "/:project_name/tasks/:project_id",:controller=>"projects/tasks", :action=>"create", :conditions=>{:method => :post}
    
    map.completed_task_project_tasks "/:project_name/tasks/completed_task/:project_id/:id",:controller=>"projects/tasks",:action=>"completed_task",:conditions=>{:method =>:get}
    map.achieved_todo_project_tasks "/:project_name/tasks/achieved_todo/:project_id",:controller=>"projects/tasks",:action=>"achieved_todo",:conditions=>{:method =>:get}
    map.reorder_task_project_tasks "/:project_name/tasks/reorder_task/:project_id",:controller=>"projects/tasks",:action=>"reorder_task",:conditions=>{:method =>:get}
    map.post_comment_project_tasks "/:project_name/tasks/post_comment/:project_id", :controller=>"projects/tasks",:action=>"post_comment",:conditions=>{:method => :post}
    map.download_tasks_project_task "/:project_name/tasks/download_tasks/:project_id/:id",:controller=>"projects/tasks",:action=>"download_tasks",:conditions=>{:method =>:get}
    map.destroy_comment_project_task "/:project_name/tasks/destroy_comment/:project_id/:id",:controller=>"projects/tasks",:action=>"destroy_comment",:conditions=>{:method =>:get}
    map.project_task  "/:project_name/tasks/:project_id/:id",:controller=>"projects/tasks", :action=>"show", :conditions=>{:method => :get}
map.subscribe_and_unsubscribe_task "/:project_name/tasks/:project_id/:id/subscribe_and_unsubscribe_post", :controller=>"projects/tasks", :action=>"subscribe_and_unsubscribe_post"
	map.project_edit_task_comment "/:project_name/tasks/edit_task_comment/:project_id/:id", :controller=>"projects/tasks", :action=>"edit_task_comment"
		map.project_update_task_comment "/:project_name/tasks/update_task_comment/:project_id/:id", :controller=>"projects/tasks", :action=>"update_task_comment"
		map.delete_task_comment_attachment "/delete_comment_attachment", :controller=>"projects/tasks", :action=>"delete_task_comment_attachment"
		map.update_status_path_project_task "/update_todo_status/:project_name/tasks/:project_id/:id",:controller=>"projects/tasks/todos",:action=>"update_status_path",:conditions=>{:method =>:get} 
            
    #Todo routes
    
    map.project_task_todos "/:project_name/tasks/todos/:project_id/:task_id",:controller=>"projects/tasks/todos", :action=>"index",:conditions=>{:method =>:get}
    map.new_project_task_todo "/:project_name/tasks/todos/new/:project_id/:task_id",:controller=>"projects/tasks/todos",:action=>"new",:conditions=>{:method =>:get}
    map.project_task_todos "/:project_name/tasks/todos/:project_id/:task_id",:controller=>"projects/tasks/todos", :action=>"create",:conditions=>{:method =>:post}
    map.project_task_todo "/:project_name/tasks/todos/:project_id/:task_id/:id"  ,:controller=>"projects/tasks/todos",:action=>"show",:conditions=>{:method =>:get}
    map.edit_project_task_todo "/:project_name/tasks/todos/edit/:project_id/:task_id/:id" ,:controller=>"projects/tasks/todos", :action=>"edit",:conditions=>{:method =>:get}
    map.completed_todo_project_task_todos "/:project_name/tasks/todos/completed_todo/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"completed_todo", :conditions=>{:method =>:get}
    map.reorder_todo_project_task_todos "/:project_name/tasks/todos/reorder_todo/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"reorder_todo",:conditions=>{:method =>:get}
    map.download_project_task_todos  "/:project_name/tasks/todos/download/:project_id/:task_id/:id", :controller=>"projects/tasks/todos",:action=>"download",:conditions=>{:method =>:get}
    map.post_comment_project_task_todos "/:project_name/tasks/todos/post_comment/:project_id/:task_id",:controller=>"projects/tasks/todos",:action=>"post_comment",:conditions=>{:method =>:post} 
    map.download_todo_project_task_todo "/:project_name/tasks/todos/download_todo/:project_id/:task_id/:id" ,:controller=>"projects/tasks/todos",:action=>"download_todo",:conditions=>{:method =>:get}
    map.destroy_comment_project_task_todos "/:project_name/tasks/todos/destroy_comment/:project_id/:task_id/:id" ,:controller=>"projects/tasks/todos" ,:action=>"destroy_comment",:conditions=>{:method =>:get}
    map.project_task_todo  "/:project_name/tasks/todos/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"update",:conditions=>{:method =>:put} 
    map.project_task_todo  "/:project_name/tasks/todos/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"destroy",:conditions=>{:method =>:delete} 
		
		map.change_todo_status "/:project_name/tasks/todos/change_todo_status/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"change_todo_status",:conditions=>{:method =>:get} 
		
		map.update_status_path_project_task_todos "/:project_name/tasks/todos/update_todo_status/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"update_status_path",:conditions=>{:method =>:get} 
		
				map.get_history_details_project_task_todos "/get_history_details/:project_name/tasks/todos/:project_id/:task_id/:id",:controller=>"projects/tasks/todos",:action=>"get_history_details",:conditions=>{:method =>:get} 
		
			map.subscribe_and_unsubscribe_todo "/:project_name/tasks/todos/:project_id/:task_id/:id/subscribe_and_unsubscribe_post", :controller=>"projects/tasks/todos", :action=>"subscribe_and_unsubscribe_post"
			
		map.project_edit_todo_comment "/:project_name/tasks/todos/edit_todo_comment/:project_id/:task_id/:id", :controller=>"projects/tasks/todos", :action=>"edit_todo_comment"
		map.project_update_todo_comment "/:project_name/tasks/todos/update_todo_comment/:project_id/:task_id/:id", :controller=>"projects/tasks/todos", :action=>"update_todo_comment"
		map.delete_todo_comment_attachment "/delete_comment_attachment", :controller=>"projects/tasks/todos", :action=>"delete_todo_comment_attachment"
		

    #File Routes
    
    map.download_selected_file_project_files  "/:project_name/files/download_selected_file/:project_id",:controller=>"projects/files",:action=>"download_selected_file",:conditions=>{:method=>:get}
    map.project_files "/:project_name/files/:project_id",:controller=>"projects/files",:action=>"create",:conditions=>{:method =>:post}


    #Chat Routes
    
    map.project_chat_index "/:project_name/chat/:project_id",:controller=>"projects/chat",:action=>"index",:conditions=>{:method =>:get}
    map.project_chat_popout "/:project_name/chat-popout/:project_id",:controller=>"projects/chat",:action=>"chat_popout",:conditions=>{:method =>:get}
    







		
	#~ end

  #~ map.resources :projects, :controller=>'projects', :collection =>{:invite_people => :post,:update_user_role=>:put},:member=>{:invite_people=>:post} do |project|
    #~ project.resources :tasks,:controller => 'projects/tasks',:collection=> {:post_comment => :post,:change_reorder_page => :get,:reorder_task =>:get,:completed_task => :get,:achieved_todo => :get,:task_filter => :get},:member => {:destroy_comment => :get,:download_tasks=>:get} do |task|
			#~ task.resources :todos,:controller => 'projects/tasks/todos',:collection=> {:post_comment => :post,:completed_todo => :get,:reorder_todo =>:get,:make_uncomplete => :get,:destroy_comment => :get,:update_status_path => :get,:get_history_details => :get,:download => :get},:member=>{:download_todo=>:get}
     #~ end

  #~ project.resources :chat, :controller=>'projects/chat',:collection=>{:download_chat=>:get,:new_todo => :get,:create_todo => :post,:message=>:post}


  #~ map.resources :projects, :controller=>'projects', :collection =>{:invite_people => :post,:update_user_role=>:put},:member=>{:invite_people=>:post} do |project|
    #~ project.resources :tasks,:controller => 'projects/tasks',:collection=> {:post_comment => :post,:change_reorder_page => :get,:reorder_task =>:get,:completed_task => :get,:achieved_todo => :get,:task_filter => :get},:member => {:destroy_comment => :get,:download_tasks=>:get} do |task|
			#~ task.resources :todos,:controller => 'projects/tasks/todos',:collection=> {:post_comment => :post,:completed_todo => :get,:reorder_todo =>:get,:make_uncomplete => :get,:destroy_comment => :get,:update_status_path => :get,:get_history_details => :get,:download => :get},:member=>{:download_todo=>:get}

     #~ end    
		#~ project.resources :posts,:controller => 'projects/posts',:collection=>{:history => :get,:download => :get},:member=>{:download_post=>:get}  do |post|
		#~ post.resources :comments, :controller => 'projects/posts/comments',:collection => {:history_display => :get,:update_status_path => :get}
     #~ end

        #~ project.resources :chat, :controller=>'projects/chat',:collection=>{:download_chat=>:get,:new_todo => :get,:create_todo => :post}

		#~ project.resources :dashboard, :controller=>'projects/dashboard'

	

  #~ end
  #~ map.resource :session
	
	map.my_tasks '/my-tasks', :controller=>'my_tasks', :action=>'index'
	
	map.new_my_task '/new_my_task', :controller=>'my_tasks', :action=>'new_my_task'
	map.create_my_task '/create_my_task', :controller=>'my_tasks', :action=>'create_my_task'
	map.new_my_todo '/new_my_todo', :controller=>'my_tasks', :action=>'new_my_todo'
	map.create_my_todo '/create_my_todo', :controller=>'my_tasks', :action=>'create_my_todo'
	map.edit_my_todo '/edit_my_todo', :controller=>'my_tasks', :action=>'edit_my_todo'
	map.update_my_todo '/update_my_todo', :controller=>'my_tasks', :action=>'update_my_todo'
	map.delete_my_todo '/delete_my_todo', :controller=>'my_tasks', :action=>'delete_my_todo'
	map.completed_todo_my_task '/completed_todo_my_task', :controller=>'my_tasks', :action=>'completed_todo_my_task'
	map.achieved_my_todo '/achieved_my_todo', :controller=>'my_tasks', :action=>'achieved_my_todo'
	map.change_mytodo_status '/change_mytodo_status', :controller=>'my_tasks', :action=>'change_mytodo_status'
	map.completed_mytask '/completed_mytask', :controller=>'my_tasks', :action=>'completed_mytask'
	map.mytask_filter '/mytask_filter', :controller=>'my_tasks', :action=>'mytask_filter'
	map.reorder_mytask '/reorder_mytask', :controller=>'my_tasks', :action=>'reorder_mytask'
	map.change_reorder_mytask_page '/change_reorder_mytask_page', :controller=>'my_tasks', :action=>'change_reorder_mytask_page'
	map.show_my_task '/show_my_task', :controller=>'my_tasks', :action=>'show_my_task'
	map.post_my_task_comment '/post_my_task_comment', :controller=>'my_tasks', :action=>'post_my_task_comment'
	map.download_my_task '/download', :controller=>'my_tasks', :action=>'download'
	map.destroy_mytask_comment '/destroy_mytask_comment', :controller=>'my_tasks', :action=>'destroy_mytask_comment'	
	map.edit_mytask_comment '/edit_mytask_comment', :controller=>'my_tasks', :action=>'edit_mytask_comment'	
	map.update_mytask_comment '/update_mytask_comment', :controller=>'my_tasks', :action=>'update_mytask_comment'	
	map.reorder_mytodo '/reorder_mytodo', :controller=>'my_tasks', :action=>'reorder_mytodo'
	
		map.show_my_tasklist '/show_my_tasklist', :controller=>'my_tasks', :action=>'show_my_tasklist'
		map.post_my_tasklist_comment '/post_my_tasklist_comment', :controller=>'my_tasks', :action=>'post_my_tasklist_comment'
		map.destroy_mytasklist_comment '/destroy_mytasklist_comment', :controller=>'my_tasks', :action=>'destroy_mytasklist_comment'	
		map.edit_mytasklist_comment '/edit_mytasklist_comment', :controller=>'my_tasks', :action=>'edit_mytasklist_comment'	
		map.update_mytasklist_comment '/update_mytasklist_comment', :controller=>'my_tasks', :action=>'update_mytasklist_comment'		
		
	map.status_filter '/:project_name/posts/:project_id/filter/:status' ,:controller=>'projects/posts', :action=>'index'
	map.status_update '/status_update/:post_id/:status', :controller=>'projects/posts', :action=>'status_update'	
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.session '/session',:controller=>'sessions',:action=>'create',:conditions=>{:method=>:post}
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.activate '/invite/:invitation_code', :controller => 'projects', :action => 'join_from_invite'
	map.forgot    '/forgot', :controller => 'users', :action => 'forgot'
  map.reset '/reset/:reset_code', :controller => 'users', :action => 'reset'
  
  
  

  map.online_user '/projects/:project_id/online_user_card',  :controller=>'projects', :action=>'online_user_card'
  map.online_user_global '/home/online_user_card',  :controller=>'home', :action=>'online_user_card'
  map.file_upload '/chat/:project_id/file_upload', :controller=>'projects/chat', :action=>'file_upload'
	map.file_download_email '/home/file_download_from_email/:id', :controller=>'home', :action=>'file_download_from_email'
  
  
  
  #User routes
  map.edit_user '/profile/:id',:controller=>"users",:action=>"edit",:conditions=>{:method=>:get}

  map.resources :users,:collection=>{:update_account=>:post,:change_plan=>:get,:close_account=>:get,:download_billing_history=>:get}

  map.resend_activation '/activationemail',:controller=>"users",:action=>"resend_activation",:conditions=>{:method=>:get}
  map.resend_activation '/activationemail',:controller=>"users",:action=>"resend_activation",:conditions=>{:method=>:post}
  map.reset_password '/resetpassword/:reset_code',:controller=>"users",:action=>"reset_password",:conditions=>{:method=>:get}
  map.change_password '/changepassword/:id',:controller=>"users",:action=>"change_password",:conditions=>{:method=>:post}
  map.update '/update', :controller=>'users',:action=>'update'
  map.invite_signup '/invite-signup',:controller=>"users",:action=>"invite_signup",:conditions=>{:method=>:get}
  

		#Admin routes
       map.adminpanel'/adminpanel',:controller=>'admin',:action=>'login'	
	map.adminlogout'/adminlogout',:controller=>'admin',:action=>'logout'	
	map.adminforgot '/adminforgot',:controller=>'admin',:action=>'forgot'
	 map.adminreset '/adminreset/:reset_code_admin', :controller => 'admin', :action => 'reset'
	map.summary '/adminpanel/summary',:controller=>'admin/summary',:action=>'summary'
	map.usermangmt '/adminpanel/usermanagement',:controller=>'admin/usermanagement',:action=>'usermanagement'
	map.projectmangmt '/adminpanel/projectmanagement',:controller=>'admin/projectmanagement',:action=>'projectmanagement'
	map.plans '/adminpanel/plans',:controller=>'admin/planmanagement',:action=>'plans'
	map.admin_create '/admin/create',:controller=>'admin',:action=>'create'
	map.download_csv '/adminpanel/usermanagement/download', :controller=>'admin/usermanagement',:action=>'download_csv'
	
  map.admin_change_plan '/admin/usermanagement/change_plan/:user_id/:plan_id',:controller=>'admin/usermanagement',:action=>'change_plan'
	map.admin_project_status '/admin/projectmanagement/project_status', :controller=>'admin/projectmanagement', :action=>'project_status'
	map.admin_user_status '/admin/usermanagement/user_status_edit', :controller=>'admin/usermanagement', :action=>'user_status_edit'
	
		map.admin_user_sorting '/admin/user/sorting', :controller=>'admin/usermanagement',:action=>'sorting_user'
	map.admin_project_sorting '/admin/project/sorting', :controller=>'admin/projectmanagement',:action=>'sorting_project'
	map.admin_plan_sorting '/admin/plan/sorting', :controller=>'admin/planmanagement',:action=>'sorting_plan'
	
	map.download_project_csv '/adminpanel/projectmanagement/download', :controller=>'admin/projectmanagement',:action=>'download_project_csv'
	map.download_plan_csv '/adminpanel/planmanagement/download', :controller=>'admin/planmanagement',:action=>'download_plan_csv'
	
	#Home Controller
	map.root :controller=>"home"
  map.complete_profile '/complete_profile',:controller=>"home",:action=>"complete_profile",:conditions=>{:method=>:put}
  map.late_tasks '/late_tasks',:controller=>'home',:action=>'late_tasks',:conditions=>{:method=>:get}
  map.task_in_progress '/task_in_progress',:controller=>'home',:action=>'task_in_progress',:conditions=>{:method=>:get}
  map.pending_tasks '/pending_tasks',:controller=>'home',:action=>'pending_tasks',:conditions=>{:method=>:get}
  map.new_posts '/new_posts',:controller=>'home',:action=>'new_posts',:conditions=>{:method=>:get}
  map.new_comments '/new_comments',:controller=>'home',:action=>'new_comments',:conditions=>{:method=>:get}
	map.all_projects '/all-projects',:controller=>'home',:action=>'all_projects',:conditions=>{:method=>:get}
	
	#Chat controller routes
	map.connect '/chat', :controller=>"chat", :action=>"chat"
  #~ map.message_project_chat '/'
	
  #Global dashboard routes
  map.connect '/global',:controller=>"home",:action=>"global_dashboard"
  map.more_history '/more_history',:controller=>"home",:action=>"more_history"
  
	#Footer Controller Routes
	map.connect '/faq', :controller=>"footer", :action=>"faq"
	map.connect '/privacy', :controller=>"footer", :action=>"privacy"
	map.connect '/terms', :controller=>"footer", :action=>"terms"
  
  
  #Chat Routes
   #map.chat '/projects/:project_id/chat', :controller=>'/projects/chat', :action=>'index'
   map.store_message '/chat/store_message', :controller=>'/projects/chat', :action=>'store_message'
   map.message_project_chat '/:project_name/chat/message/:project_id',:controller=>'projects/chat',:action=>'message',:conditions=>{:method=>:post}
   # Project Routes
   map.connect '/:url', :controller=>'projects', :action=>'index'
   #~ map.connect '/projects/:project_id/people', :controller=>'projects', :action=>'people'
   
   


	map.invite '/:project_name/invite_people/:project_id', :controller=>'projects', :action=>'invite'
	map.invite_people_project '/:project_name/:project_id/invite_people', :controller=>'projects', :action=>'invite_people'
	map.new_user_invite '/:project_name/:project_id/new_user_invite', :controller=>'projects', :action=>'new_user_invite'


  
  map.invite_people '/projects/invite/:project_id', :controller=>'projects', :action=>'invite_people',:conditions=>{:method=>:post}
  map.previous_month '/dashboard/:project_id/previous_month', :controller=>'projects/dashboard', :action=>'previous_month'
  map.next_month '/dashboard/:project_id/next_month', :controller=>'projects/dashboard', :action=>'next_month'
  map.show_event '/dashboard/:project_id/show_event', :controller=>'projects/dashboard', :action=>'show_event'
  map.more_histroy_project '/dashboard/:project_id/more_history', :controller=>'projects/dashboard', :action=>'more_history_project'
  map.subscribe '/chat/subscribe',:controller=>'projects/chat',:action=>'subscribe'
  map.unsubscribe '/chat/unsubscribe',:controller=>'projects/chat',:action=>'unsubscribe'
  
  map.project_late_tasks '/:project_name/late_tasks/:project_id',:controller=>"projects/dashboard",:action=>"late_tasks",:conditions=>{:method=>:get}
  map.project_task_in_progress '/:project_name/task_in_progress/:project_id',:controller=>"projects/dashboard",:action=>"task_in_progress",:conditions=>{:method=>:get}
  map.project_pending_tasks '/:project_name/pending_tasks/:project_id',:controller=>"projects/dashboard",:action=>"pending_tasks",:conditions=>{:method=>:get}
  map.project_new_posts '/:project_name/new_posts/:project_id',:controller=>"projects/dashboard",:action=>"new_posts",:conditions=>{:method=>:get}
  map.project_new_comments '/:project_name/new_comments/:project_id',:controller=>"projects/dashboard",:action=>"new_comments",:conditions=>{:method=>:get}

  
  #project routes
  
     map.project_people '/:project_name/people/:project_id', :controller=>'projects', :action=>'people'
		 
		 map.email_notification '/email/:token', :controller=>'home', :action=>'email_notify'		 
		 
		 map.email_reply  '/home/email_reply', :controller=>'home', :action=>'check_email_reply_and_save'		 
		 
		 map.recurly_notification '/users/recurly/notification', :controller=>'users', :action=>'recurly_notification'
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

	
  
  
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
	

end
