class CreateMonthLimits < ActiveRecord::Migration
  def self.up
    create_table :month_limits do |t|
      t.integer :month, :default=>0
      t.integer :year, :default=>0
      t.integer :storage, :default=>0
      t.integer :bandwidth, :default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :month_limits
  end
end
