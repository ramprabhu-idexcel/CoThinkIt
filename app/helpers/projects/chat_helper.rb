module Projects::ChatHelper

	def message_formation(chat_record,options={})
			chat =""
			chat= chat + "<p>#{chat_record.message}</p>"  if  chat_record.message
			file_att =""
			img_att = ""
			for attachment in chat_record.attachments			  
					attachment_content_type = find_attachment_content_type(attachment)
					if attachment_content_type == "image"			
							img_att= img_att + (options[:main] ? form_image_url(attachment) : form_popout_image_url(attachment))
					else		
							file_att= file_att +  "<li style=\"background-image: url('/images/doctype_icons/#{pass_icon_filename(attachment.content_type)}');\"> <a href=\"/#{@project.url}/posts/#{@project.id}/download/#{attachment.id}\"  >#{attachment.filename}</a></li>"
					end							
			end	 
			chat= chat + '<ul class="file-list">' +file_att+'</ul>'	if !file_att.blank?
			chat= chat  + img_att if !img_att.blank?

			chat
	end	 

	def form_image_url(attachment)
			thumbnail=Attachment.find_by_parent_id_and_thumbnail(attachment.id,"big")
			file= (attachment.width>645 && thumbnail )  ? thumbnail : attachment
			if RAILS_ENV=="development"  
					'<a href="'+attachment.public_filename+'" target="_new"> <img src= "'+file.public_filename+'" class="frame"></a>'			
			else
        "<a href='http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{attachment.filename}'> <img src= 'http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{file.filename}' class='frame'></a>"
			end			
    end	 
    
  def form_popout_image_url(attachment)
    if RAILS_ENV=="development"  
      '<a href="'+attachment.public_filename+'" > <img src= "'+attachment.small_thumbnail+'" class="frame"></a>'			
    else
      "<a href='http://s3.amazonaws.com/#{S3_CONFIG[:bucket_name]}/public/attachments/#{attachment.id.to_s}/#{attachment.filename}'> <img src= '#{attachment.small_thumbnail}' class='frame'></a>"
    end	
  end
end
