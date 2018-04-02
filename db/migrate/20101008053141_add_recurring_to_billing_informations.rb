class AddRecurringToBillingInformations < ActiveRecord::Migration
  def self.up
    add_column :billing_informations, :recurring_profile_id, :string
    add_column :billing_informations, :card_type, :string,:limit=>30
    change_column :billing_informations, :expires, :date
    remove_column :billing_informations, :address
    add_column :billing_informations, :address1, :text
    add_column :billing_informations, :address2, :text
  end

  def self.down
    remove_column :billing_informations, :recurring_profile_id
    remove_column :billing_informations, :card_type
    change_column :billing_informations, :expires, :boolean
    remove_column :billing_informations, :address1, :string
    remove_column :billing_informations, :address2, :string
    add_column :billing_informations, :address,:text
  end
end
