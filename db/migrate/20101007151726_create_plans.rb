class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :name
      t.string :storage
      t.string :transfer
      t.float  :price
      t.integer :no_of_users
      t.integer :no_of_projects
      t.timestamps
    end
    #~ Plan.create([{:name=>"Genius",:storage=>"75GB",:transfer=>"250GB",:price=>99},
                 #~ {:name=>"Prodigy",:storage=>"25GB",:transfer=>"150GB",:price=>69},
                 #~ {:name=>"Sage",:storage=>"10GB",:transfer=>"50GB",:price=>29},
                 #~ {:name=>"Thinker",:storage=>"1GB",:transfer=>"5GB",:price=>9},
                 #~ {:name=>"Apprentice",:storage=>"10MB",:transfer=>"50MB",:price=>0,:no_of_users=>3,:no_of_projects=>1}])
								 
    Plan.create([{:name=>"Organization",:storage=>"102400MB",:transfer=>"307200MB",:price=>99},
                 {:name=>"Startup",:storage=>"51200MB",:transfer=>"153600MB",:price=>69},
                 {:name=>"Team",:storage=>"25600MB",:transfer=>"76800MB",:price=>24},
                 {:name=>"Freelancer",:storage=>"1024MB",:transfer=>"5120MB",:price=>9,:no_of_users=>25,:no_of_projects=>5},
								 {:name=>"Beta",:price=>0},
                 {:name=>"Trial",:storage=>"10MB",:transfer=>"50MB",:price=>0,:no_of_users=>15,:no_of_projects=>1}])								 
  end

  def self.down
    drop_table :plans
  end
end
