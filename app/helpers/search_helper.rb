module SearchHelper
	def count_days_record_result
		count = @posts.length + @comments.length+ @files.length
		array = ['@posts','@comments','@files']
		first = []
		last = []
		if count > 0
			for each_re in array
				if eval(each_re).length >1
					 first << eval(each_re).first.created_at
					 last  << eval(each_re).last.created_at
				elsif eval(each_re).length > 0
					 first << eval(each_re).first.created_at
					 last  << eval(each_re).first.created_at
				end	
			end	
			first_date = first.sort.first
			last_date = last.sort.last
			day_different =  (Date.new(last_date.year,last_date.month,last_date.day)+1.day - Date.new(first_date.year,first_date.month,first_date.day)).to_i		
      display_day =  	day_different > 1 ? " over #{day_different} days" : 	" over #{day_different} day"	
			result_display = count > 1 ?  " #{count} results" : 	" 1 result"	
		  @result_display = "<strong>#{result_display}</strong> <em>#{display_day}</em>"	
		else
			@result_display = "<em> No Result</em>"
		end	
	end		
end
