class TokenizedUrl < ActiveRecord::Base
  belongs_to :project
  
  def site_address
    token_project.owner.site_address if token_project && token_project.owner && token_project.owner.site_address
  end
  
  def token_project
    project ? project : find_token_project
  end
  
  def find_project_id
    path=asssigned_url[1..-1].split('/tasks/todos/')
    path.count>1 ? path[1].split('/')[0] : asssigned_url[1..-1].split('/posts/')[1].split('/')[0]
  end
  
  def find_token_project
    Project.find_by_id find_project_id
  end
end
