class CreateBillingHistories < ActiveRecord::Migration
  def self.up
    create_table :billing_histories do |t|
      t.integer :user_id
      t.string :plan_name
      t.float :amount
      t.date :billing_date
      t.boolean :is_sucess,:default=>true
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_histories
  end
end
