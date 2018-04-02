class Plan < ActiveRecord::Base
  has_many :billing_informations
  def storage_value
    if storage.nil? || storage.blank?
      "Unlimited"
    else
      storage.include?("GB") ? storage.to_f*1024  : storage.to_f
    end
  end
  
    def bandwidth_value
    if transfer.nil? || transfer.blank?
      "Unlimited"
    else
      transfer.include?("GB") ? transfer.to_f*1024  : transfer.to_f
    end
  end
  

  
  def self.user_plans
    Plan.find(:all,:conditions=>['name!=?',"Beta"])
  end
end
