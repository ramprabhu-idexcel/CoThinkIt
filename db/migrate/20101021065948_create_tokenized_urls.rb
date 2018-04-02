class CreateTokenizedUrls < ActiveRecord::Migration
  def self.up
    create_table :tokenized_urls do |t|
      t.string :token
			t.string :asssigned_url
      t.timestamps
    end
  end

  def self.down
    drop_table :tokenized_urls
  end
end
