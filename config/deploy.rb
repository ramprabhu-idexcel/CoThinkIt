require 'capistrano/ext/multistage'

# User account. admin is used so we don't have to allow
# root logins on the servers. RBAC is used to allow
# admin to restart the app servers.
set :spinner_user, nil
set :use_sudo, false
set :user, 'deploy'

# Application
set :application, "cothinkit"

# SCM
set :scm, :git
set :scm_username, "deploy"
set :scm_password, "c0th1nk1t"
set :repository,  "git@github.com:CatalystFactoryLabs/cothinkit.git"
set :branch, "amazon_cloud"