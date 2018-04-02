class BillingInformation < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan

  
  def self.paid_users
    find(:all,:conditions=>['recurring_profile_id IS NOT NULL'])
  end
end
