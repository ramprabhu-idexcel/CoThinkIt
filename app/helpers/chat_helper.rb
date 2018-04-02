module ChatHelper
	def message_formation(chat_record)
    chat =""
    chat= chat + "<p>#{CGI.escapeHTML(chat_record.message.strip)}</p>"  if  chat_record.message
    file_att =""
    img_att = ""
    for attachment in chat_record.attachments			  
      attachment_content_type = find_attachment_content_type(attachment)
      if attachment_content_type == "image"				
        img_att= img_att + form_image_url(attachment)
      else		
        file_att= file_att +  "<li style=\"background-image: url('/images/doctype_icons/#{pass_icon_filename(attachment.content_type)}');\"> <a href=\"/projects/#{@project.id}/posts/download?id=#{attachment.id}\" >#{attachment.filename}</a></li>"
      end							
    end	 
    chat= chat + '<ul class="file-list">' +file_att+'</ul>'	if !file_att.blank?
    chat= chat  + img_att if !img_att.blank?
    chat
	end	 

	def form_image_url(attachment)
    if RAILS_ENV=="development"  
      '<a href="'+attachment.public_filename+'" > <img src= "'+attachment.public_filename+'" class="frame"></a>'			
    else
      '<a href="http://s3.amazonaws.com/cothink-production/public/attachments/'+attachment.id.to_s+'/'+attachment.filename+'" > <img src= "http://s3.amazonaws.com/cothink-production/public/attachments/'+attachment.id.to_s+'/'+attachment.filename+'" class="frame"></a>'						
    end			
	end	 
  
  def user_color(user)
    user.color_code.nil? ? "ffffff" : user.color_code
  end
  
  def chat_shade(user_id)
    @alt=="" ? @alt="alt" : @alt="" unless @user_id==user_id
    @alt
  end
end
