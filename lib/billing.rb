require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
class Getbilling<UsersController
  def find_billing
    @billing_info=BillingInformation.paid_users
    @billing_info.each do |bill|
      if bill.plan_id && bill.recurring_profile_id
        profile_id=bill.recurring_profile_id
        @response=creditcard_gateway.get_profile_details(profile_id)
        if @response.success? && @response.params['profile_status']=='ActiveProfile' && !(@response.params['failed_payment_count'].to_i>0)
          BillingHistory.create(:user_id=>bill.user_id,:plan_name=>@response.params['description'],:amount=>@response.params['last_payment_amount'],:billing_date=>@response.params['last_payment_date'],:is_sucess=>true)
        else
          UserMailer.deliver_payment_failed(bill.user)
          project_ids=bill.user.owner_project_ids
          ProjectUser.update_all(["status=?",false],"project_id IN (#{project_ids.join(',')})") unless project_ids.empty?
          creditcard_gateway.suspend_profile(profile_id)
        end
      end
    end
  end
end
  

@billing=Getbilling.new
@billing.find_billing


