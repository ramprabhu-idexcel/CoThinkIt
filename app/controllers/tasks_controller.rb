class TasksController < ApplicationController
	layout 'base'
	def index
	end	
	
	def new
		@task = Task.new		
	end

  def create
		@task = Task.new(params[:task])
		render :update do |page|
			if @task.save
				page.redirect_to tasks_path
			else
				for each_error in @task.errors.entries
					page.replace_html 'task_title_error',each_error[1] if each_error[0] == "title"
				end	
			end	
		end
	end
	
	def change_reorder_page
		@tasks = @project.tasks
		render :update do |page|
			page.replace_html 'tasks_list',:partial => "reorder_tasks"
		end	
	end

  def reorder_task
	end
	
end
