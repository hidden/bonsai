set :application, "bonsai"
set :repository,  "http://bitbucket.org/johno/bonsai/"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/rails/#{application}"
set :user, "bonsai"
set :use_sudo, false

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :mercurial

server "nimbus.fiit.stuba.sk", :app, :web, :db, :primary => true

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  task "start", :roles => :app do
    passenger.restart
  end

  task "restart", :roles => :app do
    passenger.restart
  end
end 