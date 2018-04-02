# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
load File.join(RAILS_ROOT, Dir["vendor/gems/tarantula-*/tasks/*.rake"])


 namespace :utils do
 desc "Email notification for the task,todo,comment creation"
  task(:email_notification=>:environment) do
			Todo.send_mail_to_todo_assignee
			Post.send_email_notify_to_post_creation
			Comment.send_email_notification_for_comment_creation
		end
	desc "Chat log creation"
  task(:chat_log=>:environment) do
		Project.find_chat_logs
  end
  
  desc "Add default values to the Email templates"
  task(:default_email_contents=>:environment) do
    Admin::EmailTemplate.add_default_values
  end
	
	  desc "Change the status of late todos, delete or suspend the out of date projects and send emails on usage exceed"
  task(:late_todos_and_delete_suspend_project_and_mail_on_usage_exceed=>:environment) do
    Todo.change_status_todo #for changing the status of late todos
		Project.project_suspend_and_delete #for deleting and suspending the projects when the billing date crosses
  end


	
end