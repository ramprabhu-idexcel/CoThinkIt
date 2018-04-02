class UserObserver < ActiveRecord::Observer
  def after_create(user)
   # UserMailer.deliver_signup_notification(user)
  end

  def after_save(user)
  
    UserMailer.deliver_activation(user,request.env['HTTP_HOST'],request.env['SERVER_NAME'])   if user.activated_at
  
  end
end
