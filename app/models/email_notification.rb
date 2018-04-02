class EmailNotification < ActiveRecord::Base
		belongs_to :user
	  belongs_to :resource, :polymorphic => true	
		
	def self.subscribe_list(resource, notifications,user_id)
		if notifications!=user_id
		notifications=notifications.split(',')
		notifications.each do |notify|		
			is_existing=EmailNotification.find_by_resource_id_and_resource_type_and_user_id(resource.id,"Post",notify)
			if !is_existing && notify!=user_id
				email_notification = EmailNotification.new
				email_notification.resource = resource
				email_notification.user_id = notify
				email_notification.is_notify=true
				email_notification.save
			end
	  end
		else
		is_mine_existing=EmailNotification.find_by_resource_id_and_resource_type_and_user_id(resource.id,"Post",user_id)
			if !is_mine_existing
				email_notification = EmailNotification.new
				email_notification.resource = resource
				email_notification.user_id = user_id
				email_notification.is_notify=true
				email_notification.save
			end
		end
	end
	
		def self.subscribe_list_for_todo(resource, notifications,user_id)
			
			
			
			if !notifications.empty?
		notifications.each do |notify|		
			is_existing=EmailNotification.find_by_resource_id_and_resource_type_and_user_id(resource.id,"Todo",notify.user_id)
			
			if !is_existing && notify.user_id!=user_id
				email_notification = EmailNotification.new
				email_notification.resource = resource
				email_notification.user_id = notify.user_id
				email_notification.is_notify=true
				email_notification.save
			end
	  end
		end
			
		is_mine_existing=EmailNotification.find_by_resource_id_and_resource_type_and_user_id(resource.id,"Todo",user_id)
			if !is_mine_existing
				email_notification = EmailNotification.new
				email_notification.resource = resource
				email_notification.user_id = user_id
				email_notification.is_notify=true
				email_notification.save
		
		end
		end
end
