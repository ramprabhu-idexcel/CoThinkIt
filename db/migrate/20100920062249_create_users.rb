class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
       t.string   :first_name,                     :limit => 40
      t.string   :last_name,                      :limit => 100, :default => '', :null => true
      t.string   :company,                     :limit => 100
      t.string   :email,                     :limit => 100
      t.string   :site_address,                     :limit => 100
      t.string   :title,                     :limit => 100
      t.string   :mobile,                     :limit => 100
      t.string   :time_zone,                     :limit => 100
      t.string   :color_code,                     :limit => 100
      t.string   :office_phone,                     :limit => 100
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :remember_token,            :limit => 40
      t.datetime :remember_token_expires_at
      t.string   :activation_code,           :limit => 40
      t.datetime :activated_at

    end
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
