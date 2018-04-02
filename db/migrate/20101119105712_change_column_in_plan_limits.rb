class ChangeColumnInPlanLimits < ActiveRecord::Migration
  def self.up
    change_column :plan_limits, :storage_used, :float
    change_column :plan_limits, :bandwidth_used, :float
    change_column :plan_limits, :download_bandwidth_in_MB, :float
  end

  def self.down
    change_column :plan_limits, :storage_used, :int
    change_column :plan_limits, :bandwidth_used, :int
    change_column :plan_limits, :download_bandwidth_in_MB, :int
  end
end
