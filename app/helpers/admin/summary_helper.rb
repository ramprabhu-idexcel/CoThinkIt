module Admin::SummaryHelper

	def current_month(record)
		count=0
		date=record.created_at.month
		year=record.created_at.year
		     if date==Time.now.month && year==Time.now.year
			     count=count+1
		     end
		count		 
	end
	     
	def total_duration(first,last)
		
sy=first.created_at.year
			ey=last.created_at.year 
			sm=first.created_at.month
			em=last.created_at.month
			if sy==ey
				duration=(em-sm)+1
			else
				years=(ey-sy)-1
				months=years*12
				prev_month=MonthLimit.last.month
				duration=months+(13-sm)+prev_month
			end

		
        end
	def user_at_plan(user)
		count=0
                    user_at_plan=BillingInformation.find_by_user_id(user.id)
		    if user_at_plan
			    count=count+1
		    end
        end
end
