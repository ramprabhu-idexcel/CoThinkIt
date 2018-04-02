# Servers & roles
role :app, "cothinkit.com", :primary => true
role :db, "cothinkit.com", :primary => true
role :web, "cothinkit.com", :asset_host_syncher => true

# Application
set :deploy_to, "/data/cothinkit"


# If you want to deploy some other branch means, set the branch here
#set :branch, "staging"

namespace :init do
  desc "create database.yml"
  task :database_yml do
    set :db_user, "deploy"
    set :db_pass, "m8YPTwBpRZ"
    database_configuration =<<-EOF
---
login: &login

production:
  adapter: mysql
  database: #{application}
  host: localhost
  username: #{db_user}
  password: #{db_pass}

  <<: *login

EOF
    run "mkdir -p #{shared_path}/config/database/"          
    put database_configuration, "#{shared_path}/config/database/database.yml"
  end
end

namespace :localize do
  
  desc "copy shared configurations to current"
  task :copy_shared_configurations, :roles => [:app] do
    %w[database.yml].each do |f|
      run "ln -nsf #{shared_path}/config/database/#{f} #{current_path}/config/#{f}"       
    end
  end  
   
end  

#~ namespace :rake do
  #~ desc "Create sphinx indexing for production" 
  #~ task :sphinx_update, :roles => :app do
     #~ run "cd #{current_path} && rake ts:start RAILS_ENV=production"
   #~ end
#~ end
  # We don't user spinner to control our app servers. SMF
  # is used to manage them, so we need to define custom
  # SMF commands for start/stop/restart here. RBAC is used
  # to allow the admin user to control these services.
  
namespace :deploy do
  desc "Restart Application"
  before "deploy:symlink", "s3_asset_host:synch_public"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end 

after "deploy:setup", "init:database_yml"
after "deploy:symlink", "localize:copy_shared_configurations"
 