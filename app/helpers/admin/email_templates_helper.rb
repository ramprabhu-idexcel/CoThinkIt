module Admin::EmailTemplatesHelper
  def display_key(key)
    case key
      when "Password Reset Admin"
        "Admin Reset Password"
      when "New Member Invitation"
        "Invite More People"
      else
        key
    end
  end
end
