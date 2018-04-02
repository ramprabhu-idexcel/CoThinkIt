# Servers & roles
set :rails_env, :development
role :app, "117.20.4.204", :primary => true
role :db, "117.20.4.204", :primary => true

# Application
set :deploy_to, "/var/www/apps/berkelouw_stag"

# If you want to deploy some other branch means, set the branch here
#set :branch, "staging"

namespace :init do
  desc "create database.yml"
  task :database_yml do
    set :db_user, "app_stag"
    set :db_pass, "tvdJdP2S7"
    database_configuration =<<-EOF
---
login: &login

development:
  adapter: mysql
  database: #{application}_staging
  host: localhost
  username: #{db_user}
  password: #{db_pass}

  <<: *login

EOF
    run "mkdir -p #{shared_path}/config/database/"
    run "mkdir -p #{shared_path}/config/environments/"
    run "mkdir -p #{shared_path}/ftp_csv_downloads/"
    run "mkdir -p #{shared_path}/ftp_image_downloads/"
    put database_configuration, "#{shared_path}/config/database/database.yml"
  end
end

namespace :localize do
  
  desc "copy shared configurations to current"
  task :copy_shared_configurations, :roles => [:app] do
    %w[database.yml].each do |f|
      run "ln -nsf #{shared_path}/config/database/#{f} #{current_path}/config/#{f}"
      run "ln -nsf #{shared_path}/config/environments/staging.rb #{current_path}/config/environments/development.rb"
    end
  end
  
  desc "link important static files to current"
  task :link_static_files, :roles => [:app] do
    run "ln -nfs #{shared_path}/config/sphinx.yml #{current_path}/config/sphinx.yml"
    run "ln -nfs #{shared_path}/config/newrelic.yml #{current_path}/config/newrelic.yml"		
    run "ln -nfs #{shared_path}/config/htpasswd #{current_path}/public/.htpasswd"	
    run "ln -nfs #{shared_path}/config/development.sphinx.conf #{current_path}/config/development.sphinx.conf"
    run "ln -nfs /var/www/apps/berkelouw_live/shared/Large_Nielsen_Images #{current_path}/public/large"
    run "ln -nfs /var/www/apps/berkelouw_live/shared/Medium_Nielsen_Images #{current_path}/public/medium"
    run "ln -nfs /var/www/apps/berkelouw_live/shared/Small_Nielsen_Images #{current_path}/public/small"
    run "ln -nfs /var/www/apps/berkelouw_live/shared/rare #{current_path}/public/rare"
    run "ln -nfs /var/www/apps/berkelouw_live/shared/generic #{current_path}/public/generic"
    run "ln -nfs #{shared_path}/ftp_csv_downloads #{current_path}/db/ftp_csv_downloads"
    run "ln -nfs #{shared_path}/ftp_image_downloads #{current_path}/db/ftp_image_downloads"
  end
  
  desc "copy Expires header to our static content"
  task :copy_expires_header, :roles => [:app] do
    %w[header].each do |f|
        run "ln -nsf #{current_path}/public #{current_path}/public/add_expires_header"
     end
  end
    
end  

# We don't user spinner to control our app servers. SMF
# is used to manage them, so we need to define custom
# SMF commands for start/stop/restart here. RBAC is used
# to allow the admin user to control these services.
  
namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
	end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path} && ruby script/delayed_job start"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path} && ruby script/delayed_job stop"
    sleep(5)
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path} && ruby script/delayed_job"
    puts "wait for 15 secs to restart DJ...."
    sleep(15)
    run "cd #{current_path} && ruby script/delayed_job"
  end
end

after "deploy:setup", "init:database_yml"
after "deploy:symlink", "localize:copy_shared_configurations"
after "deploy:symlink", "localize:link_static_files"
after "deploy:symlink", "localize:copy_expires_header"
#~ after "deploy:stop", "delayed_job:stop"
#~ after "deploy:start", "delayed_job:start"
after "deploy:restart", "delayed_job:restart"


