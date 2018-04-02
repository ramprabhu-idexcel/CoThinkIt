class AddIs90exceedAndIs100exceedToPlanLimits < ActiveRecord::Migration
  def self.up
    add_column :plan_limits, :is_90exceed, :boolean, :default=>0
    add_column :plan_limits, :is_100exceed, :boolean, :default=>0
  end

  def self.down
    remove_column :plan_limits, :is_100exceed
    remove_column :plan_limits, :is_90exceed
  end
end
