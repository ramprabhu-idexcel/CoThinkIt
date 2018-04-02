class AddNextBillingDateToBillingHistories < ActiveRecord::Migration
  def self.up
    add_column :billing_histories, :next_billing_date, :date
  end

  def self.down
    remove_column :billing_histories, :next_billing_date
  end
end
