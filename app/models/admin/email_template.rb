require 'erb'
class Admin::EmailTemplate < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  validates_presence_of :from,:message=>"Error! From field is empty!"
  validates_presence_of :subject,:message=>"Error! Subject field is empty!"
  validates_presence_of :content,:message=>"Error! Content field is empty!"
  validate :valid_from_address
  
  def mail_content
    self.content.gsub!("&lt;","<")  
    self.content.gsub!("&gt;",">")  
    self.content.gsub!("&amp;","&")  
    self.content.gsub!("&nbsp;"," ")
    self.content
  end
  
  def create_mail
    ERB.new(self.mail_content).result(binding)
  end
  
  def self.add_default_values
    self.default_values.each do |key,content|
      email_template=Admin::EmailTemplate.find_or_create_by_key(key)
      email_template.update_attributes(content)
    end
  end
    
  def self.default_values
    {
     "Close Account"=>close_account,
     "Invitation"=>invitation,
     "New Member Invitation"=>new_member_invitation,
     "New Post"=>new_post,
     "Password Reset Admin"=>password_reset_admin,
     "Payment Failed"=>payment_failed,
     "Plan Changed"=>plan_changed,
     "Post Comment"=>post_comment, 
     "Reset Password"=>reset_password,
     "Signup"=>signup,
     "Storage Bandwidth Exceed"=>storage_bandwidth,
     "Todo Assigned"=>todo_assigned,
     "Todo Comment"=>todo_comment
   }
  end
  
  def self.new_post
    attach=Attachment.new
     {:content=>%Q{<p>-- Reply ABOVE THIS LINE to add a comment to this message-- <br><br> &lt;%=@post_creater%&gt; wrote:<br><br> &lt;%= @post.content %&gt; <br></p><p>&lt;%if @post.attachments &amp;&amp; !@post.attachments.empty?%&gt;Files: 	&lt;%@post.attachments.each_with_index do |attach,index|%&gt;&nbsp; <a href="<%=APP_CONFIG[:site_url]%>/home/file_download_from_email/%3C%=attach.id%%3E">&lt;%=attach.filename%&gt;</a> <span>&lt;%=!attach.size.nil? ?  "()" :  ""%&gt;</span><br> &lt;%end%&gt; &lt;%end%&gt; <br> View Post: &lt;%=@url%&gt;<br><br> --<br> Delivered by co&middot;think&middot;it</p>},
      :from=>'"Cothinkit <notifications@cothinkit.com>"',
      :subject=>'"[#{@project_name}] There\'s a new post! "'
    }
  end
  
  def self.activation
    {:content=>%Q{<p>&lt;%= @user.login %&gt;, your account has been activated.&nbsp; Welcome aboard!<br /><br />&nbsp; &lt;%= @url %&gt;</p>},
    :from=>'"Cothinkit <noreply@cothinkit.com>"',
    :subject=>"Your account has been activated!"
    }
  end
  
  def self.close_account
    {:content=>%Q{<p>Hi &lt;%= @first_name%&gt;,<br><br>At your request, we've deleted your account and all projects you own. We're sorry to see you go and hope you'll think about coming back in the future.<br><br>Please let me know if there is something co&middot;think&middot;it could do better or change that might change your mind! We wish you all the best and hope to see you back soon!<br><br>Best,<br><br>Jesse Ma<br>Founder of co&middot;think&middot;it<br><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br>@cothinkit<br><br>--<br>Collaborating is just easier with co&middot;think&middot;it!</p>},
        :from=>'"Cothinkit <noreply@cothinkit.com>"',
        :subject=>'"Your Cothinkit Account Has Been Deleted!"'
    }
  end
  
  def self.invitation
    {:content=> %Q{<p>Hi &lt;%= @recipient_name%&gt;:<br><br>Please click the link below to join the &lt;%=@project_name%&gt; project:<br><br>&lt;%= @url%&gt;<br><br>If you're not a member of co&middot;think&middot;it yet, you'll have to sign up, Don't worry its fast and FREE.</p><p>Questions, comments, or need help getting started? Email us at team@cothinkit.com and we'd love to hear from you!<br><br>Best,<br><br>Team co路think路it<br><a target="_blank" href="mailto:team@cothinkit.com">team@cothinkit.com</a><br>@cothinkit<br><br>--<br>Collaborating is just easier with co路think路it!</p>},
    :from=>'"Cothinkit <noreply@cothinkit.com>"',
    :subject=>'"#{@inviter_name} invited you to join the #{@project_name} Project on cothinkit!"'
    }
  end
  
  def self.todo_comment
    attach=Attachment.new
    {:content=> %Q{<p>--Reply ABOVE THIS LINE to add a comment to this message-- <br /><br />Hi &lt;%=@user.first_name.capitalize%&gt;: <br /><br />&lt;%=@creater.first_name.capitalize%&gt; added the following comment: <br /><br />&lt;%= @comment.comment%&gt;</p>
<p>&lt;%@comment.attachments.each_with_index do |attach, index|%&gt;&lt;img src="&lt;%= APP_CONFIG[:site_url] %&gt;&lt;%= @icon[index] %&gt;"&gt;&lt;a href="&lt;%=APP_CONFIG[:site_url]%&gt;/home/file_download_from_email/&lt;%=attach.id%&gt;"&gt;&lt;%=attach.filename%&gt;&lt;/a&gt;&lt;span&gt;&lt;%=!attach.size.nil? ?&nbsp; "(#{number_to_human_size(attach.size)})" :&nbsp; ""%&gt;&lt;/span&gt;&lt;/img&gt;</p>
<p>&lt;%end if @comment.attachments &amp;&amp; !@comment.attachments.empty?%&gt; <br /><br />Click the following link to view the comment: &lt;%=@url%&gt; <br /><br /><br />Delivered by co&middot;think&middot;it</p>},
:from=>'"#{@creater_first_name} #{@creater_last_name}<notifications@cothinkit.com>"',
:subject=>'"#{project.name}: There\'s a new comment by #{@creater_first_name} on \'#{@todo.title}\' on co穞hink穒t!"'
    }
  end
  
  def self.post_comment
    attach=Attachment.new
     {:content=>%Q{<p>--Reply ABOVE THIS LINE to add a comment to this message--<br><br>&lt;%=@creater.first_name.capitalize%&gt; added the following comment: <br><br>&lt;%= @comment.comment %&gt;<br><br>&lt;%if @comment.attachments &amp;&amp; !@comment.attachments.empty?%&gt;Files:<br>&nbsp;&nbsp; &nbsp;&lt;%@comment.attachments.each_with_index do |attach, index|%&gt;<br>&nbsp;&nbsp; &nbsp;&lt;img src="&lt;%= APP_CONFIG[:site_url] %&gt;&lt;%= @icon[index] %&gt;"&gt;<br>&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&lt;a href="&lt;%=APP_CONFIG[:site_url]%&gt;/home/file_download_from_email/&lt;%=attach.id%&gt;"&gt;&lt;%=attach.filename%&gt;&lt;/a&gt;<br>&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&lt;span&gt;&lt;%=!attach.size.nil? ?&nbsp; "()" :&nbsp; ""%&gt;&lt;/span&gt;&lt;/img&gt;<br>&nbsp;&nbsp; &nbsp;&lt;%end%&gt;<br>&lt;%end%&gt; <br><br>View Comment:&nbsp; &lt;%=@url%&gt;<br><br>--<br>Delivered by co&middot;think&middot;it</p>},
     :from=>'"Cothinkit <notifications@cothinkit.com>"',
     :subject=>'"[#{@project_name}]: There\'s a new comment on \'#{@title}\'"'
    }
  end
  
  def self.todo_assigned
    {:content=> %Q{<p>--Reply ABOVE THIS LINE to add a comment to this message--<br /><br /><br />Hi &lt;%=@user.first_name.capitalize%&gt;,<br /><br />You've been assigned a new to-do for the '&lt;%=@project_name%&gt;' Project by &lt;%=@creater.first_name.capitalize%&gt; on co&middot;think&middot;it!<br /><br />&lt;%=@todo.title.capitalize%&gt;<br /><br /><br />Due by: &lt;%=(!@todo.due_date.nil? and !@todo.due_date.blank?) ? @todo.due_date.strftime("%A, %B %e, %Y") : 'N/A'%&gt;<br /><br /><br />Click the following to view the to-do: &lt;%=@url%&gt;<br /><br />--<br />Delivered by co&middot;think&middot;it</p>},
    :from=>'"#{@todo_first_name} #{@todo_last_name}<notifications@cothinkit.com>"',
    :subject=>'"#{@project_name}: You\'ve been assigned a new to-do by #{@todo_first_name} on co穞hink穒t"'
    }
    
  end
  
  def self.signup
     {:content=>%Q{<p>Hi &lt;%= @recipient_name%&gt;:<br></p><p>Please click the activation link below to activate your account!<br><br>&lt;%= @url%&gt;<br><br>Questions, comments, or need help getting started? Email us, we'd love to hear from you!<br><br>Best,<br><br>Team co&middot;think&middot;it<br>team@cothinkit.com<br>@cothinkit<br><br>--<br>Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"Cothinkit <noreply@cothinkit.com>"',
     :subject=>'"Your Cothinkit Activation Link!"'
    }
  end 
  
  def self.new_member_invitation
    {:content=>%Q{<p>Hi &lt;%= @recipient_name%&gt;:<br><br>You've been invited to join the &lt;%= @project_name%&gt; Project on cothinkit by &lt;%= @inviter_name%&gt;! <br><br><br>Please click the link below to join the project:<br><br>&lt;%= @url%&gt;<br><br>If you're not a member of co&middot;think&middot;it yet, you'll have to sign up, but don't worry, it takes less than a minute to join. If you're already part of the co&middot;think&middot;it community, you're all set to go!<br><br>Questions, comments, or need help getting started? Email me or our Support Team at <a target="_blank" href="mailto:support@cothinkit.com">support@cothinkit.com</a> and we'll get back to you!<br><br>Best of luck on your project and thanks for using co&middot;think&middot;it!<br><br>Sincerely,<br><br>Jesse Ma<br>Founder of co&middot;think&middot;it<br><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br>@cothinkit<br><br>--<br>Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"Cothinkit <noreply@cothinkit.com>"',
     :subject=>'"#{@inviter_name} invited you to join the #{@project_name} Project on cothinkit!"'
    }
  end
  
  def self.reset_password
    {:content=>%Q{<p>Hi &lt;%= @user.first_name.capitalize %&gt;:<br><br>Forgot your password? Don't worry I do it all the time and it's actually a good idea to change your password from time to time anyways!<br><br></p><p>Please click the link below to reset your password:</p><p>&nbsp;&lt;%= @url %&gt;<br><br>Questions, comments, or need help in getting started? Email us at team@cothinkit.com, we'd love to hear from you!<br><br>Best,<br><br>Team co&middot;think&middot;it<br>team@cothinkit.com<br>@cothinkit<br><br>--<br>Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"Cothinkit <noreply@cothinkit.com>"',
     :subject=>'"Reset your cothinkit password!"'
    }
  end
  
  def self.plan_changed
     {:content=>%Q{<p>Hi &lt;%= @first_name%&gt;:<br /><br />You've changed to the &lt;%= @plan_name%&gt; Plan on cothinkit.<br /><br />Have a question or comment? Send us an email at support@cothinkit.com and we'll get back to you!<br /><br />Best,<br /><br />Jesse Ma<br />Founder of co&middot;think&middot;it<br /><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br />@cothinkit<br /><br />--<br />Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"admin@cothinkit.com"',
     :subject=>'"You\'ve Successfully Changed to the #{@plan_name} Plan on cothinkit!"'
    }
  end
  
  def self.payment_failed
     {:content=>%Q{<p>Hi &lt;%= @first_name%&gt;:<br /><br />We've had a problem processing your payment on cothinkit. Until the issue is resolved, your projects will be suspended.<br /><br />Please visit the account page to resubmit your updated billing information. If you have any problems, please email me at your convenience.<br /><br />Best,<br /><br />Jesse Ma<br />Founder of co&middot;think&middot;it<br /><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br />@cothinkit<br /><br />--<br />Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"admin@cothinkit.com"',
     :subject=>'"Please update your billing information on cothinkit!"'
    }
  end
  
  def self.password_reset_admin
     {:content=>%Q{<p>Hi :<br /><br />Forgot your password? Don't worry I do it all the time and it's actually a good idea to change your password from time to time anyways!<br /><br />Please click the link below to confirm your registration:<br /><br />&nbsp;&lt;%= @url %&gt;<br /><br />Questions, comments, or need help getting started? Email me or our Support Team at support@cothinkit.com and we'll get back to you!<br /><br />Best,<br /><br />Jesse Ma<br />Founder of co&middot;think&middot;it<br /><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br />@cothinkit<br /><br />--<br />Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"Cothinkit <noreply@cothinkit.com>"',
     :subject=>'"Reset your cothinkit password!"'
    }
  end
  
  def self.storage_bandwidth
     {:content=>%Q{<p>Hi &lt;%= @first_name %&gt;:<br /><br />You're currently on the &lt;%= @plan %&gt; Plan, which allows for &lt;%= @storage_plan %&gt; storage and &lt;%= @transfer_plan %&gt; transfer per month. <br /><br />You're currently using &lt;%= @storage_plan %&gt; storage and &lt;%= @transfer_plan %&gt; transfer this month. It might be a good time to upgrade to the &lt;%= @next_plan %&gt; Plan, which allows for &lt;%= @storage_next_plan %&gt; storage and &lt;%= @transfer_next_plan %&gt; transfer.<br /><br />All of our plan limits are soft limits, but if you consistently exceed them, we will ask that you upgrade. If you have any questions, please send an email to <a target="_blank" href="mailto:support@cothinkit.com">support@cothinkit.com</a>.<br /><br />Best,<br /><br />Jesse Ma<br />Founder of co&middot;think&middot;it<br /><a target="_blank" href="mailto:jesse@cothinkit.com">jesse@cothinkit.com</a><br />@cothinkit<br /><br />--<br />Collaborating is just easier with co&middot;think&middot;it!</p>},
     :from=>'"admin@cothinkit.com"',
     :subject=>'"You\'re about to exceed your storage or transfer limits of current co穞hink穒t plan!"'
    }
  end
  
  def self.number_to_human_size(temp)
    
  end
  
  def valid_from_address
    unless self.from.blank?
      if self.from.include?("<")
        (self.from.split("<")[1].match /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})>\"$/i) ? true : errors.add(:from,"Error! Improper value entered")
      else
        (self.from.match /^\"([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\"$/i) ? true : errors.add(:from,"Error! Improper value entered")
      end
    end
  end
  
end
