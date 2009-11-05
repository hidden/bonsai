set :application, "wiki"
set :repository,  "git://github.com/jsuchal/bonsai.git"

set :deploy_to, "/var/rails/#{application}"
set :user, "wiki"
set :use_sudo, false
set :ssh_options, {:forward_agent => true}

set :scm, :git

server "kif.fiit.stuba.sk", :app, :web, :db, :primary => true

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

  desc "Symlink shared"
  task :symlink_shared do
    run "ln -nfs #{shared_path} #{release_path}/shared"
  end

  task :symlink_database_yml do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task "restart", :roles => :app do
    passenger.restart
  end
end

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
after "deploy:finalize_update", 'deploy:symlink_database_yml'
after "deploy:symlink", "deploy:update_crontab"