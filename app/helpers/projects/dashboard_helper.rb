module Projects::DashboardHelper
  def display_time(todo)
    time_zone=find_time_zone						
		time = todo.created_at.gmtime+find_current_zone_difference(time_zone)
  end
end
