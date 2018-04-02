class CreateBillingInformations < ActiveRecord::Migration
  def self.up
    create_table :billing_informations do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.integer :zip_code
      t.integer :country_id
      t.integer :plan_id
      t.integer :user_id
			 t.string :card_holder
			  t.integer :card
			  t.integer :ccv
			  t.integer :expires

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_informations
  end
end
