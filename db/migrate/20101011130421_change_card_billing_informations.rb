class ChangeCardBillingInformations < ActiveRecord::Migration
  def self.up
    change_column :billing_informations, :card, :bigint
  end

  def self.down
    change_column :billing_informations, :card, :integer
  end
end
