class RemoveCardFromBillingInformations < ActiveRecord::Migration
  def self.up
    remove_column :billing_informations, :card
    remove_column :billing_informations, :ccv
  end

  def self.down
    add_column :billing_information, :card,:string,:limit=>20
    add_column :billing_information, :ccv,:string,:limit=>10
  end
end
