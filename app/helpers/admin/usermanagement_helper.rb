module Admin::UsermanagementHelper
require 'recurly' 

 def user_plan(user)
	 
    plan=Plan.find_by_id(user.plan_id)
     if plan
      plan.name
    end
		
	end
	
	def user_status(status)
		if status==true
			"Active"
		elsif status == false
			"Suspend"
			else
				"Delete"
		end
		
	end

end
