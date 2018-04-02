module Admin::ProjectmanagementHelper
  def project_status(status)
		if status==true
			"Active"
		else
			"Suspend"
		end
	end
  
  def bandwidth_in_gb(value)
    (value/1024.0).round(2)
  end
end
