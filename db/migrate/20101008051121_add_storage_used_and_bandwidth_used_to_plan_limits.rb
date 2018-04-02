class AddStorageUsedAndBandwidthUsedToPlanLimits < ActiveRecord::Migration
  def self.up
    add_column :plan_limits, :storage_used, :integer, :default=>0
    add_column :plan_limits, :bandwidth_used, :integer, :default=>0
  end

  def self.down
    remove_column :plan_limits, :bandwidth_used
    remove_column :plan_limits, :storage_used
  end
end
