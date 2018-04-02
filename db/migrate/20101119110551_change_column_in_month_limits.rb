class ChangeColumnInMonthLimits < ActiveRecord::Migration
  def self.up
    change_column :month_limits, :storage, :float
    change_column :month_limits, :bandwidth, :float
  end

  def self.down
    change_column :month_limits, :storage, :int
    change_column :month_limits, :bandwidth, :int
  end
end
