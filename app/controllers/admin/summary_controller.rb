class Admin::SummaryController < AdminController
	#~ before_filter :admin_login_required
	
	 layout "admin"
	
	def summary
		 #storage and bandwidth
		@storage=0
		@bandwidth=0
		@plans=MonthLimit.find:all
		count=@plans.count
	         if count!=0
			sy=@plans.first.year
			ey=@plans.last.year 
			sm=@plans.first.month
			em=@plans.last.month
			if sy==ey
				@duration=(em-sm)+1
			else
				years=(ey-sy)-1
				months=years*12
				prev_month=MonthLimit.last.month
				@duration=months+(13-sm)+prev_month
			end

				@plans.each do |record|
				date=record.created_at.month
				year=record.created_at.year
					if date==Time.now.month && year==Time.now.year
						val = (record.bandwidth.nil?) ? 0 : record.bandwidth
						download=val
		      end
				 end	  
				 @month_limit=MonthLimit.find_by_month_and_year(Time.now.month, Time.now.year)
				 if @month_limit
					 @storage=@storage+@month_limit.storage
					 @bandwidth=@bandwidth+@month_limit.bandwidth
					 @storage=@storage.to_i
					 @bandwidth=@bandwidth.to_i
				end
	         end
        end
	
end
