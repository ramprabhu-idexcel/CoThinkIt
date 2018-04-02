module Admin::PlanmanagementHelper
  def convert_to_GB(value)
    if value.nil? || value.blank?
      "Unlimited"
    else
      value.include?("GB") ? value.to_f : (value.to_i/1024.0).round(2)
    end 
  end 
end
